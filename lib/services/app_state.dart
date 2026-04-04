import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/mood_entry.dart';
import '../models/journal_entry.dart';

class AppState extends ChangeNotifier {
  String? userName;
  bool onboardingComplete = false;
  List<String> selectedConcerns = [];

  // Theme
  ThemeMode themeMode = ThemeMode.light; // default light with brand colors
  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme() {
    themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  // Mood
  final List<MoodEntry> moodEntries = [];

  // Journal
  final List<JournalEntry> journalEntries = [];

  // Streaks
  int currentStreak = 0;
  int longestStreak = 0;
  int exercisesCompleted = 0;

  // Breathing
  int breathingSessionsCompleted = 0;

  void completeOnboarding(String name, List<String> concerns) {
    userName = name;
    selectedConcerns = concerns;
    onboardingComplete = true;
    notifyListeners();
  }

  void addMoodEntry(int mood, int energy, int sleep, int anxiety, {String? note}) {
    final entry = MoodEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      mood: mood,
      energy: energy,
      sleep: sleep,
      anxiety: anxiety,
      note: note,
    );
    moodEntries.add(entry);
    _updateStreak();
    notifyListeners();
  }

  void addJournalEntry(JournalEntry entry) {
    journalEntries.add(entry);
    exercisesCompleted++;
    _updateStreak();
    notifyListeners();
  }

  void completeBreathingSession() {
    breathingSessionsCompleted++;
    exercisesCompleted++;
    _updateStreak();
    notifyListeners();
  }

  void _updateStreak() {
    // Simple streak: consecutive days with any activity
    if (moodEntries.isEmpty && journalEntries.isEmpty) return;

    final today = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final hasActivity = moodEntries.any((e) =>
        e.date.year == checkDate.year &&
        e.date.month == checkDate.month &&
        e.date.day == checkDate.day
      ) || journalEntries.any((e) =>
        e.date.year == checkDate.year &&
        e.date.month == checkDate.month &&
        e.date.day == checkDate.day
      );

      if (hasActivity) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    currentStreak = streak;
    if (streak > longestStreak) longestStreak = streak;
  }

  List<MoodEntry> get recentMoods {
    final sorted = List<MoodEntry>.from(moodEntries)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(7).toList();
  }

  double? get averageMoodThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final thisWeek = moodEntries.where((e) => e.date.isAfter(weekAgo));
    if (thisWeek.isEmpty) return null;
    return thisWeek.map((e) => e.mood).reduce((a, b) => a + b) / thisWeek.length;
  }
}
