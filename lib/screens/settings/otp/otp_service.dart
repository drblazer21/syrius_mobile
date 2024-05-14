import 'package:otp/otp.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:znn_sdk_dart/znn_sdk_dart.dart';

const Algorithm _kOtpAlgorithm = Algorithm.SHA256;
const int _kOtpDigits = 6;
const int _kOtpRefreshIntervalInSeconds = 30;

class OTPService {
  String generateGoogleAuthenticatorUri({
    required String secretKey,
  }) {
    final String accountName =
        Address.parse(kDefaultAddressList.first).toShortString();

    const String issuer = 'syrius-mobile';

    return 'otpauth://totp/$issuer@$accountName?secret=$secretKey&issuer='
        '$issuer&algorithm=${_kOtpAlgorithm.name}&digits=$_kOtpDigits&period='
        '$_kOtpRefreshIntervalInSeconds';
  }

  String generateOtpCode({
    required String secretKey,
  }) {
    final DateTime now = DateTime.now();

    return OTP.generateTOTPCodeString(
      secretKey,
      now.millisecondsSinceEpoch,
      // ignore: avoid_redundant_argument_values
      interval: _kOtpRefreshIntervalInSeconds,
      isGoogle: true,
      // ignore: avoid_redundant_argument_values
      length: _kOtpDigits,
      // ignore: avoid_redundant_argument_values
      algorithm: _kOtpAlgorithm,
    );
  }

  String generateSecretKey() => OTP.randomSecret();

  bool validateCode({
    required String userCode,
    required String secretKey,
  }) {
    final String expectedCode = generateOtpCode(secretKey: secretKey);

    final bool isCodeValid = OTP.constantTimeVerification(
      expectedCode,
      userCode,
    );

    return isCodeValid;
  }
}
