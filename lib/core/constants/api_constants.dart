class ApiConstants {
  ApiConstants._();

  // Live Railway Production Backend URL
  static const String baseUrl = 'https://pgfinder-production-8381.up.railway.app/api/v1';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String myProfile = '/users/me';
  static const String uploadKyc = '/kyc/upload';

  // Discovery & Properties
  static const String propertySearch = '/properties/search';
  static const String propertyDetails = '/properties';
  static const String amenities = '/amenities';

  // Bookings & Payments
  static const String initiateBooking = '/bookings/initiate';
  static const String myBookings = '/bookings/my-bookings';
  static const String bookingDetails = '/bookings';
  static const String verifyPayment = '/payments/verify';

  // Invoices & Complaints
  static const String myInvoices = '/invoices/my-invoices';
  static const String initiateInvoicePayment = '/invoices';
  static const String complaints = '/complaints';
  static const String myComplaints = '/complaints/my-complaints';
}
