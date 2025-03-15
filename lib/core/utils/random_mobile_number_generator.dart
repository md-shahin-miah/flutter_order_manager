import 'dart:math';

class RandomMobileNumberGenerator {
  static String generateMobileNumber({String countryCode = '1', int length = 10}) {
    final random = Random();
    String number = countryCode;

    // Ensure the length is valid.
    if (length < 1) {
      return ''; // Or throw an exception
    }
    //Ensure the length of the generated number does not exceed the provided length.
    for (int i = 0; i < length - countryCode.length; i++) {
      number += random.nextInt(10).toString();
    }

    return number;
  }


  static String generateUKMobileNumber() {
    // UK mobile numbers typically follow the format +44-XXXXXXXXX
    return generateMobileNumber(countryCode: '44', length: 10);
  }
}