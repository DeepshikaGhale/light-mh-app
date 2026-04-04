import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/journal_entry.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  int _step = 0;
  final _situationController = TextEditingController();
  final _thoughtController = TextEditingController();
  final _balancedController = TextEditingController();
  String? _selectedDistortion;
  int _distressBefore = 5;
  int _distressAfter = 5;

  final _steps = [
    'What happened?',
    'What went through your mind?',
    'Rate your distress',
    'Identify the pattern',
    'Find a balanced thought',
    'How do you feel now?',
  ];

  final _stepDescriptions = [
    'Describe the situation briefly. What triggered your thoughts?',
    'What automatic thought popped into your head?',
    'How distressed did you feel? (1 = barely, 10 = extremely)',
    'Which thinking pattern might be at play?',
    'What would you tell a friend in this situation?',
    'Rate your distress now after reframing.',
  ];

  @override
  void dispose() {
    _situationController.dispose();
    _thoughtController.dispose();
    _balancedController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    switch (_step) {
      case 0: return _situationController.text.trim().isNotEmpty;
      case 1: return _thoughtController.text.trim().isNotEmpty;
      case 2: return true;
      case 3: return _selectedDistortion != null;
      case 4: return _balancedController.text.trim().isNotEmpty;
      case 5: return true;
      default: return false;
    }
  }

  void _next() {
    if (_step < 5) {
      setState(() => _step++);
    } else {
      _save();
    }
  }

  void _save() {
    final entry = JournalEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      situation: _situationController.text.trim(),
      automaticThought: _thoughtController.text.trim(),
      cognitiveDistortion: _selectedDistortion ?? '',
      balancedThought: _balancedController.text.trim(),
      distressBefore: _distressBefore,
      distressAfter: _distressAfter,
    );

    context.read<AppState>().addJournalEntry(entry);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Well done!'),
        content: Text(
          _distressAfter < _distressBefore
              ? 'Your distress went from $_distressBefore to $_distressAfter. '
                'Reframing your thoughts made a difference!'
              : "It's okay if you don't feel better right away. "
                'The practice of noticing thought patterns builds resilience over time.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog
              if (Navigator.canPop(context)) {
                Navigator.pop(context); // screen
              }
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thought Journal'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              Row(
                children: List.generate(6, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i <= _step
                            ? AppTheme.primary
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              Text(
                _steps[_step],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _stepDescriptions[_step],
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildStepContent()),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: _step > 0 ? 2 : 1,
                    child: ElevatedButton(
                      onPressed: _canProceed ? _next : null,
                      child: Text(_step == 5 ? 'Save Entry' : 'Continue'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return TextField(
          controller: _situationController,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'e.g., "My friend cancelled plans last minute..."',
          ),
          onChanged: (_) => setState(() {}),
        );
      case 1:
        return TextField(
          controller: _thoughtController,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'e.g., "They don\'t actually want to hang out with me..."',
          ),
          onChanged: (_) => setState(() {}),
        );
      case 2:
        return _DistressSlider(
          value: _distressBefore,
          onChanged: (v) => setState(() => _distressBefore = v),
        );
      case 3:
        return ListView.builder(
          itemCount: CognitiveDistortion.all.length,
          itemBuilder: (context, index) {
            final d = CognitiveDistortion.all[index];
            final isSelected = _selectedDistortion == d.name;
            return GestureDetector(
              onTap: () => setState(() => _selectedDistortion = d.name),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      case 4:
        return TextField(
          controller: _balancedController,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'e.g., "Plans change sometimes - it doesn\'t mean they don\'t care..."',
          ),
          onChanged: (_) => setState(() {}),
        );
      case 5:
        return _DistressSlider(
          value: _distressAfter,
          onChanged: (v) => setState(() => _distressAfter = v),
        );
      default:
        return const SizedBox();
    }
  }
}

class _DistressSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _DistressSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _label(value),
          style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 32),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: _color(value),
          onChanged: (v) => onChanged(v.round()),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Barely', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              Text('Extremely', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  String _label(int v) {
    if (v <= 2) return 'Minimal distress';
    if (v <= 4) return 'Mild distress';
    if (v <= 6) return 'Moderate distress';
    if (v <= 8) return 'High distress';
    return 'Severe distress';
  }

  Color _color(int v) {
    if (v <= 3) return AppTheme.success;
    if (v <= 6) return AppTheme.secondary;
    return AppTheme.error;
  }
}
