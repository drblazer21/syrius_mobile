import 'package:web3dart/web3dart.dart';

extension IsContractInteraction on Transaction {
  bool get isContractInteraction => data != null;
}
