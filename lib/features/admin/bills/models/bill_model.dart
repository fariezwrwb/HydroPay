import 'package:aya_ikbal/features/admin/customers/models/customer_model.dart';
import 'package:aya_ikbal/features/admin/services/models/service_model.dart';

class PaymentModel {
  final int id;
  final int billId;
  final DateTime paymentDate;
  final bool verified;
  final int totalAmount;
  final String paymentProof;

  PaymentModel({
    required this.id,
    required this.billId,
    required this.paymentDate,
    required this.verified,
    required this.totalAmount,
    required this.paymentProof,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      billId: json['bill_id'],
      paymentDate: DateTime.parse(json['payment_date']),
      verified: json['verified'],
      totalAmount: json['total_amount'],
      paymentProof: json['payment_proof'],
    );
  }
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
  final DateTime createdAt;
  final DateTime updatedAt;
  
  final CustomerModel? customer;
  final ServiceModel? service;
  final PaymentModel? payments;

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
    this.customer,
    this.service,
    this.payments,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'],
      customerId: json['customer_id'],
      adminId: json['admin_id'],
      month: json['month'],
      year: json['year'],
      measurementNumber: json['measurement_number'],
      usageValue: json['usage_value'],
      price: json['price'],
      serviceId: json['service_id'],
      paid: json['paid'],
      ownerToken: json['owner_token'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      customer: json['customer'] != null 
          ? CustomerModel.fromJson(json['customer']) 
          : null,
      service: json['service'] != null 
          ? ServiceModel.fromJson(json['service']) 
          : null,
      payments: json['payments'] != null 
          ? PaymentModel.fromJson(json['payments']) 
          : null,
    );
  }

  String get periodLabel {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[month - 1]} $year';
  }

    bool get hasPendingPayment {
    return paid && payments != null && payments!.verified == false;
  }

  
  bool? get verifiedPayment => payments?.verified;
  
  
  bool get isUnpaid => !paid && payments == null;
}