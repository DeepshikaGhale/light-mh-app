import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';

class BreatheScreen extends StatefulWidget {
  const BreatheScreen({super.key});

  @override
  State<BreatheScreen> createState() => _BreatheScreenState();
}

class _BreatheScreenState extends State<BreatheScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRunning = false;
  int _cyclesCompleted = 0;
  static const _totalCycles = 5;
  String _phase = 'Tap to start';
  Timer? _phaseTimer;
  int _phaseSeconds = 0;

  // 4-7-8 breathing pattern
  static const _inhale = 4;
  static const _hold = 7;
  static const _exhale = 8;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _inhale + _hold + _exhale),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _phaseTimer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _isRunning = true;
      _cyclesCompleted = 0;
    });
    _runCycle();
  }

  void _runCycle() {
    if (_cyclesCompleted >= _totalCycles) {
      _complete();
      return;
    }

    _controller.forward(from: 0).then((_) {
      if (!mounted || !_isRunning) return;
      setState(() => _cyclesCompleted++);
      _runCycle();
    });

    // Phase tracking
    _startPhaseTracking();
  }

  void _startPhaseTracking() {
    _phaseTimer?.cancel();
    _phaseSeconds = 0;
    _setPhase('Breathe in', _inhale);

    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isRunning) {
        timer.cancel();
        return;
      }
      _phaseSeconds++;
      if (_phaseSeconds == _inhale) {
        _setPhase('Hold', _hold);
      } else if (_phaseSeconds == _inhale + _hold) {
        _setPhase('Breathe out', _exhale);
      }
    });
  }

  void _setPhase(String phase, int duration) {
    setState(() => _phase = '$phase ($duration s)');
  }

  void _complete() {
    _phaseTimer?.cancel();
    context.read<AppState>().completeBreathingSession();
    setState(() {
      _isRunning = false;
      _phase = 'Session complete';
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Great job!'),
        content: const Text(
          'You completed a 4-7-8 breathing session. '
          'Regular breathing exercises help reduce anxiety '
          'and improve sleep quality.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _phase = 'Tap to start');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _stop() {
    _controller.stop();
    _phaseTimer?.cancel();
    setState(() {
      _isRunning = false;
      _phase = 'Tap to start';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breathe')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              '4-7-8 Breathing',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inhale 4s - Hold 7s - Exhale 8s',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const Spacer(),
            // Breathing circle
            GestureDetector(
              onTap: _isRunning ? _stop : _start,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final totalDuration = _inhale + _hold + _exhale;
                  final progress = _controller.value * totalDuration;
                  double scale;

                  if (progress < _inhale) {
                    // Inhale: grow from 0.6 to 1.0
                    scale = 0.6 + (progress / _inhale) * 0.4;
                  } else if (progress < _inhale + _hold) {
                    // Hold: stay at 1.0
                    scale = 1.0;
                  } else {
                    // Exhale: shrink from 1.0 to 0.6
                    final exhaleProgress =
                        (progress - _inhale - _hold) / _exhale;
                    scale = 1.0 - exhaleProgress * 0.4;
                  }

                  return SizedBox(
                    width: 250,
                    height: 250,
                    child: CustomPaint(
                      painter: _BreathCirclePainter(
                        scale: scale,
                        progress: _controller.value,
                        isRunning: _isRunning,
                      ),
                      child: Center(
                        child: Text(
                          _phase,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            // Cycle counter
            if (_isRunning || _cyclesCompleted > 0)
              Text(
                'Cycle $_cyclesCompleted / $_totalCycles',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _isRunning
                    ? 'Tap the circle to stop'
                    : 'Tap the circle to begin',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreathCirclePainter extends CustomPainter {
  final double scale;
  final double progress;
  final bool isRunning;

  _BreathCirclePainter({
    required this.scale,
    required this.progress,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final radius = maxRadius * scale;

    // Outer glow
    final glowPaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius, glowPaint);

    // Main circle
    final circlePaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    // Border
    final borderPaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);

    // Progress arc
    if (isRunning) {
      final arcPaint = Paint()
        ..color = AppTheme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: maxRadius + 8),
        -pi / 2,
        2 * pi * progress,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BreathCirclePainter old) =>
      scale != old.scale || progress != old.progress;
}
