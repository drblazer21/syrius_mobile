import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:syrius_mobile/database/export.dart';

part 'app_network_asset_entries.g.dart';

typedef AppNetworkWithAssets = ({
  List<NetworkAsset> assets,
  AppNetwork network,
});

@JsonSerializable()
class AppNetworkAssetEntries {
  final List<int> items;

  AppNetworkAssetEntries({required this.items});

  factory AppNetworkAssetEntries.fromJson(Map<String, Object?> json) =>
      _$AppNetworkAssetEntriesFromJson(json);

  Map<String, Object?> toJson() {
    return _$AppNetworkAssetEntriesToJson(this);
  }

  static JsonTypeConverter<AppNetworkAssetEntries, String> converter =
      TypeConverter.json(
    fromJson: (json) =>
        AppNetworkAssetEntries.fromJson(json as Map<String, Object?>),
    toJson: (entries) => entries.toJson(),
  );
}
