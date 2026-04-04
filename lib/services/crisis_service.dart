/// Crisis detection service for Light.
/// Monitors user input for crisis keywords and provides
/// appropriate resources. Everything runs locally.
class CrisisService {
  static const _crisisKeywords = [
    'suicide',
    'suicidal',
    'kill myself',
    'end my life',
    'want to die',
    'self harm',
    'self-harm',
    'cutting myself',
    'hurt myself',
    'no reason to live',
    'better off dead',
  ];

  /// Returns true if the text contains crisis-related language.
  static bool containsCrisisLanguage(String text) {
    final lower = text.toLowerCase();
    return _crisisKeywords.any((kw) => lower.contains(kw));
  }

  /// Returns a crisis response message with resources.
  static String get crisisResponse =>
      "I'm concerned about what you've shared. You matter, and help is available right now.\n\n"
      "**Crisis Resources:**\n"
      "988 Suicide & Crisis Lifeline: Call or text **988**\n"
      "Crisis Text Line: Text **HOME** to **741741**\n"
      "International: findahelpline.com\n\n"
      "If you're in immediate danger, please call **911** or your local emergency number.\n\n"
      "I'm an AI and can't provide emergency support, but trained counselors at these numbers can help 24/7.";

  /// Resources list for display in a dedicated screen.
  static const resources = [
    CrisisResource(
      name: '988 Suicide & Crisis Lifeline',
      action: 'Call or text 988',
      description: '24/7 free and confidential support',
    ),
    CrisisResource(
      name: 'Crisis Text Line',
      action: 'Text HOME to 741741',
      description: 'Free crisis counseling via text',
    ),
    CrisisResource(
      name: 'International Association for Suicide Prevention',
      action: 'findahelpline.com',
      description: 'Find a helpline in your country',
    ),
    CrisisResource(
      name: 'Emergency Services',
      action: 'Call 911',
      description: 'For immediate danger',
    ),
  ];
}

class CrisisResource {
  final String name;
  final String action;
  final String description;

  const CrisisResource({
    required this.name,
    required this.action,
    required this.description,
  });
}
