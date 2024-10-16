enum NomSupportedMethods {
  info,
  send,
  sign;

  String get name {
    switch (this) {
      case NomSupportedMethods.info:
        return 'znn_info';
      case NomSupportedMethods.send:
        return 'znn_send';
      case NomSupportedMethods.sign:
        return 'znn_sign';
    }
  }
}
