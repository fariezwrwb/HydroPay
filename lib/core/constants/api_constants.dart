class ApiConstants {
  static const String baseUrl = 'https://learn.smktelkom-mlg.sch.id/pdam';


  static const String register = '/admins';
  static const String login = '/auth';


  static const String adminMe = '/admins/me';
  static const String customerMe = '/customers/me';


  static const String services = '/services';

  
  static const String customers = '/customers';

  
  static const String bills = '/bills';
  static const String myBills = '/bills/me';

  
  static const String payments = '/payments';
  static const String myPayments = '/payments/me';
  static String paymentProof(String fileName) => '/payment-proof/$fileName';
}