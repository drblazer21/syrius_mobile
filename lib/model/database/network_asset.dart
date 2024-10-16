// import 'package:isar/isar.dart';
//
// part 'network_asset.g.dart';
//
// // A generic class to define both currencies and tokens on an EVM, for example
//
// @collection
// class NetworkAsset {
//   Id? id;
//   String? contractAddressHex;
//   final int decimals;
//   String? logoUrl;
//   final String? name;
//   final String symbol;
//
//   bool get isCurrency => contractAddressHex == null;
//
//   NetworkAsset({
//     required this.decimals,
//     required this.symbol,
//     this.contractAddressHex,
//     this.id,
//     this.logoUrl,
//     this.name,
//   });
//
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     if (runtimeType != other.runtimeType) return false;
//     return other is NetworkAsset &&
//         contractAddressHex?.toLowerCase() ==
//             other.contractAddressHex?.toLowerCase();
//   }
//
//   @override
//   int get hashCode => contractAddressHex.hashCode;
//
//   @override
//   String toString() => 'NetworkAsset(contractAddressHex: $contractAddressHex, '
//       'decimals: $decimals, logUrl: $logoUrl, name: $name, symbol: $symbol)';
// }
