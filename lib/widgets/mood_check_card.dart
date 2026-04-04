import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class MoodCheckCard extends StatefulWidget {
  const MoodCheckCard({super.key});

  @override
  State<MoodCheckCard> createState() => _MoodCheckCardState();
}

class _MoodCheckCardState extends State<MoodCheckCard> {
  int? _selectedMood;
  int _energy = 3;
  int _sleep = 7;
  int _anxiety = 3;
  bool _expanded = false;

  static const _moods = [
    {'emoji': '😞', 'label': 'Awful'},
    {'emoji': '😔', 'label': 'Bad'},
    {'emoji': '😐', 'label': 'Okay'},
    {'emoji': '🙂', 'label': 'Good'},
    {'emoji': '😊', 'label': 'Great'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Mood selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (i) {
              final isSelected = _selectedMood == i + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = i + 1;
                    _expanded = true;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _moods[i]['emoji']!,
                        style: TextStyle(fontSize: isSelected ? 32 : 28),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _moods[i]['label']!,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          // Expanded details
          if (_expanded && _selectedMood != null) ...[
            const SizedBox(height: 20),
            _SliderRow(
              label: 'Energy',
              icon: Icons.bolt_rounded,
              value: _energy,
              min: 1,
              max: 5,
              onChanged: (v) => setState(() => _energy = v),
            ),
            const SizedBox(height: 12),
            _SliderRow(
              label: 'Sleep (hours)',
              icon: Icons.nightlight_round,
              value: _sleep,
              min: 0,
              max: 12,
              onChanged: (v) => setState(() => _sleep = v),
            ),
            const SizedBox(height: 12),
            _SliderRow(
              label: 'Anxiety',
              icon: Icons.waves_rounded,
              value: _anxiety,
              min: 1,
              max: 5,
              onChanged: (v) => setState(() => _anxiety = v),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<AppState>().addMoodEntry(
                        _selectedMood!,
                        _energy,
                        _sleep,
                        _anxiety,
                      );
                  setState(() {
                    _selectedMood = null;
                    _expanded = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mood logged!'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Log Mood'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _SliderRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            activeColor: AppTheme.primary,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(
          width: 24,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
