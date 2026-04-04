class JournalEntry {
  final String id;
  final DateTime date;
  final String situation;
  final String automaticThought;
  final String cognitiveDistortion;
  final String balancedThought;
  final int distressBefore; // 1-10
  final int distressAfter;  // 1-10

  JournalEntry({
    required this.id,
    required this.date,
    required this.situation,
    required this.automaticThought,
    required this.cognitiveDistortion,
    required this.balancedThought,
    required this.distressBefore,
    required this.distressAfter,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'situation': situation,
    'automaticThought': automaticThought,
    'cognitiveDistortion': cognitiveDistortion,
    'balancedThought': balancedThought,
    'distressBefore': distressBefore,
    'distressAfter': distressAfter,
  };

  factory JournalEntry.fromMap(Map<String, dynamic> map) => JournalEntry(
    id: map['id'],
    date: DateTime.parse(map['date']),
    situation: map['situation'],
    automaticThought: map['automaticThought'],
    cognitiveDistortion: map['cognitiveDistortion'],
    balancedThought: map['balancedThought'],
    distressBefore: map['distressBefore'],
    distressAfter: map['distressAfter'],
  );
}

class CognitiveDistortion {
  final String id;
  final String name;
  final String description;
  final String example;

  const CognitiveDistortion({
    required this.id,
    required this.name,
    required this.description,
    required this.example,
  });

  static const List<CognitiveDistortion> all = [
    CognitiveDistortion(
      id: 'all_or_nothing',
      name: 'All-or-Nothing Thinking',
      description: 'Seeing things in black and white. If it\'s not perfect, it\'s a total failure.',
      example: '"I didn\'t finish the whole assignment, so I\'m a complete failure."',
    ),
    CognitiveDistortion(
      id: 'catastrophizing',
      name: 'Catastrophizing',
      description: 'Expecting the worst possible outcome.',
      example: '"I made a mistake at work. I\'m going to get fired."',
    ),
    CognitiveDistortion(
      id: 'mind_reading',
      name: 'Mind Reading',
      description: 'Assuming you know what others are thinking.',
      example: '"They didn\'t text back. They must hate me."',
    ),
    CognitiveDistortion(
      id: 'overgeneralization',
      name: 'Overgeneralization',
      description: 'Drawing broad conclusions from a single event.',
      example: '"I failed this exam. I always fail everything."',
    ),
    CognitiveDistortion(
      id: 'mental_filter',
      name: 'Mental Filter',
      description: 'Focusing only on the negative and ignoring positives.',
      example: '"I got great feedback but one small critique — the whole thing was bad."',
    ),
    CognitiveDistortion(
      id: 'should_statements',
      name: 'Should Statements',
      description: 'Rigid rules about how you or others should behave.',
      example: '"I should be able to handle this without help."',
    ),
    CognitiveDistortion(
      id: 'emotional_reasoning',
      name: 'Emotional Reasoning',
      description: 'Believing something is true because it feels true.',
      example: '"I feel like a burden, so I must be one."',
    ),
    CognitiveDistortion(
      id: 'personalization',
      name: 'Personalization',
      description: 'Blaming yourself for things outside your control.',
      example: '"My friend is upset. It must be something I did."',
    ),
  ];
}
