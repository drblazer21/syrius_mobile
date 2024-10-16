// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_network_asset_entries.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNetworkAssetEntries _$AppNetworkAssetEntriesFromJson(
        Map<String, dynamic> json) =>
    AppNetworkAssetEntries(
      items: (json['items'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$AppNetworkAssetEntriesToJson(
        AppNetworkAssetEntries instance) =>
    <String, dynamic>{
      'items': instance.items,
    };
