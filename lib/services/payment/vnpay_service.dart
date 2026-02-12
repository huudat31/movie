import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class VNPayService {
  // Sandbox info - Dùng demo
  static const String tmnCode =
      'TCB00011'; // Mã định danh merchant - Đây là mã test phổ biến
  static const String hashKey =
      'THSZZBEXCIBKHYXXTMLJYZYVZZYXGXXY'; // Chuỗi bí mật hash key test
  static const String vnpUrl =
      'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  static const String returnUrl =
      'http://localhost:8080/vnpay_return'; // Thường là một trang web handler

  String createPaymentUrl({
    required String orderId,
    required double amount,
    required String orderInfo,
    String? ipAddress,
  }) {
    final vnpParams = <String, String>{
      'vnp_Version': '2.1.0',
      'vnp_Command': 'pay',
      'vnp_TmnCode': tmnCode,
      'vnp_Amount': (amount * 100)
          .toInt()
          .toString(), // VNPay tính theo đơn vị VND * 100
      'vnp_CreateDate': DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
      'vnp_CurrCode': 'VND',
      'vnp_IpAddr': ipAddress ?? '127.0.0.1',
      'vnp_Locale': 'vn',
      'vnp_OrderInfo': orderInfo,
      'vnp_OrderType': 'topup',
      'vnp_ReturnUrl': returnUrl,
      'vnp_TxnRef': orderId,
    };

    // 1. Sort parameters by key
    final sortedKeys = vnpParams.keys.toList()..sort();

    // 2. Build query string for hashing and for final URL
    final hashDataBuffer = StringBuffer();
    final queryDataBuffer = StringBuffer();

    for (var i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final value = vnpParams[key]!;

      hashDataBuffer.write(Uri.encodeComponent(key));
      hashDataBuffer.write('=');
      hashDataBuffer.write(Uri.encodeComponent(value));

      queryDataBuffer.write(Uri.encodeFull(key));
      queryDataBuffer.write('=');
      queryDataBuffer.write(Uri.encodeFull(value));

      if (i < sortedKeys.length - 1) {
        hashDataBuffer.write('&');
        queryDataBuffer.write('&');
      }
    }

    // 3. Generate Secure Hash (HMAC-SHA512)
    final hmac = Hmac(sha512, utf8.encode(hashKey));
    final digest = hmac.convert(utf8.encode(hashDataBuffer.toString()));
    final secureHash = digest.toString();

    // 4. Return Final URL
    return '$vnpUrl?${queryDataBuffer.toString()}&vnp_SecureHash=$secureHash';
  }

  bool verifyHash(Map<String, String> params) {
    final vnpSecureHash = params['vnp_SecureHash'];
    if (vnpSecureHash == null) return false;

    // Remove hash from params to re-calculate
    final checkParams = Map<String, String>.from(params)
      ..remove('vnp_SecureHash')
      ..remove('vnp_SecureHashType');

    final sortedKeys = checkParams.keys.toList()..sort();
    final hashDataBuffer = StringBuffer();

    for (var i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final value = checkParams[key]!;
      hashDataBuffer.write(Uri.encodeComponent(key));
      hashDataBuffer.write('=');
      hashDataBuffer.write(Uri.encodeComponent(value));
      if (i < sortedKeys.length - 1) {
        hashDataBuffer.write('&');
      }
    }

    final hmac = Hmac(sha512, utf8.encode(hashKey));
    final digest = hmac.convert(utf8.encode(hashDataBuffer.toString()));

    return digest.toString().toLowerCase() == vnpSecureHash.toLowerCase();
  }
}
