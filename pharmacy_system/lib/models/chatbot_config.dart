class ChatBotConfig {
  final bool isEnabled;
  final String welcomeMessage;

  ChatBotConfig({
    required this.isEnabled,
    required this.welcomeMessage,
  });

  factory ChatBotConfig.fromMap(Map<String, dynamic> map) {
    return ChatBotConfig(
      isEnabled: map['isEnabled'] ?? true,
      welcomeMessage: map['welcomeMessage'] ?? "Hi! I’m your pharmacist assistant 💊.",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'welcomeMessage': welcomeMessage,
    };
  }
}
