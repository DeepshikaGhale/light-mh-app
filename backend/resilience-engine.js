/**
 * ResilienceEngine — Core computation for Recovery Debt.
 *
 * Inputs:
 *   - operationalRisk (0-100): from Rootly OCH score
 *   - incidentEvents: [{timestamp, severity, resolved_at}]
 *   - sleepHours: last night's sleep
 *   - hrvScore: normalized RMSSD (0-100, higher = better)
 *
 * Outputs:
 *   - biologicalScore (0-100)
 *   - recoveryDebt (can be negative = surplus)
 *   - state: CRITICAL_DEBT | WARNING | STABLE
 *   - recommendations[]
 */

class ResilienceEngine {
  /**
   * Compute biological recovery score from sleep + HRV.
   * No ML — deterministic weighted formula.
   */
  static computeBiologicalScore(sleepHours, hrvScore) {
    // Sleep component (0-50 points)
    // Optimal: 7-9h. Below 6h = heavy penalty.
    let sleepScore;
    if (sleepHours >= 7) {
      sleepScore = 50;
    } else if (sleepHours >= 6) {
      sleepScore = 35;
    } else if (sleepHours >= 5) {
      sleepScore = 20;
    } else if (sleepHours >= 4) {
      sleepScore = 10;
    } else {
      sleepScore = 0;
    }

    // HRV component (0-50 points)
    // hrvScore is already normalized 0-100, we take half
    const hrvComponent = Math.min(50, hrvScore * 0.5);

    return Math.round(sleepScore + hrvComponent);
  }

  /**
   * Compute Recovery Debt.
   * Positive = debt (bad). Negative = surplus (good).
   */
  static computeRecoveryDebt(operationalRisk, biologicalScore) {
    return operationalRisk - biologicalScore;
  }

  /**
   * Classify state based on recovery debt.
   */
  static classifyState(recoveryDebt) {
    if (recoveryDebt > 30) return 'CRITICAL_DEBT';
    if (recoveryDebt > 15) return 'WARNING';
    return 'STABLE';
  }

  /**
   * Map incidents to biological dips.
   * Aligns incident timestamps with simulated HRV/sleep drops.
   */
  static mapIncidentsToBiologicalImpact(incidentEvents, sleepTimeline, hrvTimeline) {
    return incidentEvents.map(incident => {
      const sevMultiplier = { sev0: 4.0, sev1: 3.0, sev2: 1.5, sev3: 0.5 };
      const afterHours = new Date(incident.timestamp).getHours() >= 22 ||
                         new Date(incident.timestamp).getHours() < 6;

      // Base recovery hours by severity
      const baseRecoveryHours = (sevMultiplier[incident.severity] || 1.0) * 16;
      const actualRecoveryHours = afterHours ? baseRecoveryHours * 1.5 : baseRecoveryHours;

      // Find closest HRV reading to incident
      let hrvDrop = null;
      if (hrvTimeline && hrvTimeline.length > 0) {
        const incidentTime = new Date(incident.timestamp).getTime();
        const closest = hrvTimeline.reduce((prev, curr) => {
          return Math.abs(new Date(curr.timestamp).getTime() - incidentTime) <
                 Math.abs(new Date(prev.timestamp).getTime() - incidentTime)
            ? curr : prev;
        });
        // Simulate HRV drop based on severity
        const dropPercent = { sev0: 55, sev1: 40, sev2: 20, sev3: 10 };
        hrvDrop = {
          before: closest.value,
          after: Math.round(closest.value * (1 - (dropPercent[incident.severity] || 15) / 100)),
          dropPercent: dropPercent[incident.severity] || 15,
        };
      }

      return {
        incidentId: incident.id,
        title: incident.title,
        severity: incident.severity,
        timestamp: incident.timestamp,
        afterHours,
        biologicalCost: {
          recoveryHoursNeeded: Math.round(actualRecoveryHours),
          afterHoursMultiplier: afterHours ? 1.5 : 1.0,
          hrvImpact: hrvDrop,
        },
        status: actualRecoveryHours > 24 ? 'RECOVERY_INCOMPLETE' : 'RECOVERED',
      };
    });
  }

  /**
   * Generate actionable recommendations based on state.
   */
  static generateRecommendations(state, recoveryDebt, incidentImpacts) {
    const recs = [];

    if (state === 'CRITICAL_DEBT') {
      recs.push({
        priority: 'CRITICAL',
        action: 'REQUEST_SHIFT_SWAP',
        message: 'Recovery debt is critical. Request immediate shift relief.',
        rootlyAction: 'POST /v1/override_shifts',
      });
      recs.push({
        priority: 'CRITICAL',
        action: 'GENERATE_HANDOFF',
        message: 'Generate handoff summary for clean transition.',
        rootlyAction: 'MCP: get_oncall_handoff_summary',
      });
      recs.push({
        priority: 'HIGH',
        action: 'SILENCE_LOW_SEV',
        message: 'Silence sev3/sev4 alerts for recovery period.',
        rootlyAction: 'MCP: update incident alerts',
      });
    }

    if (state === 'WARNING') {
      recs.push({
        priority: 'MEDIUM',
        action: 'MONITOR',
        message: `Recovery debt at ${recoveryDebt}. Consider reducing on-call load.`,
        rootlyAction: 'MCP: check_responder_availability',
      });
      recs.push({
        priority: 'MEDIUM',
        action: 'BREATHING_EXERCISE',
        message: '4-7-8 breathing to activate parasympathetic recovery.',
        rootlyAction: null,
      });
    }

    if (state === 'STABLE') {
      recs.push({
        priority: 'LOW',
        action: 'MAINTAIN',
        message: 'Recovery capacity is adequate. Continue current rotation.',
        rootlyAction: null,
      });
    }

    // Add incident-specific recs
    const unrecovered = (incidentImpacts || []).filter(i => i.status === 'RECOVERY_INCOMPLETE');
    if (unrecovered.length > 0) {
      recs.push({
        priority: 'HIGH',
        action: 'RECOVERY_JOURNAL',
        message: `${unrecovered.length} incident(s) still impacting recovery. Debrief journaling recommended.`,
        rootlyAction: null,
      });
    }

    return recs;
  }

  /**
   * Full pipeline: compute everything from raw inputs.
   */
  static compute({ operationalRisk, incidentEvents, sleepHours, hrvScore, hrvTimeline }) {
    const biologicalScore = this.computeBiologicalScore(sleepHours, hrvScore);
    const recoveryDebt = this.computeRecoveryDebt(operationalRisk, biologicalScore);
    const state = this.classifyState(recoveryDebt);

    const incidentImpacts = this.mapIncidentsToBiologicalImpact(
      incidentEvents || [],
      [],
      hrvTimeline || []
    );

    const recommendations = this.generateRecommendations(state, recoveryDebt, incidentImpacts);

    return {
      biologicalScore,
      operationalRisk,
      recoveryDebt,
      state,
      summary: {
        sleepHours,
        hrvScore,
        incidentCount: (incidentEvents || []).length,
        afterHoursIncidents: (incidentEvents || []).filter(i =>
          new Date(i.timestamp).getHours() >= 22 || new Date(i.timestamp).getHours() < 6
        ).length,
      },
      incidentImpacts,
      recommendations,
      timestamp: new Date().toISOString(),
    };
  }
}

module.exports = { ResilienceEngine };
