import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/obs_theme.dart';
import '../../models/rootly_models.dart';
import '../../services/app_state.dart';
import '../../services/mock_rootly_service.dart';
import 'incident_timeline.dart';
import 'circuit_breaker.dart';

class BurnoutDashboard extends StatelessWidget {
  const BurnoutDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final delta = MockWellnessService.computeResilienceDelta();
    final och = MockRootlyService.getOCHScore();
    final shift = MockRootlyService.getShiftMetrics();
    final sleepHistory = MockWellnessService.getWeeklySleep();

    return Scaffold(
      backgroundColor: ObsTheme.bgOf(context),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: delta.inDebt ? ObsTheme.critical : ObsTheme.safeOf(context),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Light'),
            const Spacer(),
            Text(
              'LIVE',
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Courier',
                color: ObsTheme.safeOf(context),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              ObsTheme.isDark(context) ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
            onPressed: () => context.read<AppState>().toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: ObsTheme.tierColor(delta.compositeScore).withValues(alpha: 0.1),
                border: Border.all(
                  color: ObsTheme.tierColor(delta.compositeScore).withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    delta.compositeScore >= 50
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    color: ObsTheme.tierColor(delta.compositeScore),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'STATUS: ${delta.statusLabel}',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      color: ObsTheme.tierColor(delta.compositeScore),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Resilience gauge
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: CustomPaint(
                  painter: _ResilienceGaugePainter(
                    compositeScore: delta.compositeScore,
                    ochScore: delta.ochScore,
                    sleepRisk: delta.sleepRisk,
                    borderColor: ObsTheme.borderOf(context),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${delta.delta > 0 ? "+" : ""}${delta.delta}',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                            color: delta.inDebt ? ObsTheme.critical : ObsTheme.safeOf(context),
                          ),
                        ),
                        Text(
                          'RESILIENCE DELTA',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: ObsTheme.textSecondaryOf(context),
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Two-score breakdown
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'ROOTLY OCH',
                    value: '${och.score}',
                    subtitle: 'External Load',
                    color: ObsTheme.tierColor(och.score),
                    trend: '${och.trend > 0 ? "+" : ""}${och.trend}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: 'SLEEP RISK',
                    value: '${delta.sleepRisk}',
                    subtitle: 'Recovery Deficit',
                    color: ObsTheme.tierColor(delta.sleepRisk),
                    trend: null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Shift stats row
            Row(
              children: [
                _MiniStat(label: 'INCIDENTS', value: '${shift.incidentCount}'),
                _MiniStat(label: 'AFTER-HRS', value: '${shift.afterHoursPages}'),
                _MiniStat(label: 'ON-CALL HRS', value: shift.hoursOnCall.toStringAsFixed(0)),
                _MiniStat(label: 'AVG MTTR', value: '${shift.avgMttrMinutes.toStringAsFixed(0)}m'),
              ],
            ),
            const SizedBox(height: 20),

            // Sleep trend sparkline
            _SectionHeader(title: 'SLEEP RECOVERY TREND (7 DAY)'),
            const SizedBox(height: 8),
            Container(
              height: 80,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ObsTheme.surfaceOf(context),
                border: Border.all(color: ObsTheme.borderOf(context)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: _SleepSparklinePainter(sleepHistory, safeColor: ObsTheme.safeOf(context)),
              ),
            ),
            const SizedBox(height: 20),

            // Telemetry insights
            _SectionHeader(title: 'TELEMETRY INSIGHTS'),
            const SizedBox(height: 8),
            ...delta.insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ObsTheme.surfaceOf(context),
                  border: Border.all(color: ObsTheme.borderOf(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('→ ', style: TextStyle(color: ObsTheme.info, fontFamily: 'Courier')),
                    Expanded(
                      child: Text(
                        insight,
                        style: TextStyle(
                          fontSize: 12,
                          color: ObsTheme.textSecondaryOf(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 20),

            // Risk factors from Rootly
            _SectionHeader(title: 'OCH RISK FACTORS'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: och.riskFactors.map((f) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ObsTheme.surfaceLightOf(context),
                  border: Border.all(color: ObsTheme.borderOf(context)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontSize: 11,
                    color: ObsTheme.textSecondaryOf(context),
                    fontFamily: 'Courier',
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),

            // Quick nav
            Row(
              children: [
                Expanded(
                  child: _NavButton(
                    icon: Icons.timeline,
                    label: 'INCIDENT TIMELINE',
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const IncidentTimeline())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NavButton(
                    icon: Icons.shield_outlined,
                    label: 'CIRCUIT BREAKER',
                    color: delta.compositeScore >= 50 ? ObsTheme.critical : null,
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CircuitBreaker())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: ObsTheme.textMutedOf(context),
        fontFamily: 'Courier',
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final String? trend;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ObsTheme.surfaceOf(context),
        border: Border.all(color: ObsTheme.borderOf(context)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1,
              color: ObsTheme.textMutedOf(context),
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                  color: color,
                ),
              ),
              if (trend != null) ...[
                const SizedBox(width: 8),
                Text(
                  trend!,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Courier',
                    color: trend!.startsWith('-') ? ObsTheme.critical : ObsTheme.safeOf(context),
                  ),
                ),
              ],
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: ObsTheme.textSecondaryOf(context)),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: ObsTheme.surfaceOf(context),
          border: Border.all(color: ObsTheme.borderOf(context)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier',
                color: ObsTheme.textPrimaryOf(context),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                letterSpacing: 1,
                fontFamily: 'Courier',
                color: ObsTheme.textMutedOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? ObsTheme.info;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.08),
          border: Border.all(color: c.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: c, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                fontFamily: 'Courier',
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResilienceGaugePainter extends CustomPainter {
  final int compositeScore;
  final int ochScore;
  final int sleepRisk;
  final Color borderColor;

  _ResilienceGaugePainter({
    required this.compositeScore,
    required this.ochScore,
    required this.sleepRisk,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    // Background ring
    final bgPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75,
      pi * 1.5,
      false,
      bgPaint,
    );

    // Score arc
    final scoreColor = ObsTheme.tierColor(compositeScore);
    final scorePaint = Paint()
      ..color = scoreColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final sweepAngle = (compositeScore / 100) * pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75,
      sweepAngle,
      false,
      scorePaint,
    );

    // Glow effect
    final glowPaint = Paint()
      ..color = scoreColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75,
      sweepAngle,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SleepSparklinePainter extends CustomPainter {
  final List<SleepMetrics> data;
  final Color safeColor;
  _SleepSparklinePainter(this.data, {required this.safeColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxEff = 100.0;
    final minEff = 40.0;
    final range = maxEff - minEff;

    // Threshold line at 85%
    final thresholdY = size.height - ((85 - minEff) / range) * size.height;
    final thresholdPaint = Paint()
      ..color = ObsTheme.warning.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, thresholdY),
      Offset(size.width, thresholdY),
      thresholdPaint,
    );

    // Data line
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i].sleepEfficiency - minEff) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [safeColor.withValues(alpha: 0.15), safeColor.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = safeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Dots
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i].sleepEfficiency - minEff) / range) * size.height;
      final dotColor = data[i].sleepEfficiency < 85 ? ObsTheme.critical : safeColor;
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = dotColor);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
