class LocalityChildService {
  final String id;
  final String title;
  final String? image;
  final String actionType;
  final String? actionTarget;
  final Map<String, dynamic> actionConfig;
  final String actionVariant;

  const LocalityChildService({
    required this.id,
    required this.title,
    this.image,
    required this.actionType,
    this.actionTarget,
    required this.actionConfig,
    this.actionVariant = 'list',
  });

  factory LocalityChildService.fromJson(Map<String, dynamic> json) {
    final action = json['action'] as Map<String, dynamic>?;
    return LocalityChildService(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString(),
      actionType: action?['type']?.toString() ?? '',
      actionTarget: action?['target']?.toString(),
      actionConfig: action?['config'] as Map<String, dynamic>? ?? {},
      actionVariant: action?['variant']?.toString() ?? 'list',
    );
  }
}
