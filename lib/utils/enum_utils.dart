import 'package:syrius_mobile/utils/utils.dart';

String extractNameFromEnum(dynamic enumValue) {
  final String valueName = enumValue.toString().split('.')[1];
  if (RegExp('^[a-z]+[A-Z]+').hasMatch(valueName)) {
    final List<String> parts = valueName
        .split(RegExp('(?<=[a-z])(?=[A-Z])'))
        .map((e) => e.toLowerCase())
        .toList();
    parts.first = parts.first.capitalize();
    return parts.join(' ');
  }
  return valueName.capitalize();
}
