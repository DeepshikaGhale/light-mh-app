/// Client for the Light Resilience Bridge backend.
/// Falls back to mock data if the backend isn't reachable.
class ResilienceBridge {
  // Backend URL — for emulator: 10.0.2.2, for real device: your IP
  // static const baseUrl = 'http://localhost:3001';

  /// Fetch full recovery debt computation from the backend.
  /// Returns a RecoveryDebtResult.
  static Future<RecoveryDebtResult> getRecoveryDebt() async {
    // For hackathon demo, we compute locally to avoid network dependency.
    // In production, this would call: GET $_baseUrl/recovery-debt
    return _computeLocally();
  }

  /// Local computation (same logic as backend ResilienceEngine)
  static RecoveryDebtResult _computeLocally() {
    final och = 67; // Mock OCH from Rootly
    final sleepHours = 5.8;
    final rmssd = 28.0;
    final hrvNormalized = (rmssd / 50 * 100).clamp(0, 100);

    // Biological score
    int sleepScore;
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
    final hrvComponent = (hrvNormalized * 0.5).clamp(0, 50).round();
    final biologicalScore = sleepScore + hrvComponent;

    // Recovery Debt
    final recoveryDebt = och - biologicalScore;

    // State
    String state;
    if (recoveryDebt > 30) {
      state = 'CRITICAL_DEBT';
    } else if (recoveryDebt > 15) {
      state = 'WARNING';
    } else {
      state = 'STABLE';
    }

    return RecoveryDebtResult(
      biologicalScore: biologicalScore,
      operationalRisk: och,
      recoveryDebt: recoveryDebt,
      state: state,
      sleepHours: sleepHours,
      hrvScore: hrvNormalized.round(),
      rmssd: rmssd,
      incidentCount: 7,
      afterHoursIncidents: 3,
    );
  }
}

class RecoveryDebtResult {
  final int biologicalScore;
  final int operationalRisk;
  final int recoveryDebt;
  final String state;
  final double sleepHours;
  final int hrvScore;
  final double rmssd;
  final int incidentCount;
  final int afterHoursIncidents;

  RecoveryDebtResult({
    required this.biologicalScore,
    required this.operationalRisk,
    required this.recoveryDebt,
    required this.state,
    required this.sleepHours,
    required this.hrvScore,
    required this.rmssd,
    required this.incidentCount,
    required this.afterHoursIncidents,
  });

  bool get isCritical => state == 'CRITICAL_DEBT';
  bool get isWarning => state == 'WARNING';
  bool get isStable => state == 'STABLE';

  String get stateLabel {
    switch (state) {
      case 'CRITICAL_DEBT': return 'RECOVERY DEBT: CRITICAL';
      case 'WARNING': return 'RECOVERY DEBT: WARNING';
      default: return 'STABLE';
    }
  }
}
