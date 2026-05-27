class ServiceModel {
  final int id;
  final String name;
  final int minUsage;
  final int maxUsage;
  final int price;
  final String ownerToken;
  final String createdAt;
  final String updatedAt;

  ServiceModel({
    required this.id,
    required this.name,
    required this.minUsage,
    required this.maxUsage,
    required this.price,
    required this.ownerToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      minUsage: json['min_usage'] ?? 0,
      maxUsage: json['max_usage'] ?? 0,
      price: json['price'] ?? 0,
      ownerToken: json['owner_token'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'min_usage': minUsage.toString(),
        'max_usage': maxUsage.toString(),
        'price': price.toString(),
      };
}