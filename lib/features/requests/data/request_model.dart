class RequestModel {
  RequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.providerId,
    this.budget,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) => RequestModel(
    id: json['id']?.toString() ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    userId: json['user_id'] as String? ?? '',
    providerId: json['provider_id'].toString(),
    status: json['status'].toString(),
    createdAt: DateTime.parse(
      (json['created_at'] as String?) ?? DateTime.now().toIso8601String(),
    ),
    budget: json['budget'] != null
        ? int.tryParse(json['budget'].toString())
        : null,
  );
  final String id;
  final String title;
  final String description;
  final String userId;
  final String? providerId;
  final String status;
  final DateTime createdAt;
  final int? budget;

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
