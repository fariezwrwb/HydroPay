import '../../../admin/customers/models/customer_model.dart';

class AdminNestedModel {
  final int id;
  final int userId;
  final String name;
  final String phone;
  final String ownerToken;
  final String createdAt;
  final String updatedAt;

  AdminNestedModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.ownerToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminNestedModel.fromJson(Map<String, dynamic> json) =>
      AdminNestedModel(
        id: json['id'] ?? 0,
        userId: json['user_id'] ?? 0,
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        ownerToken: json['owner_token'] ?? '',
        createdAt: json['createdAt'] ?? '',
        updatedAt: json['updatedAt'] ?? '',
      );
}

class PaymentNestedModel {
  final int id;
  final int billId;
  final String paymentDate;
  final bool verified;
  final int totalAmount;
  final String paymentProof;
  final String ownerToken;
  final String createdAt;
  final String updatedAt;

  PaymentNestedModel({
    required this.id,
    required this.billId,
    required this.paymentDate,
    required this.verified,
    required this.totalAmount,
    required this.paymentProof,
    required this.ownerToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentNestedModel.fromJson(Map<String, dynamic> json) =>
      PaymentNestedModel(
        id: json['id'] ?? 0,
        billId: json['bill_id'] ?? 0,
        paymentDate: json['payment_date'] ?? '',
        verified: json['verified'] ?? false,
        totalAmount: json['total_amount'] ?? 0,
        paymentProof: json['payment_proof'] ?? '',
        ownerToken: json['owner_token'] ?? '',
        createdAt: json['createdAt'] ?? '',
        updatedAt: json['updatedAt'] ?? '',
      );
}

class BillModel {
  final int id;
  final int customerId;
  final int adminId;
  final int month;
  final int year;
  final String measurementNumber;
  final int usageValue;
  final int price;
  final int serviceId;
  final bool paid;
  final String ownerToken;
  final String createdAt;
  final String updatedAt;

  final ServiceNestedModel? service;
  final AdminNestedModel? admin;
  final CustomerModel? customer;
  final PaymentNestedModel? payments;
  final int? amount;
  final bool? verifiedPayment;

  BillModel({
    required this.id,
    required this.customerId,
    required this.adminId,
    required this.month,
    required this.year,
    required this.measurementNumber,
    required this.usageValue,
    required this.price,
    required this.serviceId,
    required this.paid,
    required this.ownerToken,
    required this.createdAt,
    required this.updatedAt,
    this.service,
    this.admin,
    this.customer,
    this.payments,
    this.amount,
    this.verifiedPayment,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) => BillModel(
        id: json['id'] ?? 0,
        customerId: json['customer_id'] ?? 0,
        adminId: json['admin_id'] ?? 0,
        month: json['month'] ?? 0,
        year: json['year'] ?? 0,
        measurementNumber: json['measurement_number'] ?? '',
        usageValue: json['usage_value'] ?? 0,
        price: json['price'] ?? 0,
        serviceId: json['service_id'] ?? 0,
        paid: json['paid'] ?? false,
        ownerToken: json['owner_token'] ?? '',
        createdAt: json['createdAt'] ?? '',
        updatedAt: json['updatedAt'] ?? '',
        service: json['service'] != null
            ? ServiceNestedModel.fromJson(json['service'])
            : null,
        admin: json['admin'] != null
            ? AdminNestedModel.fromJson(json['admin'])
            : null,
        customer: json['customer'] != null
            ? CustomerModel.fromJson(json['customer'])
            : null,
        payments: json['payments'] != null
            ? PaymentNestedModel.fromJson(json['payments'])
            : null,
        amount: json['amount'],
        verifiedPayment: json['verified_payment'],
      );
  String get monthName {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return month >= 1 && month <= 12 ? months[month] : '-';
  }

 
  String get periodLabel => '$monthName $year';

  
  bool get hasPendingPayment =>
      payments != null && !payments!.verified;
}