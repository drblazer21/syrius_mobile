enum Eip155SupportedMethods {
  ethSign,
  ethSignTransaction,
  ethSignTypedData,
  ethSignTypedDataV4,
  switchChain,
  personalSign,
  ethSendTransaction;

  String get name {
    switch (this) {
      case ethSign:
        return 'eth_sign';
      case ethSignTransaction:
        return 'eth_signTransaction';
      case ethSignTypedData:
        return 'eth_signTypedData';
      case ethSignTypedDataV4:
        return 'eth_signTypedData_v4';
      case switchChain:
        return 'wallet_switchEthereumChain';
      case personalSign:
        return 'personal_sign';
      case ethSendTransaction:
        return 'eth_sendTransaction';
    }
  }
}
