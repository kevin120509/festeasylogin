class RequestModel {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String? providerId;
  final String status;
  final DateTime createdAt;
  final int? budget;

  RequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    this.providerId,
    required this.status,
    required this.createdAt,
    this.budget,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) => RequestModel(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        userId: json['user_id'] ?? '',
        providerId: json['provider_id'],
        status: json['status'] ?? 'open',
        createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
        budget: json['budget'] != null ? int.tryParse(json['budget'].toString()) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'user_id': userId,
        'provider_id': providerId,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'budget': budget,
      };
}