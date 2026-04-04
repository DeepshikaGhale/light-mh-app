class MoodEntry {
  final String id;
  final DateTime date;
  final int mood;       // 1-5 (1=awful, 5=great)
  final int energy;     // 1-5
  final int sleep;      // hours
  final int anxiety;    // 1-5
  final String? note;

  MoodEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.energy,
    required this.sleep,
    required this.anxiety,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'mood': mood,
    'energy': energy,
    'sleep': sleep,
    'anxiety': anxiety,
    'note': note,
  };

  factory MoodEntry.fromMap(Map<String, dynamic> map) => MoodEntry(
    id: map['id'],
    date: DateTime.parse(map['date']),
    mood: map['mood'],
    energy: map['energy'],
    sleep: map['sleep'],
    anxiety: map['anxiety'],
    note: map['note'],
  );

  String get moodEmoji {
    switch (mood) {
      case 1: return '😞';
      case 2: return '😔';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '😊';
      default: return '😐';
    }
  }

  String get moodLabel {
    switch (mood) {
      case 1: return 'Awful';
      case 2: return 'Bad';
      case 3: return 'Okay';
      case 4: return 'Good';
      case 5: return 'Great';
      default: return 'Okay';
    }
  }
}
