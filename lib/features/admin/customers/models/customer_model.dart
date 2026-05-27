class UserModel {
  final int id;
  final String username;
  final String password;
  final String role;
  final String ownerToken;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.ownerToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? 0,
        username: json['username'] ?? '',
        password: json['password'] ?? '',
        role: json['role'] ?? '',
        ownerToken: json['owner_token'] ?? '',
        createdAt: json['createdAt'] ?? '',
        updatedAt: json['updatedAt'] ?? '',
      );
}

class ServiceNestedModel {
  final int id;
  final String name;
  final int minUsage;
  final int maxUsage;
  final int price;
  final String ownerToken;
  final String createdAt;
  final String updatedAt;

  ServiceNestedModel({
    required this.id,
    required this.name,
    required this.minUsage,
    required this.maxUsage,
    required this.price,
    required this.ownerToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceNestedModel.fromJson(Map<String, dynamic> json) =>
      ServiceNestedModel(
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

class CustomerModel {
  final int id;
  final int userId;
  final String customerNumber;
  final String name;
  final String phone;
  final String address;
  final int serviceId;
  final String ownerToken;
  final String createdAt;
  final String updatedAt;
  final UserModel? user;
  final ServiceNestedModel? service;

  CustomerModel({
    required this.id,
    required this.userId,
    required this.customerNumber,
    required this.name,
    required this.phone,
    required this.address,
    required this.serviceId,
    required this.ownerToken,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.service,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] ?? 0,
        userId: json['user_id'] ?? 0,
        customerNumber: json['customer_number'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        address: json['address'] ?? '',
        serviceId: json['service_id'] ?? 0,
        ownerToken: json['owner_token'] ?? '',
        createdAt: json['createdAt'] ?? '',
        updatedAt: json['updatedAt'] ?? '',
        user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
        service: json['service'] != null
            ? ServiceNestedModel.fromJson(json['service'])
            : null,
      );
}