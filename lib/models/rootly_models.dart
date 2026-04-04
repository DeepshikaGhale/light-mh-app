// Models for Rootly incident data and On-Call Health metrics.

class RootlyIncident {
  final String id;
  final String title;
  final String severity; // sev0, sev1, sev2, sev3
  final String status;
  final DateTime startedAt;
  final DateTime? resolvedAt;
  final Duration? mttr;
  final bool afterHours; // occurred between 10PM-6AM

  RootlyIncident({
    required this.id,
    required this.title,
    required this.severity,
    required this.status,
    required this.startedAt,
    this.resolvedAt,
    this.mttr,
    bool? afterHours,
  }) : afterHours = afterHours ?? (startedAt.hour >= 22 || startedAt.hour < 6);

  int get severityNum {
    switch (severity) {
      case 'sev0': return 0;
      case 'sev1': return 1;
      case 'sev2': return 2;
      case 'sev3': return 3;
      default: return 4;
    }
  }

  String get severityEmoji {
    switch (severity) {
      case 'sev0': return '🔴';
      case 'sev1': return '🔴';
      case 'sev2': return '🟡';
      case 'sev3': return '🟢';
      default: return '⚪';
    }
  }

  /// Estimated biological recovery time in hours based on severity + time of day
  double get biologicalCostHours {
    double base;
    switch (severity) {
      case 'sev0': base = 72; break;  // 3 days
      case 'sev1': base = 48; break;  // 2 days
      case 'sev2': base = 12; break;
      case 'sev3': base = 4; break;
      default: base = 2;
    }
    // After-hours incidents cost 1.5x more recovery
    if (afterHours) base *= 1.5;
    return base;
  }
}

class OnCallHealthScore {
  final int score;         // 0-100
  final int trend;         // positive = improving, negative = declining
  final DateTime timestamp;
  final List<String> riskFactors;

  OnCallHealthScore({
    required this.score,
    required this.trend,
    required this.timestamp,
    required this.riskFactors,
  });

  String get tier {
    if (score >= 75) return 'IMMEDIATE ACTION';
    if (score >= 50) return 'EARLY INTERVENTION';
    if (score >= 25) return 'MONITOR RISK';
    return 'MAINTAIN BALANCE';
  }
}

class ShiftMetrics {
  final int totalShiftsThisWeek;
  final double hoursOnCall;
  final int incidentCount;
  final int afterHoursPages;
  final double avgMttrMinutes;

  ShiftMetrics({
    required this.totalShiftsThisWeek,
    required this.hoursOnCall,
    required this.incidentCount,
    required this.afterHoursPages,
    required this.avgMttrMinutes,
  });
}

class SleepMetrics {
  final double sleepEfficiency;      // 0-100%
  final double deepSleepRatio;       // 0-100%
  final double fragmentationIndex;   // awakenings per hour
  final double rmssd;                // HRV in ms
  final double sleepLatencyMin;      // minutes to fall asleep
  final DateTime date;

  SleepMetrics({
    required this.sleepEfficiency,
    required this.deepSleepRatio,
    required this.fragmentationIndex,
    required this.rmssd,
    required this.sleepLatencyMin,
    required this.date,
  });

  /// Sleep risk score 0-100 (higher = worse)
  int get sleepRiskScore {
    double risk = 0;
    // Sleep efficiency: <85% is poor
    if (sleepEfficiency < 85) risk += (85 - sleepEfficiency) * 2;
    // Deep sleep: <15% is insufficient
    if (deepSleepRatio < 15) risk += (15 - deepSleepRatio) * 2;
    // Fragmentation: >5 is disrupted
    if (fragmentationIndex > 5) risk += (fragmentationIndex - 5) * 5;
    // HRV: RMSSD < 30ms is high stress
    if (rmssd < 30) risk += (30 - rmssd) * 1.5;
    // Sleep latency: >30 min is hyperarousal
    if (sleepLatencyMin > 30) risk += (sleepLatencyMin - 30);
    return risk.clamp(0, 100).round();
  }
}

/// The core fusion metric
class ResilienceDelta {
  final int ochScore;       // Rootly load (0-100)
  final int sleepRisk;      // DREAMT recovery deficit (0-100)
  final int compositeScore; // Fused burnout risk (0-100)
  final int delta;          // Recovery - Load (negative = biological debt)
  final List<String> insights;

  ResilienceDelta({
    required this.ochScore,
    required this.sleepRisk,
    required this.compositeScore,
    required this.delta,
    required this.insights,
  });

  bool get inDebt => delta < 0;

  String get statusLabel {
    if (compositeScore >= 75) return 'BIOLOGICAL DEBT CRITICAL';
    if (compositeScore >= 50) return 'BIOLOGICAL DEBT DETECTED';
    if (compositeScore >= 25) return 'RECOVERY DECLINING';
    return 'RESILIENT';
  }
}
