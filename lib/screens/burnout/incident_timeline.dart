import 'package:flutter/material.dart';
import '../../theme/obs_theme.dart';
import '../../models/rootly_models.dart';
import '../../services/mock_rootly_service.dart';

class IncidentTimeline extends StatelessWidget {
  const IncidentTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final incidents = MockRootlyService.getRecentIncidents();
    final sleepData = MockWellnessService.getWeeklySleep();

    return Scaffold(
      backgroundColor: ObsTheme.bgOf(context),
      appBar: AppBar(
        title: const Text('Incident × Biology'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: incidents.length,
        itemBuilder: (context, index) {
          final incident = incidents[index];
          // Find closest sleep data
          final closestSleep = _findClosestSleep(incident.startedAt, sleepData);

          return _IncidentCard(
            incident: incident,
            sleepMetrics: closestSleep,
            isLast: index == incidents.length - 1,
          );
        },
      ),
    );
  }

  SleepMetrics? _findClosestSleep(DateTime incidentTime, List<SleepMetrics> sleep) {
    if (sleep.isEmpty) return null;
    SleepMetrics? closest;
    int minDiff = 999999;
    for (final s in sleep) {
      final diff = (s.date.difference(incidentTime).inHours).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = s;
      }
    }
    return closest;
  }
}

class _IncidentCard extends StatelessWidget {
  final RootlyIncident incident;
  final SleepMetrics? sleepMetrics;
  final bool isLast;

  const _IncidentCard({
    required this.incident,
    this.sleepMetrics,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final sevColor = incident.severityNum <= 1 ? ObsTheme.critical :
                     incident.severityNum == 2 ? ObsTheme.warning : ObsTheme.safeOf(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline spine
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: sevColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: sevColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: ObsTheme.borderOf(context),
                    ),
                  ),
              ],
            ),
          ),
          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ObsTheme.surfaceOf(context),
                border: Border.all(color: ObsTheme.borderOf(context)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: sevColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          incident.severity.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                            color: sevColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        incident.id,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Courier',
                          color: ObsTheme.textMutedOf(context),
                        ),
                      ),
                      const Spacer(),
                      if (incident.afterHours)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ObsTheme.critical.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.nightlight_round, size: 10, color: ObsTheme.critical),
                              const SizedBox(width: 4),
                              Text(
                                'AFTER-HOURS',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontFamily: 'Courier',
                                  color: ObsTheme.critical,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    incident.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ObsTheme.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(incident.startedAt),
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Courier',
                      color: ObsTheme.textMutedOf(context),
                    ),
                  ),
                  if (incident.mttr != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'MTTR: ${_formatDuration(incident.mttr!)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Courier',
                        color: ObsTheme.textSecondaryOf(context),
                      ),
                    ),
                  ],

                  // Biological cost section
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ObsTheme.bgOf(context),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: incident.biologicalCostHours > 24
                            ? ObsTheme.critical.withValues(alpha: 0.3)
                            : ObsTheme.borderOf(context),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BIOLOGICAL COST',
                          style: TextStyle(
                            fontSize: 9,
                            fontFamily: 'Courier',
                            letterSpacing: 1,
                            color: ObsTheme.textMutedOf(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              size: 16,
                              color: incident.biologicalCostHours > 24
                                  ? ObsTheme.critical
                                  : ObsTheme.warning,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${incident.biologicalCostHours.toStringAsFixed(0)}h recovery needed',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                                color: incident.biologicalCostHours > 24
                                    ? ObsTheme.critical
                                    : ObsTheme.warning,
                              ),
                            ),
                          ],
                        ),
                        if (sleepMetrics != null) ...[
                          const SizedBox(height: 8),
                          // Sleep impact mini-bar
                          Row(
                            children: [
                              _SleepMini(
                                label: 'SLEEP EFF',
                                value: '${sleepMetrics!.sleepEfficiency.toStringAsFixed(0)}%',
                                bad: sleepMetrics!.sleepEfficiency < 85,
                              ),
                              const SizedBox(width: 12),
                              _SleepMini(
                                label: 'DEEP SLEEP',
                                value: '${sleepMetrics!.deepSleepRatio.toStringAsFixed(0)}%',
                                bad: sleepMetrics!.deepSleepRatio < 15,
                              ),
                              const SizedBox(width: 12),
                              _SleepMini(
                                label: 'HRV',
                                value: '${sleepMetrics!.rmssd.toStringAsFixed(0)}ms',
                                bad: sleepMetrics!.rmssd < 30,
                              ),
                            ],
                          ),
                        ],
                        if (incident.afterHours) ...[
                          const SizedBox(height: 6),
                          Text(
                            '× 1.5 multiplier (after-hours incident)',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Courier',
                              color: ObsTheme.critical.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    if (diff.inDays == 0) return 'Today $h:$m';
    if (diff.inDays == 1) return 'Yesterday $h:$m';
    return '${diff.inDays}d ago $h:$m';
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m';
  }
}

class _SleepMini extends StatelessWidget {
  final String label;
  final String value;
  final bool bad;
  const _SleepMini({required this.label, required this.value, required this.bad});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontFamily: 'Courier',
            letterSpacing: 0.5,
            color: ObsTheme.textMutedOf(context),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
            color: bad ? ObsTheme.critical : ObsTheme.safeOf(context),
          ),
        ),
      ],
    );
  }
}
