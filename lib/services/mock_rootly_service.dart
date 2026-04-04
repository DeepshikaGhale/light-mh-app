import '../models/rootly_models.dart';

/// Mock Rootly data for hackathon demo.
/// In production, these call the real Rootly API + On-Call Health API.
class MockRootlyService {
  /// Simulated recent incidents for the current user
  static List<RootlyIncident> getRecentIncidents() {
    final now = DateTime.now();
    return [
      RootlyIncident(
        id: 'INC-1847',
        title: 'Database connection pool exhausted',
        severity: 'sev1',
        status: 'resolved',
        startedAt: now.subtract(const Duration(hours: 6, minutes: 23)),
        resolvedAt: now.subtract(const Duration(hours: 4, minutes: 11)),
        mttr: const Duration(hours: 2, minutes: 12),
      ),
      RootlyIncident(
        id: 'INC-1842',
        title: 'Auth service 5xx spike (>15%)',
        severity: 'sev1',
        status: 'resolved',
        startedAt: now.subtract(const Duration(days: 1, hours: 2)),
        resolvedAt: now.subtract(const Duration(days: 1)),
        mttr: const Duration(hours: 1, minutes: 47),
      ),
      RootlyIncident(
        id: 'INC-1838',
        title: 'Payment webhook delivery failures',
        severity: 'sev0',
        status: 'resolved',
        startedAt: now.subtract(const Duration(days: 2, hours: 3)),
        resolvedAt: now.subtract(const Duration(days: 1, hours: 22)),
        mttr: const Duration(hours: 5, minutes: 3),
      ),
      RootlyIncident(
        id: 'INC-1835',
        title: 'CDN cache purge timeout',
        severity: 'sev2',
        status: 'resolved',
        startedAt: now.subtract(const Duration(days: 3, hours: 14)),
        resolvedAt: now.subtract(const Duration(days: 3, hours: 13)),
        mttr: const Duration(minutes: 45),
      ),
      RootlyIncident(
        id: 'INC-1831',
        title: 'Kubernetes node OOM - prod-worker-7',
        severity: 'sev1',
        status: 'resolved',
        startedAt: now.subtract(const Duration(days: 4, hours: 1, minutes: 15)),
        resolvedAt: now.subtract(const Duration(days: 3, hours: 22)),
        mttr: const Duration(hours: 3, minutes: 15),
      ),
      RootlyIncident(
        id: 'INC-1828',
        title: 'API latency p99 > 2s on /search',
        severity: 'sev3',
        status: 'resolved',
        startedAt: now.subtract(const Duration(days: 5, hours: 10)),
        resolvedAt: now.subtract(const Duration(days: 5, hours: 9)),
        mttr: const Duration(minutes: 32),
      ),
      RootlyIncident(
        id: 'INC-1824',
        title: 'SSL certificate expiry - api.prod',
        severity: 'sev2',
        status: 'resolved',
        startedAt: now.subtract(const Duration(days: 6, hours: 16)),
        resolvedAt: now.subtract(const Duration(days: 6, hours: 15)),
        mttr: const Duration(minutes: 55),
      ),
    ];
  }

  /// Simulated OCH score + trend
  static OnCallHealthScore getOCHScore() {
    return OnCallHealthScore(
      score: 67,
      trend: -12, // declining
      timestamp: DateTime.now(),
      riskFactors: [
        '3 sev0/sev1 incidents in 7 days',
        '2 after-hours pages this week',
        'On-call 3 consecutive weeks',
        'Slack sentiment: declining',
        'PR review backlog: 8 open',
      ],
    );
  }

  /// Simulated shift metrics
  static ShiftMetrics getShiftMetrics() {
    return ShiftMetrics(
      totalShiftsThisWeek: 3,
      hoursOnCall: 52.5,
      incidentCount: 7,
      afterHoursPages: 3,
      avgMttrMinutes: 127,
    );
  }

  /// Simulated handoff summary (would come from Rootly MCP in production)
  static String generateHandoffSummary() {
    return '''## On-Call Handoff Summary
**Outgoing:** You  |  **Incoming:** Sarah K.  |  **Generated:** ${DateTime.now().toString().substring(0, 16)}

### Open Items
- **INC-1847** (Sev1) — DB connection pool exhausted. Resolved, but monitoring for recurrence. Pool size bumped from 50→100 in `prod-db-config`.
- **INC-1842** (Sev1) — Auth service 5xx. Root cause: bad deploy at 14:02. Rolled back. Post-mortem scheduled Thursday.

### Watch List
- Payment webhooks (INC-1838) — delivery queue still draining. ETA: 2 hours.
- Node memory on `prod-worker-7` — OOM killed twice this week. Infra ticket INFRA-442 open.

### Context
- Deploy freeze until Thursday per INC-1838 post-mortem
- Platform team aware of k8s memory issues
- PagerDuty escalation updated: backup is Marcus T.

### Biological Note
⚠️ Outgoing engineer's resilience score is in **Early Intervention** range. 3 after-hours pages in 48h, sleep quality declining. Recommend light shift for next rotation.''';
  }
}

/// Mock wellness/sleep data based on DREAMT dataset parameters
class MockWellnessService {
  /// 7-day sleep history — shows degradation after incidents
  static List<SleepMetrics> getWeeklySleep() {
    final now = DateTime.now();
    return [
      // 7 days ago — good baseline
      SleepMetrics(
        sleepEfficiency: 91,
        deepSleepRatio: 22,
        fragmentationIndex: 2.1,
        rmssd: 42,
        sleepLatencyMin: 12,
        date: now.subtract(const Duration(days: 6)),
      ),
      // 6 days ago — after sev2 incident, slight dip
      SleepMetrics(
        sleepEfficiency: 88,
        deepSleepRatio: 19,
        fragmentationIndex: 3.0,
        rmssd: 38,
        sleepLatencyMin: 18,
        date: now.subtract(const Duration(days: 5)),
      ),
      // 5 days ago — recovering
      SleepMetrics(
        sleepEfficiency: 89,
        deepSleepRatio: 20,
        fragmentationIndex: 2.8,
        rmssd: 40,
        sleepLatencyMin: 15,
        date: now.subtract(const Duration(days: 4)),
      ),
      // 4 days ago — sev1 at 1AM, big drop
      SleepMetrics(
        sleepEfficiency: 62,
        deepSleepRatio: 8,
        fragmentationIndex: 7.2,
        rmssd: 22,
        sleepLatencyMin: 45,
        date: now.subtract(const Duration(days: 3)),
      ),
      // 3 days ago — sev0 payment incident, still wrecked
      SleepMetrics(
        sleepEfficiency: 58,
        deepSleepRatio: 6,
        fragmentationIndex: 8.5,
        rmssd: 19,
        sleepLatencyMin: 52,
        date: now.subtract(const Duration(days: 2)),
      ),
      // 2 days ago — sev1 auth, compounding
      SleepMetrics(
        sleepEfficiency: 64,
        deepSleepRatio: 10,
        fragmentationIndex: 6.8,
        rmssd: 24,
        sleepLatencyMin: 38,
        date: now.subtract(const Duration(days: 1)),
      ),
      // Today — still not recovered
      SleepMetrics(
        sleepEfficiency: 71,
        deepSleepRatio: 13,
        fragmentationIndex: 5.4,
        rmssd: 28,
        sleepLatencyMin: 28,
        date: now,
      ),
    ];
  }

  /// Compute the fusion: Resilience Delta
  static ResilienceDelta computeResilienceDelta() {
    final och = MockRootlyService.getOCHScore();
    final sleepData = getWeeklySleep();
    final latestSleep = sleepData.last;
    final sleepRisk = latestSleep.sleepRiskScore;

    // Weighted composite
    double composite = 0.6 * och.score + 0.4 * sleepRisk;

    // Interaction effect: both high = multiplicative
    if (och.score > 50 && sleepRisk > 50) {
      composite = (composite * 1.3).clamp(0, 100);
    }

    // Delta: positive = resilient, negative = biological debt
    final recoveryCapacity = 100 - sleepRisk;
    final delta = recoveryCapacity - och.score;

    final insights = <String>[];

    if (latestSleep.sleepEfficiency < 85) {
      insights.add(
        'Sleep efficiency ${latestSleep.sleepEfficiency.toStringAsFixed(0)}% '
        '(baseline: 91%). Down ${(91 - latestSleep.sleepEfficiency).toStringAsFixed(0)}pp since Monday.'
      );
    }
    if (latestSleep.rmssd < 30) {
      insights.add(
        'HRV (RMSSD) at ${latestSleep.rmssd.toStringAsFixed(0)}ms. '
        'Below 30ms threshold — high sympathetic activation.'
      );
    }
    if (latestSleep.fragmentationIndex > 5) {
      insights.add(
        'Sleep fragmentation ${latestSleep.fragmentationIndex.toStringAsFixed(1)} '
        'awakenings/hr. After-hours pages are disrupting recovery.'
      );
    }

    final incidents = MockRootlyService.getRecentIncidents();
    final afterHours = incidents.where((i) => i.afterHours).length;
    if (afterHours > 1) {
      insights.add(
        '$afterHours after-hours incidents in 7 days. Each 2AM page costs '
        '1.5x more biological recovery than daytime.'
      );
    }

    final totalBioCost = incidents.fold<double>(0, (s, i) => s + i.biologicalCostHours);
    insights.add(
      'Total biological cost this week: ${totalBioCost.toStringAsFixed(0)} hours of recovery needed. '
      'Available recovery time: ~56 hours. Deficit: ${(totalBioCost - 56).toStringAsFixed(0)}h.'
    );

    return ResilienceDelta(
      ochScore: och.score,
      sleepRisk: sleepRisk,
      compositeScore: composite.round(),
      delta: delta,
      insights: insights,
    );
  }
}
