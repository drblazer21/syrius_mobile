// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AppAddressesTable extends AppAddresses
    with TableInfo<$AppAddressesTable, AppAddress> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppAddressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _indexMeta = const VerificationMeta('index');
  @override
  late final GeneratedColumn<int> index = GeneratedColumn<int>(
      'index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _blockChainMeta =
      const VerificationMeta('blockChain');
  @override
  late final GeneratedColumnWithTypeConverter<BlockChain, int> blockChain =
      GeneratedColumn<int>('block_chain', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<BlockChain>($AppAddressesTable.$converterblockChain);
  static const VerificationMeta _hexMeta = const VerificationMeta('hex');
  @override
  late final GeneratedColumn<String> hex = GeneratedColumn<String>(
      'hex', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _bitcoinNetVersionMeta =
      const VerificationMeta('bitcoinNetVersion');
  @override
  late final GeneratedColumn<int> bitcoinNetVersion = GeneratedColumn<int>(
      'bitcoin_net_version', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, index, blockChain, hex, label, bitcoinNetVersion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_addresses';
  @override
  VerificationContext validateIntegrity(Insertable<AppAddress> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('index')) {
      context.handle(
          _indexMeta, index.isAcceptableOrUnknown(data['index']!, _indexMeta));
    } else if (isInserting) {
      context.missing(_indexMeta);
    }
    context.handle(_blockChainMeta, const VerificationResult.success());
    if (data.containsKey('hex')) {
      context.handle(
          _hexMeta, hex.isAcceptableOrUnknown(data['hex']!, _hexMeta));
    } else if (isInserting) {
      context.missing(_hexMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('bitcoin_net_version')) {
      context.handle(
          _bitcoinNetVersionMeta,
          bitcoinNetVersion.isAcceptableOrUnknown(
              data['bitcoin_net_version']!, _bitcoinNetVersionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppAddress map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppAddress(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      index: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}index'])!,
      blockChain: $AppAddressesTable.$converterblockChain.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}block_chain'])!),
      hex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hex'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      bitcoinNetVersion: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}bitcoin_net_version']),
    );
  }

  @override
  $AppAddressesTable createAlias(String alias) {
    return $AppAddressesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BlockChain, int, int> $converterblockChain =
      const EnumIndexConverter<BlockChain>(BlockChain.values);
}

class AppAddress extends DataClass implements Insertable<AppAddress> {
  final int id;
  final int index;
  final BlockChain blockChain;
  final String hex;
  final String label;

  /// Matters only Bitcoin, because Bitcoin testnet addresses differ from
  /// Bitcoin mainnet addresses
  ///
  /// 0 - mainnet
  /// 1 - testnet
  final int? bitcoinNetVersion;
  const AppAddress(
      {required this.id,
      required this.index,
      required this.blockChain,
      required this.hex,
      required this.label,
      this.bitcoinNetVersion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['index'] = Variable<int>(index);
    {
      map['block_chain'] = Variable<int>(
          $AppAddressesTable.$converterblockChain.toSql(blockChain));
    }
    map['hex'] = Variable<String>(hex);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || bitcoinNetVersion != null) {
      map['bitcoin_net_version'] = Variable<int>(bitcoinNetVersion);
    }
    return map;
  }

  AppAddressesCompanion toCompanion(bool nullToAbsent) {
    return AppAddressesCompanion(
      id: Value(id),
      index: Value(index),
      blockChain: Value(blockChain),
      hex: Value(hex),
      label: Value(label),
      bitcoinNetVersion: bitcoinNetVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(bitcoinNetVersion),
    );
  }

  factory AppAddress.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppAddress(
      id: serializer.fromJson<int>(json['id']),
      index: serializer.fromJson<int>(json['index']),
      blockChain: $AppAddressesTable.$converterblockChain
          .fromJson(serializer.fromJson<int>(json['blockChain'])),
      hex: serializer.fromJson<String>(json['hex']),
      label: serializer.fromJson<String>(json['label']),
      bitcoinNetVersion: serializer.fromJson<int?>(json['bitcoinNetVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'index': serializer.toJson<int>(index),
      'blockChain': serializer.toJson<int>(
          $AppAddressesTable.$converterblockChain.toJson(blockChain)),
      'hex': serializer.toJson<String>(hex),
      'label': serializer.toJson<String>(label),
      'bitcoinNetVersion': serializer.toJson<int?>(bitcoinNetVersion),
    };
  }

  AppAddress copyWith(
          {int? id,
          int? index,
          BlockChain? blockChain,
          String? hex,
          String? label,
          Value<int?> bitcoinNetVersion = const Value.absent()}) =>
      AppAddress(
        id: id ?? this.id,
        index: index ?? this.index,
        blockChain: blockChain ?? this.blockChain,
        hex: hex ?? this.hex,
        label: label ?? this.label,
        bitcoinNetVersion: bitcoinNetVersion.present
            ? bitcoinNetVersion.value
            : this.bitcoinNetVersion,
      );
  AppAddress copyWithCompanion(AppAddressesCompanion data) {
    return AppAddress(
      id: data.id.present ? data.id.value : this.id,
      index: data.index.present ? data.index.value : this.index,
      blockChain:
          data.blockChain.present ? data.blockChain.value : this.blockChain,
      hex: data.hex.present ? data.hex.value : this.hex,
      label: data.label.present ? data.label.value : this.label,
      bitcoinNetVersion: data.bitcoinNetVersion.present
          ? data.bitcoinNetVersion.value
          : this.bitcoinNetVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppAddress(')
          ..write('id: $id, ')
          ..write('index: $index, ')
          ..write('blockChain: $blockChain, ')
          ..write('hex: $hex, ')
          ..write('label: $label, ')
          ..write('bitcoinNetVersion: $bitcoinNetVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, index, blockChain, hex, label, bitcoinNetVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppAddress &&
          other.id == this.id &&
          other.index == this.index &&
          other.blockChain == this.blockChain &&
          other.hex == this.hex &&
          other.label == this.label &&
          other.bitcoinNetVersion == this.bitcoinNetVersion);
}

class AppAddressesCompanion extends UpdateCompanion<AppAddress> {
  final Value<int> id;
  final Value<int> index;
  final Value<BlockChain> blockChain;
  final Value<String> hex;
  final Value<String> label;
  final Value<int?> bitcoinNetVersion;
  const AppAddressesCompanion({
    this.id = const Value.absent(),
    this.index = const Value.absent(),
    this.blockChain = const Value.absent(),
    this.hex = const Value.absent(),
    this.label = const Value.absent(),
    this.bitcoinNetVersion = const Value.absent(),
  });
  AppAddressesCompanion.insert({
    this.id = const Value.absent(),
    required int index,
    required BlockChain blockChain,
    required String hex,
    required String label,
    this.bitcoinNetVersion = const Value.absent(),
  })  : index = Value(index),
        blockChain = Value(blockChain),
        hex = Value(hex),
        label = Value(label);
  static Insertable<AppAddress> custom({
    Expression<int>? id,
    Expression<int>? index,
    Expression<int>? blockChain,
    Expression<String>? hex,
    Expression<String>? label,
    Expression<int>? bitcoinNetVersion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (index != null) 'index': index,
      if (blockChain != null) 'block_chain': blockChain,
      if (hex != null) 'hex': hex,
      if (label != null) 'label': label,
      if (bitcoinNetVersion != null) 'bitcoin_net_version': bitcoinNetVersion,
    });
  }

  AppAddressesCompanion copyWith(
      {Value<int>? id,
      Value<int>? index,
      Value<BlockChain>? blockChain,
      Value<String>? hex,
      Value<String>? label,
      Value<int?>? bitcoinNetVersion}) {
    return AppAddressesCompanion(
      id: id ?? this.id,
      index: index ?? this.index,
      blockChain: blockChain ?? this.blockChain,
      hex: hex ?? this.hex,
      label: label ?? this.label,
      bitcoinNetVersion: bitcoinNetVersion ?? this.bitcoinNetVersion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (index.present) {
      map['index'] = Variable<int>(index.value);
    }
    if (blockChain.present) {
      map['block_chain'] = Variable<int>(
          $AppAddressesTable.$converterblockChain.toSql(blockChain.value));
    }
    if (hex.present) {
      map['hex'] = Variable<String>(hex.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (bitcoinNetVersion.present) {
      map['bitcoin_net_version'] = Variable<int>(bitcoinNetVersion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppAddressesCompanion(')
          ..write('id: $id, ')
          ..write('index: $index, ')
          ..write('blockChain: $blockChain, ')
          ..write('hex: $hex, ')
          ..write('label: $label, ')
          ..write('bitcoinNetVersion: $bitcoinNetVersion')
          ..write(')'))
        .toString();
  }
}

class $AppNetworksTable extends AppNetworks
    with TableInfo<$AppNetworksTable, AppNetwork> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppNetworksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetsMeta = const VerificationMeta('assets');
  @override
  late final GeneratedColumnWithTypeConverter<AppNetworkAssetEntries, String>
      assets = GeneratedColumn<String>('assets', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<AppNetworkAssetEntries>(
              $AppNetworksTable.$converterassets);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _blockChainMeta =
      const VerificationMeta('blockChain');
  @override
  late final GeneratedColumnWithTypeConverter<BlockChain, int> blockChain =
      GeneratedColumn<int>('block_chain', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<BlockChain>($AppNetworksTable.$converterblockChain);
  static const VerificationMeta _blockExplorerUrlMeta =
      const VerificationMeta('blockExplorerUrl');
  @override
  late final GeneratedColumn<String> blockExplorerUrl = GeneratedColumn<String>(
      'block_explorer_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chainIdMeta =
      const VerificationMeta('chainId');
  @override
  late final GeneratedColumn<int> chainId = GeneratedColumn<int>(
      'chain_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currencySymbolMeta =
      const VerificationMeta('currencySymbol');
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
      'currency_symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<NetworkType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<NetworkType>($AppNetworksTable.$convertertype);
  @override
  List<GeneratedColumn> get $columns => [
        assets,
        id,
        blockChain,
        blockExplorerUrl,
        chainId,
        currencySymbol,
        name,
        url,
        type
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_networks';
  @override
  VerificationContext validateIntegrity(Insertable<AppNetwork> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    context.handle(_assetsMeta, const VerificationResult.success());
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    context.handle(_blockChainMeta, const VerificationResult.success());
    if (data.containsKey('block_explorer_url')) {
      context.handle(
          _blockExplorerUrlMeta,
          blockExplorerUrl.isAcceptableOrUnknown(
              data['block_explorer_url']!, _blockExplorerUrlMeta));
    } else if (isInserting) {
      context.missing(_blockExplorerUrlMeta);
    }
    if (data.containsKey('chain_id')) {
      context.handle(_chainIdMeta,
          chainId.isAcceptableOrUnknown(data['chain_id']!, _chainIdMeta));
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
          _currencySymbolMeta,
          currencySymbol.isAcceptableOrUnknown(
              data['currency_symbol']!, _currencySymbolMeta));
    } else if (isInserting) {
      context.missing(_currencySymbolMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppNetwork map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppNetwork(
      assets: $AppNetworksTable.$converterassets.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assets'])!),
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      blockChain: $AppNetworksTable.$converterblockChain.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}block_chain'])!),
      blockExplorerUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}block_explorer_url'])!,
      chainId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chain_id']),
      currencySymbol: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}currency_symbol'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      type: $AppNetworksTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
    );
  }

  @override
  $AppNetworksTable createAlias(String alias) {
    return $AppNetworksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AppNetworkAssetEntries, String, String>
      $converterassets = AppNetworkAssetEntries.converter;
  static JsonTypeConverter2<BlockChain, int, int> $converterblockChain =
      const EnumIndexConverter<BlockChain>(BlockChain.values);
  static JsonTypeConverter2<NetworkType, int, int> $convertertype =
      const EnumIndexConverter<NetworkType>(NetworkType.values);
}

class AppNetwork extends DataClass implements Insertable<AppNetwork> {
  final AppNetworkAssetEntries assets;
  final int id;
  final BlockChain blockChain;
  final String blockExplorerUrl;
  final int? chainId;
  final String currencySymbol;
  final String name;
  final String url;
  final NetworkType type;
  const AppNetwork(
      {required this.assets,
      required this.id,
      required this.blockChain,
      required this.blockExplorerUrl,
      this.chainId,
      required this.currencySymbol,
      required this.name,
      required this.url,
      required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['assets'] =
          Variable<String>($AppNetworksTable.$converterassets.toSql(assets));
    }
    map['id'] = Variable<int>(id);
    {
      map['block_chain'] = Variable<int>(
          $AppNetworksTable.$converterblockChain.toSql(blockChain));
    }
    map['block_explorer_url'] = Variable<String>(blockExplorerUrl);
    if (!nullToAbsent || chainId != null) {
      map['chain_id'] = Variable<int>(chainId);
    }
    map['currency_symbol'] = Variable<String>(currencySymbol);
    map['name'] = Variable<String>(name);
    map['url'] = Variable<String>(url);
    {
      map['type'] = Variable<int>($AppNetworksTable.$convertertype.toSql(type));
    }
    return map;
  }

  AppNetworksCompanion toCompanion(bool nullToAbsent) {
    return AppNetworksCompanion(
      assets: Value(assets),
      id: Value(id),
      blockChain: Value(blockChain),
      blockExplorerUrl: Value(blockExplorerUrl),
      chainId: chainId == null && nullToAbsent
          ? const Value.absent()
          : Value(chainId),
      currencySymbol: Value(currencySymbol),
      name: Value(name),
      url: Value(url),
      type: Value(type),
    );
  }

  factory AppNetwork.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppNetwork(
      assets: $AppNetworksTable.$converterassets
          .fromJson(serializer.fromJson<String>(json['assets'])),
      id: serializer.fromJson<int>(json['id']),
      blockChain: $AppNetworksTable.$converterblockChain
          .fromJson(serializer.fromJson<int>(json['blockChain'])),
      blockExplorerUrl: serializer.fromJson<String>(json['blockExplorerUrl']),
      chainId: serializer.fromJson<int?>(json['chainId']),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String>(json['url']),
      type: $AppNetworksTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assets': serializer
          .toJson<String>($AppNetworksTable.$converterassets.toJson(assets)),
      'id': serializer.toJson<int>(id),
      'blockChain': serializer.toJson<int>(
          $AppNetworksTable.$converterblockChain.toJson(blockChain)),
      'blockExplorerUrl': serializer.toJson<String>(blockExplorerUrl),
      'chainId': serializer.toJson<int?>(chainId),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'name': serializer.toJson<String>(name),
      'url': serializer.toJson<String>(url),
      'type':
          serializer.toJson<int>($AppNetworksTable.$convertertype.toJson(type)),
    };
  }

  AppNetwork copyWith(
          {AppNetworkAssetEntries? assets,
          int? id,
          BlockChain? blockChain,
          String? blockExplorerUrl,
          Value<int?> chainId = const Value.absent(),
          String? currencySymbol,
          String? name,
          String? url,
          NetworkType? type}) =>
      AppNetwork(
        assets: assets ?? this.assets,
        id: id ?? this.id,
        blockChain: blockChain ?? this.blockChain,
        blockExplorerUrl: blockExplorerUrl ?? this.blockExplorerUrl,
        chainId: chainId.present ? chainId.value : this.chainId,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        name: name ?? this.name,
        url: url ?? this.url,
        type: type ?? this.type,
      );
  AppNetwork copyWithCompanion(AppNetworksCompanion data) {
    return AppNetwork(
      assets: data.assets.present ? data.assets.value : this.assets,
      id: data.id.present ? data.id.value : this.id,
      blockChain:
          data.blockChain.present ? data.blockChain.value : this.blockChain,
      blockExplorerUrl: data.blockExplorerUrl.present
          ? data.blockExplorerUrl.value
          : this.blockExplorerUrl,
      chainId: data.chainId.present ? data.chainId.value : this.chainId,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppNetwork(')
          ..write('assets: $assets, ')
          ..write('id: $id, ')
          ..write('blockChain: $blockChain, ')
          ..write('blockExplorerUrl: $blockExplorerUrl, ')
          ..write('chainId: $chainId, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(assets, id, blockChain, blockExplorerUrl,
      chainId, currencySymbol, name, url, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppNetwork &&
          other.assets == this.assets &&
          other.id == this.id &&
          other.blockChain == this.blockChain &&
          other.blockExplorerUrl == this.blockExplorerUrl &&
          other.chainId == this.chainId &&
          other.currencySymbol == this.currencySymbol &&
          other.name == this.name &&
          other.url == this.url &&
          other.type == this.type);
}

class AppNetworksCompanion extends UpdateCompanion<AppNetwork> {
  final Value<AppNetworkAssetEntries> assets;
  final Value<int> id;
  final Value<BlockChain> blockChain;
  final Value<String> blockExplorerUrl;
  final Value<int?> chainId;
  final Value<String> currencySymbol;
  final Value<String> name;
  final Value<String> url;
  final Value<NetworkType> type;
  const AppNetworksCompanion({
    this.assets = const Value.absent(),
    this.id = const Value.absent(),
    this.blockChain = const Value.absent(),
    this.blockExplorerUrl = const Value.absent(),
    this.chainId = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.name = const Value.absent(),
    this.url = const Value.absent(),
    this.type = const Value.absent(),
  });
  AppNetworksCompanion.insert({
    required AppNetworkAssetEntries assets,
    this.id = const Value.absent(),
    required BlockChain blockChain,
    required String blockExplorerUrl,
    this.chainId = const Value.absent(),
    required String currencySymbol,
    required String name,
    required String url,
    required NetworkType type,
  })  : assets = Value(assets),
        blockChain = Value(blockChain),
        blockExplorerUrl = Value(blockExplorerUrl),
        currencySymbol = Value(currencySymbol),
        name = Value(name),
        url = Value(url),
        type = Value(type);
  static Insertable<AppNetwork> custom({
    Expression<String>? assets,
    Expression<int>? id,
    Expression<int>? blockChain,
    Expression<String>? blockExplorerUrl,
    Expression<int>? chainId,
    Expression<String>? currencySymbol,
    Expression<String>? name,
    Expression<String>? url,
    Expression<int>? type,
  }) {
    return RawValuesInsertable({
      if (assets != null) 'assets': assets,
      if (id != null) 'id': id,
      if (blockChain != null) 'block_chain': blockChain,
      if (blockExplorerUrl != null) 'block_explorer_url': blockExplorerUrl,
      if (chainId != null) 'chain_id': chainId,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (type != null) 'type': type,
    });
  }

  AppNetworksCompanion copyWith(
      {Value<AppNetworkAssetEntries>? assets,
      Value<int>? id,
      Value<BlockChain>? blockChain,
      Value<String>? blockExplorerUrl,
      Value<int?>? chainId,
      Value<String>? currencySymbol,
      Value<String>? name,
      Value<String>? url,
      Value<NetworkType>? type}) {
    return AppNetworksCompanion(
      assets: assets ?? this.assets,
      id: id ?? this.id,
      blockChain: blockChain ?? this.blockChain,
      blockExplorerUrl: blockExplorerUrl ?? this.blockExplorerUrl,
      chainId: chainId ?? this.chainId,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      name: name ?? this.name,
      url: url ?? this.url,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assets.present) {
      map['assets'] = Variable<String>(
          $AppNetworksTable.$converterassets.toSql(assets.value));
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (blockChain.present) {
      map['block_chain'] = Variable<int>(
          $AppNetworksTable.$converterblockChain.toSql(blockChain.value));
    }
    if (blockExplorerUrl.present) {
      map['block_explorer_url'] = Variable<String>(blockExplorerUrl.value);
    }
    if (chainId.present) {
      map['chain_id'] = Variable<int>(chainId.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (type.present) {
      map['type'] =
          Variable<int>($AppNetworksTable.$convertertype.toSql(type.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppNetworksCompanion(')
          ..write('assets: $assets, ')
          ..write('id: $id, ')
          ..write('blockChain: $blockChain, ')
          ..write('blockExplorerUrl: $blockExplorerUrl, ')
          ..write('chainId: $chainId, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _faviconUrlMeta =
      const VerificationMeta('faviconUrl');
  @override
  late final GeneratedColumn<String> faviconUrl = GeneratedColumn<String>(
      'favicon_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, faviconUrl, title, url];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(Insertable<Bookmark> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('favicon_url')) {
      context.handle(
          _faviconUrlMeta,
          faviconUrl.isAcceptableOrUnknown(
              data['favicon_url']!, _faviconUrlMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      faviconUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}favicon_url']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final int id;
  final String? faviconUrl;
  final String title;
  final String url;
  const Bookmark(
      {required this.id,
      this.faviconUrl,
      required this.title,
      required this.url});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || faviconUrl != null) {
      map['favicon_url'] = Variable<String>(faviconUrl);
    }
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      faviconUrl: faviconUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(faviconUrl),
      title: Value(title),
      url: Value(url),
    );
  }

  factory Bookmark.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<int>(json['id']),
      faviconUrl: serializer.fromJson<String?>(json['faviconUrl']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'faviconUrl': serializer.toJson<String?>(faviconUrl),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
    };
  }

  Bookmark copyWith(
          {int? id,
          Value<String?> faviconUrl = const Value.absent(),
          String? title,
          String? url}) =>
      Bookmark(
        id: id ?? this.id,
        faviconUrl: faviconUrl.present ? faviconUrl.value : this.faviconUrl,
        title: title ?? this.title,
        url: url ?? this.url,
      );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      faviconUrl:
          data.faviconUrl.present ? data.faviconUrl.value : this.faviconUrl,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('faviconUrl: $faviconUrl, ')
          ..write('title: $title, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, faviconUrl, title, url);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.faviconUrl == this.faviconUrl &&
          other.title == this.title &&
          other.url == this.url);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<int> id;
  final Value<String?> faviconUrl;
  final Value<String> title;
  final Value<String> url;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.faviconUrl = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    this.faviconUrl = const Value.absent(),
    required String title,
    required String url,
  })  : title = Value(title),
        url = Value(url);
  static Insertable<Bookmark> custom({
    Expression<int>? id,
    Expression<String>? faviconUrl,
    Expression<String>? title,
    Expression<String>? url,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (faviconUrl != null) 'favicon_url': faviconUrl,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
    });
  }

  BookmarksCompanion copyWith(
      {Value<int>? id,
      Value<String?>? faviconUrl,
      Value<String>? title,
      Value<String>? url}) {
    return BookmarksCompanion(
      id: id ?? this.id,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      title: title ?? this.title,
      url: url ?? this.url,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (faviconUrl.present) {
      map['favicon_url'] = Variable<String>(faviconUrl.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('faviconUrl: $faviconUrl, ')
          ..write('title: $title, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }
}

class $EthereumTxsTable extends EthereumTxs
    with TableInfo<$EthereumTxsTable, EthereumTx> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EthereumTxsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _fromMeta = const VerificationMeta('from');
  @override
  late final GeneratedColumn<String> from = GeneratedColumn<String>(
      'from', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _gasMeta = const VerificationMeta('gas');
  @override
  late final GeneratedColumn<int> gas = GeneratedColumn<int>(
      'gas', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
      'hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inputMeta = const VerificationMeta('input');
  @override
  late final GeneratedColumn<String> input = GeneratedColumn<String>(
      'input', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _networkMeta =
      const VerificationMeta('network');
  @override
  late final GeneratedColumn<int> network = GeneratedColumn<int>(
      'network', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES app_networks (id)'));
  static const VerificationMeta _toMeta = const VerificationMeta('to');
  @override
  late final GeneratedColumn<String> to = GeneratedColumn<String>(
      'to', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<BigInt> value = GeneratedColumn<BigInt>(
      'value', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: true);
  static const VerificationMeta _txDateTimeMeta =
      const VerificationMeta('txDateTime');
  @override
  late final GeneratedColumn<DateTime> txDateTime = GeneratedColumn<DateTime>(
      'tx_date_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumnWithTypeConverter<EthereumTransactionStatus, int>
      status = GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<EthereumTransactionStatus>(
              $EthereumTxsTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns =>
      [id, from, gas, hash, input, network, to, value, txDateTime, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ethereum_txs';
  @override
  VerificationContext validateIntegrity(Insertable<EthereumTx> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('from')) {
      context.handle(
          _fromMeta, from.isAcceptableOrUnknown(data['from']!, _fromMeta));
    } else if (isInserting) {
      context.missing(_fromMeta);
    }
    if (data.containsKey('gas')) {
      context.handle(
          _gasMeta, gas.isAcceptableOrUnknown(data['gas']!, _gasMeta));
    } else if (isInserting) {
      context.missing(_gasMeta);
    }
    if (data.containsKey('hash')) {
      context.handle(
          _hashMeta, hash.isAcceptableOrUnknown(data['hash']!, _hashMeta));
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    if (data.containsKey('input')) {
      context.handle(
          _inputMeta, input.isAcceptableOrUnknown(data['input']!, _inputMeta));
    } else if (isInserting) {
      context.missing(_inputMeta);
    }
    if (data.containsKey('network')) {
      context.handle(_networkMeta,
          network.isAcceptableOrUnknown(data['network']!, _networkMeta));
    } else if (isInserting) {
      context.missing(_networkMeta);
    }
    if (data.containsKey('to')) {
      context.handle(_toMeta, to.isAcceptableOrUnknown(data['to']!, _toMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('tx_date_time')) {
      context.handle(
          _txDateTimeMeta,
          txDateTime.isAcceptableOrUnknown(
              data['tx_date_time']!, _txDateTimeMeta));
    } else if (isInserting) {
      context.missing(_txDateTimeMeta);
    }
    context.handle(_statusMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EthereumTx map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EthereumTx(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      from: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from'])!,
      gas: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gas'])!,
      hash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hash'])!,
      input: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}input'])!,
      network: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}network'])!,
      to: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to']),
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}value'])!,
      txDateTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}tx_date_time'])!,
      status: $EthereumTxsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
    );
  }

  @override
  $EthereumTxsTable createAlias(String alias) {
    return $EthereumTxsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EthereumTransactionStatus, int, int>
      $converterstatus = const EnumIndexConverter<EthereumTransactionStatus>(
          EthereumTransactionStatus.values);
}

class EthereumTx extends DataClass implements Insertable<EthereumTx> {
  final int id;
  final String from;
  final int gas;
  final String hash;
  final String input;
  final int network;
  final String? to;
  final BigInt value;
  final DateTime txDateTime;
  final EthereumTransactionStatus status;
  const EthereumTx(
      {required this.id,
      required this.from,
      required this.gas,
      required this.hash,
      required this.input,
      required this.network,
      this.to,
      required this.value,
      required this.txDateTime,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['from'] = Variable<String>(from);
    map['gas'] = Variable<int>(gas);
    map['hash'] = Variable<String>(hash);
    map['input'] = Variable<String>(input);
    map['network'] = Variable<int>(network);
    if (!nullToAbsent || to != null) {
      map['to'] = Variable<String>(to);
    }
    map['value'] = Variable<BigInt>(value);
    map['tx_date_time'] = Variable<DateTime>(txDateTime);
    {
      map['status'] =
          Variable<int>($EthereumTxsTable.$converterstatus.toSql(status));
    }
    return map;
  }

  EthereumTxsCompanion toCompanion(bool nullToAbsent) {
    return EthereumTxsCompanion(
      id: Value(id),
      from: Value(from),
      gas: Value(gas),
      hash: Value(hash),
      input: Value(input),
      network: Value(network),
      to: to == null && nullToAbsent ? const Value.absent() : Value(to),
      value: Value(value),
      txDateTime: Value(txDateTime),
      status: Value(status),
    );
  }

  factory EthereumTx.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EthereumTx(
      id: serializer.fromJson<int>(json['id']),
      from: serializer.fromJson<String>(json['from']),
      gas: serializer.fromJson<int>(json['gas']),
      hash: serializer.fromJson<String>(json['hash']),
      input: serializer.fromJson<String>(json['input']),
      network: serializer.fromJson<int>(json['network']),
      to: serializer.fromJson<String?>(json['to']),
      value: serializer.fromJson<BigInt>(json['value']),
      txDateTime: serializer.fromJson<DateTime>(json['txDateTime']),
      status: $EthereumTxsTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'from': serializer.toJson<String>(from),
      'gas': serializer.toJson<int>(gas),
      'hash': serializer.toJson<String>(hash),
      'input': serializer.toJson<String>(input),
      'network': serializer.toJson<int>(network),
      'to': serializer.toJson<String?>(to),
      'value': serializer.toJson<BigInt>(value),
      'txDateTime': serializer.toJson<DateTime>(txDateTime),
      'status': serializer
          .toJson<int>($EthereumTxsTable.$converterstatus.toJson(status)),
    };
  }

  EthereumTx copyWith(
          {int? id,
          String? from,
          int? gas,
          String? hash,
          String? input,
          int? network,
          Value<String?> to = const Value.absent(),
          BigInt? value,
          DateTime? txDateTime,
          EthereumTransactionStatus? status}) =>
      EthereumTx(
        id: id ?? this.id,
        from: from ?? this.from,
        gas: gas ?? this.gas,
        hash: hash ?? this.hash,
        input: input ?? this.input,
        network: network ?? this.network,
        to: to.present ? to.value : this.to,
        value: value ?? this.value,
        txDateTime: txDateTime ?? this.txDateTime,
        status: status ?? this.status,
      );
  EthereumTx copyWithCompanion(EthereumTxsCompanion data) {
    return EthereumTx(
      id: data.id.present ? data.id.value : this.id,
      from: data.from.present ? data.from.value : this.from,
      gas: data.gas.present ? data.gas.value : this.gas,
      hash: data.hash.present ? data.hash.value : this.hash,
      input: data.input.present ? data.input.value : this.input,
      network: data.network.present ? data.network.value : this.network,
      to: data.to.present ? data.to.value : this.to,
      value: data.value.present ? data.value.value : this.value,
      txDateTime:
          data.txDateTime.present ? data.txDateTime.value : this.txDateTime,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EthereumTx(')
          ..write('id: $id, ')
          ..write('from: $from, ')
          ..write('gas: $gas, ')
          ..write('hash: $hash, ')
          ..write('input: $input, ')
          ..write('network: $network, ')
          ..write('to: $to, ')
          ..write('value: $value, ')
          ..write('txDateTime: $txDateTime, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, from, gas, hash, input, network, to, value, txDateTime, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EthereumTx &&
          other.id == this.id &&
          other.from == this.from &&
          other.gas == this.gas &&
          other.hash == this.hash &&
          other.input == this.input &&
          other.network == this.network &&
          other.to == this.to &&
          other.value == this.value &&
          other.txDateTime == this.txDateTime &&
          other.status == this.status);
}

class EthereumTxsCompanion extends UpdateCompanion<EthereumTx> {
  final Value<int> id;
  final Value<String> from;
  final Value<int> gas;
  final Value<String> hash;
  final Value<String> input;
  final Value<int> network;
  final Value<String?> to;
  final Value<BigInt> value;
  final Value<DateTime> txDateTime;
  final Value<EthereumTransactionStatus> status;
  const EthereumTxsCompanion({
    this.id = const Value.absent(),
    this.from = const Value.absent(),
    this.gas = const Value.absent(),
    this.hash = const Value.absent(),
    this.input = const Value.absent(),
    this.network = const Value.absent(),
    this.to = const Value.absent(),
    this.value = const Value.absent(),
    this.txDateTime = const Value.absent(),
    this.status = const Value.absent(),
  });
  EthereumTxsCompanion.insert({
    this.id = const Value.absent(),
    required String from,
    required int gas,
    required String hash,
    required String input,
    required int network,
    this.to = const Value.absent(),
    required BigInt value,
    required DateTime txDateTime,
    required EthereumTransactionStatus status,
  })  : from = Value(from),
        gas = Value(gas),
        hash = Value(hash),
        input = Value(input),
        network = Value(network),
        value = Value(value),
        txDateTime = Value(txDateTime),
        status = Value(status);
  static Insertable<EthereumTx> custom({
    Expression<int>? id,
    Expression<String>? from,
    Expression<int>? gas,
    Expression<String>? hash,
    Expression<String>? input,
    Expression<int>? network,
    Expression<String>? to,
    Expression<BigInt>? value,
    Expression<DateTime>? txDateTime,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (from != null) 'from': from,
      if (gas != null) 'gas': gas,
      if (hash != null) 'hash': hash,
      if (input != null) 'input': input,
      if (network != null) 'network': network,
      if (to != null) 'to': to,
      if (value != null) 'value': value,
      if (txDateTime != null) 'tx_date_time': txDateTime,
      if (status != null) 'status': status,
    });
  }

  EthereumTxsCompanion copyWith(
      {Value<int>? id,
      Value<String>? from,
      Value<int>? gas,
      Value<String>? hash,
      Value<String>? input,
      Value<int>? network,
      Value<String?>? to,
      Value<BigInt>? value,
      Value<DateTime>? txDateTime,
      Value<EthereumTransactionStatus>? status}) {
    return EthereumTxsCompanion(
      id: id ?? this.id,
      from: from ?? this.from,
      gas: gas ?? this.gas,
      hash: hash ?? this.hash,
      input: input ?? this.input,
      network: network ?? this.network,
      to: to ?? this.to,
      value: value ?? this.value,
      txDateTime: txDateTime ?? this.txDateTime,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (from.present) {
      map['from'] = Variable<String>(from.value);
    }
    if (gas.present) {
      map['gas'] = Variable<int>(gas.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (input.present) {
      map['input'] = Variable<String>(input.value);
    }
    if (network.present) {
      map['network'] = Variable<int>(network.value);
    }
    if (to.present) {
      map['to'] = Variable<String>(to.value);
    }
    if (value.present) {
      map['value'] = Variable<BigInt>(value.value);
    }
    if (txDateTime.present) {
      map['tx_date_time'] = Variable<DateTime>(txDateTime.value);
    }
    if (status.present) {
      map['status'] =
          Variable<int>($EthereumTxsTable.$converterstatus.toSql(status.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EthereumTxsCompanion(')
          ..write('id: $id, ')
          ..write('from: $from, ')
          ..write('gas: $gas, ')
          ..write('hash: $hash, ')
          ..write('input: $input, ')
          ..write('network: $network, ')
          ..write('to: $to, ')
          ..write('value: $value, ')
          ..write('txDateTime: $txDateTime, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $NetworkAssetsTable extends NetworkAssets
    with TableInfo<$NetworkAssetsTable, NetworkAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NetworkAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _contractAddressHexMeta =
      const VerificationMeta('contractAddressHex');
  @override
  late final GeneratedColumn<String> contractAddressHex =
      GeneratedColumn<String>('contract_address_hex', aliasedName, true,
          additionalChecks: GeneratedColumn.checkTextLength(),
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _decimalsMeta =
      const VerificationMeta('decimals');
  @override
  late final GeneratedColumn<int> decimals = GeneratedColumn<int>(
      'decimals', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _logoUrlMeta =
      const VerificationMeta('logoUrl');
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
      'logo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _networkMeta =
      const VerificationMeta('network');
  @override
  late final GeneratedColumn<int> network = GeneratedColumn<int>(
      'network', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES app_networks (id)'));
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCurrencyMeta =
      const VerificationMeta('isCurrency');
  @override
  late final GeneratedColumn<bool> isCurrency = GeneratedColumn<bool>(
      'is_currency', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_currency" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        contractAddressHex,
        decimals,
        logoUrl,
        name,
        network,
        symbol,
        isCurrency
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'network_assets';
  @override
  VerificationContext validateIntegrity(Insertable<NetworkAsset> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contract_address_hex')) {
      context.handle(
          _contractAddressHexMeta,
          contractAddressHex.isAcceptableOrUnknown(
              data['contract_address_hex']!, _contractAddressHexMeta));
    }
    if (data.containsKey('decimals')) {
      context.handle(_decimalsMeta,
          decimals.isAcceptableOrUnknown(data['decimals']!, _decimalsMeta));
    } else if (isInserting) {
      context.missing(_decimalsMeta);
    }
    if (data.containsKey('logo_url')) {
      context.handle(_logoUrlMeta,
          logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('network')) {
      context.handle(_networkMeta,
          network.isAcceptableOrUnknown(data['network']!, _networkMeta));
    } else if (isInserting) {
      context.missing(_networkMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('is_currency')) {
      context.handle(
          _isCurrencyMeta,
          isCurrency.isAcceptableOrUnknown(
              data['is_currency']!, _isCurrencyMeta));
    } else if (isInserting) {
      context.missing(_isCurrencyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NetworkAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NetworkAsset(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      contractAddressHex: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}contract_address_hex']),
      decimals: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}decimals'])!,
      logoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_url']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      network: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}network'])!,
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      isCurrency: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_currency'])!,
    );
  }

  @override
  $NetworkAssetsTable createAlias(String alias) {
    return $NetworkAssetsTable(attachedDatabase, alias);
  }
}

class NetworkAsset extends DataClass implements Insertable<NetworkAsset> {
  final int id;
  final String? contractAddressHex;
  final int decimals;
  final String? logoUrl;
  final String? name;
  final int network;
  final String symbol;
  final bool isCurrency;
  const NetworkAsset(
      {required this.id,
      this.contractAddressHex,
      required this.decimals,
      this.logoUrl,
      this.name,
      required this.network,
      required this.symbol,
      required this.isCurrency});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || contractAddressHex != null) {
      map['contract_address_hex'] = Variable<String>(contractAddressHex);
    }
    map['decimals'] = Variable<int>(decimals);
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['network'] = Variable<int>(network);
    map['symbol'] = Variable<String>(symbol);
    map['is_currency'] = Variable<bool>(isCurrency);
    return map;
  }

  NetworkAssetsCompanion toCompanion(bool nullToAbsent) {
    return NetworkAssetsCompanion(
      id: Value(id),
      contractAddressHex: contractAddressHex == null && nullToAbsent
          ? const Value.absent()
          : Value(contractAddressHex),
      decimals: Value(decimals),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      network: Value(network),
      symbol: Value(symbol),
      isCurrency: Value(isCurrency),
    );
  }

  factory NetworkAsset.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NetworkAsset(
      id: serializer.fromJson<int>(json['id']),
      contractAddressHex:
          serializer.fromJson<String?>(json['contractAddressHex']),
      decimals: serializer.fromJson<int>(json['decimals']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      name: serializer.fromJson<String?>(json['name']),
      network: serializer.fromJson<int>(json['network']),
      symbol: serializer.fromJson<String>(json['symbol']),
      isCurrency: serializer.fromJson<bool>(json['isCurrency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contractAddressHex': serializer.toJson<String?>(contractAddressHex),
      'decimals': serializer.toJson<int>(decimals),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'name': serializer.toJson<String?>(name),
      'network': serializer.toJson<int>(network),
      'symbol': serializer.toJson<String>(symbol),
      'isCurrency': serializer.toJson<bool>(isCurrency),
    };
  }

  NetworkAsset copyWith(
          {int? id,
          Value<String?> contractAddressHex = const Value.absent(),
          int? decimals,
          Value<String?> logoUrl = const Value.absent(),
          Value<String?> name = const Value.absent(),
          int? network,
          String? symbol,
          bool? isCurrency}) =>
      NetworkAsset(
        id: id ?? this.id,
        contractAddressHex: contractAddressHex.present
            ? contractAddressHex.value
            : this.contractAddressHex,
        decimals: decimals ?? this.decimals,
        logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
        name: name.present ? name.value : this.name,
        network: network ?? this.network,
        symbol: symbol ?? this.symbol,
        isCurrency: isCurrency ?? this.isCurrency,
      );
  NetworkAsset copyWithCompanion(NetworkAssetsCompanion data) {
    return NetworkAsset(
      id: data.id.present ? data.id.value : this.id,
      contractAddressHex: data.contractAddressHex.present
          ? data.contractAddressHex.value
          : this.contractAddressHex,
      decimals: data.decimals.present ? data.decimals.value : this.decimals,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      name: data.name.present ? data.name.value : this.name,
      network: data.network.present ? data.network.value : this.network,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      isCurrency:
          data.isCurrency.present ? data.isCurrency.value : this.isCurrency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NetworkAsset(')
          ..write('id: $id, ')
          ..write('contractAddressHex: $contractAddressHex, ')
          ..write('decimals: $decimals, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('name: $name, ')
          ..write('network: $network, ')
          ..write('symbol: $symbol, ')
          ..write('isCurrency: $isCurrency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contractAddressHex, decimals, logoUrl,
      name, network, symbol, isCurrency);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NetworkAsset &&
          other.id == this.id &&
          other.contractAddressHex == this.contractAddressHex &&
          other.decimals == this.decimals &&
          other.logoUrl == this.logoUrl &&
          other.name == this.name &&
          other.network == this.network &&
          other.symbol == this.symbol &&
          other.isCurrency == this.isCurrency);
}

class NetworkAssetsCompanion extends UpdateCompanion<NetworkAsset> {
  final Value<int> id;
  final Value<String?> contractAddressHex;
  final Value<int> decimals;
  final Value<String?> logoUrl;
  final Value<String?> name;
  final Value<int> network;
  final Value<String> symbol;
  final Value<bool> isCurrency;
  const NetworkAssetsCompanion({
    this.id = const Value.absent(),
    this.contractAddressHex = const Value.absent(),
    this.decimals = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.name = const Value.absent(),
    this.network = const Value.absent(),
    this.symbol = const Value.absent(),
    this.isCurrency = const Value.absent(),
  });
  NetworkAssetsCompanion.insert({
    this.id = const Value.absent(),
    this.contractAddressHex = const Value.absent(),
    required int decimals,
    this.logoUrl = const Value.absent(),
    this.name = const Value.absent(),
    required int network,
    required String symbol,
    required bool isCurrency,
  })  : decimals = Value(decimals),
        network = Value(network),
        symbol = Value(symbol),
        isCurrency = Value(isCurrency);
  static Insertable<NetworkAsset> custom({
    Expression<int>? id,
    Expression<String>? contractAddressHex,
    Expression<int>? decimals,
    Expression<String>? logoUrl,
    Expression<String>? name,
    Expression<int>? network,
    Expression<String>? symbol,
    Expression<bool>? isCurrency,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contractAddressHex != null)
        'contract_address_hex': contractAddressHex,
      if (decimals != null) 'decimals': decimals,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (name != null) 'name': name,
      if (network != null) 'network': network,
      if (symbol != null) 'symbol': symbol,
      if (isCurrency != null) 'is_currency': isCurrency,
    });
  }

  NetworkAssetsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? contractAddressHex,
      Value<int>? decimals,
      Value<String?>? logoUrl,
      Value<String?>? name,
      Value<int>? network,
      Value<String>? symbol,
      Value<bool>? isCurrency}) {
    return NetworkAssetsCompanion(
      id: id ?? this.id,
      contractAddressHex: contractAddressHex ?? this.contractAddressHex,
      decimals: decimals ?? this.decimals,
      logoUrl: logoUrl ?? this.logoUrl,
      name: name ?? this.name,
      network: network ?? this.network,
      symbol: symbol ?? this.symbol,
      isCurrency: isCurrency ?? this.isCurrency,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contractAddressHex.present) {
      map['contract_address_hex'] = Variable<String>(contractAddressHex.value);
    }
    if (decimals.present) {
      map['decimals'] = Variable<int>(decimals.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (network.present) {
      map['network'] = Variable<int>(network.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (isCurrency.present) {
      map['is_currency'] = Variable<bool>(isCurrency.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NetworkAssetsCompanion(')
          ..write('id: $id, ')
          ..write('contractAddressHex: $contractAddressHex, ')
          ..write('decimals: $decimals, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('name: $name, ')
          ..write('network: $network, ')
          ..write('symbol: $symbol, ')
          ..write('isCurrency: $isCurrency')
          ..write(')'))
        .toString();
  }
}

class $WalletNotificationsTable extends WalletNotifications
    with TableInfo<$WalletNotificationsTable, WalletNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletNotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailsMeta =
      const VerificationMeta('details');
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
      'details', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<NotificationType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<NotificationType>(
              $WalletNotificationsTable.$convertertype);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, createdAt, title, details, type, isRead];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_notifications';
  @override
  VerificationContext validateIntegrity(Insertable<WalletNotification> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('details')) {
      context.handle(_detailsMeta,
          details.isAcceptableOrUnknown(data['details']!, _detailsMeta));
    } else if (isInserting) {
      context.missing(_detailsMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletNotification(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      details: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details'])!,
      type: $WalletNotificationsTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
    );
  }

  @override
  $WalletNotificationsTable createAlias(String alias) {
    return $WalletNotificationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<NotificationType, int, int> $convertertype =
      const EnumIndexConverter<NotificationType>(NotificationType.values);
}

class WalletNotification extends DataClass
    implements Insertable<WalletNotification> {
  final int id;
  final DateTime createdAt;
  final String title;
  final String details;
  final NotificationType type;
  final bool isRead;
  const WalletNotification(
      {required this.id,
      required this.createdAt,
      required this.title,
      required this.details,
      required this.type,
      required this.isRead});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['title'] = Variable<String>(title);
    map['details'] = Variable<String>(details);
    {
      map['type'] =
          Variable<int>($WalletNotificationsTable.$convertertype.toSql(type));
    }
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  WalletNotificationsCompanion toCompanion(bool nullToAbsent) {
    return WalletNotificationsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      title: Value(title),
      details: Value(details),
      type: Value(type),
      isRead: Value(isRead),
    );
  }

  factory WalletNotification.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletNotification(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      title: serializer.fromJson<String>(json['title']),
      details: serializer.fromJson<String>(json['details']),
      type: $WalletNotificationsTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'title': serializer.toJson<String>(title),
      'details': serializer.toJson<String>(details),
      'type': serializer
          .toJson<int>($WalletNotificationsTable.$convertertype.toJson(type)),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  WalletNotification copyWith(
          {int? id,
          DateTime? createdAt,
          String? title,
          String? details,
          NotificationType? type,
          bool? isRead}) =>
      WalletNotification(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        title: title ?? this.title,
        details: details ?? this.details,
        type: type ?? this.type,
        isRead: isRead ?? this.isRead,
      );
  WalletNotification copyWithCompanion(WalletNotificationsCompanion data) {
    return WalletNotification(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      title: data.title.present ? data.title.value : this.title,
      details: data.details.present ? data.details.value : this.details,
      type: data.type.present ? data.type.value : this.type,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletNotification(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('title: $title, ')
          ..write('details: $details, ')
          ..write('type: $type, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, title, details, type, isRead);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletNotification &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.title == this.title &&
          other.details == this.details &&
          other.type == this.type &&
          other.isRead == this.isRead);
}

class WalletNotificationsCompanion extends UpdateCompanion<WalletNotification> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> title;
  final Value<String> details;
  final Value<NotificationType> type;
  final Value<bool> isRead;
  const WalletNotificationsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.title = const Value.absent(),
    this.details = const Value.absent(),
    this.type = const Value.absent(),
    this.isRead = const Value.absent(),
  });
  WalletNotificationsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String title,
    required String details,
    required NotificationType type,
    this.isRead = const Value.absent(),
  })  : title = Value(title),
        details = Value(details),
        type = Value(type);
  static Insertable<WalletNotification> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? title,
    Expression<String>? details,
    Expression<int>? type,
    Expression<bool>? isRead,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (title != null) 'title': title,
      if (details != null) 'details': details,
      if (type != null) 'type': type,
      if (isRead != null) 'is_read': isRead,
    });
  }

  WalletNotificationsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<String>? title,
      Value<String>? details,
      Value<NotificationType>? type,
      Value<bool>? isRead}) {
    return WalletNotificationsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      details: details ?? this.details,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
          $WalletNotificationsTable.$convertertype.toSql(type.value));
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('title: $title, ')
          ..write('details: $details, ')
          ..write('type: $type, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $AppAddressesTable appAddresses = $AppAddressesTable(this);
  late final $AppNetworksTable appNetworks = $AppNetworksTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $EthereumTxsTable ethereumTxs = $EthereumTxsTable(this);
  late final $NetworkAssetsTable networkAssets = $NetworkAssetsTable(this);
  late final $WalletNotificationsTable walletNotifications =
      $WalletNotificationsTable(this);
  late final AppAddressesDao appAddressesDao =
      AppAddressesDao(this as Database);
  late final AppNetworksDao appNetworksDao = AppNetworksDao(this as Database);
  late final BookmarksDao bookmarksDao = BookmarksDao(this as Database);
  late final EthereumTxsDao ethereumTxsDao = EthereumTxsDao(this as Database);
  late final NetworkAssetsDao networkAssetsDao =
      NetworkAssetsDao(this as Database);
  late final WalletNotificationsDao walletNotificationsDao =
      WalletNotificationsDao(this as Database);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        appAddresses,
        appNetworks,
        bookmarks,
        ethereumTxs,
        networkAssets,
        walletNotifications
      ];
}

typedef $$AppAddressesTableCreateCompanionBuilder = AppAddressesCompanion
    Function({
  Value<int> id,
  required int index,
  required BlockChain blockChain,
  required String hex,
  required String label,
  Value<int?> bitcoinNetVersion,
});
typedef $$AppAddressesTableUpdateCompanionBuilder = AppAddressesCompanion
    Function({
  Value<int> id,
  Value<int> index,
  Value<BlockChain> blockChain,
  Value<String> hex,
  Value<String> label,
  Value<int?> bitcoinNetVersion,
});

class $$AppAddressesTableFilterComposer
    extends FilterComposer<_$Database, $AppAddressesTable> {
  $$AppAddressesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get index => $state.composableBuilder(
      column: $state.table.index,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<BlockChain, BlockChain, int> get blockChain =>
      $state.composableBuilder(
          column: $state.table.blockChain,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<String> get hex => $state.composableBuilder(
      column: $state.table.hex,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get label => $state.composableBuilder(
      column: $state.table.label,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get bitcoinNetVersion => $state.composableBuilder(
      column: $state.table.bitcoinNetVersion,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AppAddressesTableOrderingComposer
    extends OrderingComposer<_$Database, $AppAddressesTable> {
  $$AppAddressesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get index => $state.composableBuilder(
      column: $state.table.index,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get blockChain => $state.composableBuilder(
      column: $state.table.blockChain,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get hex => $state.composableBuilder(
      column: $state.table.hex,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get label => $state.composableBuilder(
      column: $state.table.label,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get bitcoinNetVersion => $state.composableBuilder(
      column: $state.table.bitcoinNetVersion,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$AppAddressesTableTableManager extends RootTableManager<
    _$Database,
    $AppAddressesTable,
    AppAddress,
    $$AppAddressesTableFilterComposer,
    $$AppAddressesTableOrderingComposer,
    $$AppAddressesTableCreateCompanionBuilder,
    $$AppAddressesTableUpdateCompanionBuilder,
    (AppAddress, BaseReferences<_$Database, $AppAddressesTable, AppAddress>),
    AppAddress,
    PrefetchHooks Function()> {
  $$AppAddressesTableTableManager(_$Database db, $AppAddressesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AppAddressesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AppAddressesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> index = const Value.absent(),
            Value<BlockChain> blockChain = const Value.absent(),
            Value<String> hex = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<int?> bitcoinNetVersion = const Value.absent(),
          }) =>
              AppAddressesCompanion(
            id: id,
            index: index,
            blockChain: blockChain,
            hex: hex,
            label: label,
            bitcoinNetVersion: bitcoinNetVersion,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int index,
            required BlockChain blockChain,
            required String hex,
            required String label,
            Value<int?> bitcoinNetVersion = const Value.absent(),
          }) =>
              AppAddressesCompanion.insert(
            id: id,
            index: index,
            blockChain: blockChain,
            hex: hex,
            label: label,
            bitcoinNetVersion: bitcoinNetVersion,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppAddressesTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $AppAddressesTable,
    AppAddress,
    $$AppAddressesTableFilterComposer,
    $$AppAddressesTableOrderingComposer,
    $$AppAddressesTableCreateCompanionBuilder,
    $$AppAddressesTableUpdateCompanionBuilder,
    (AppAddress, BaseReferences<_$Database, $AppAddressesTable, AppAddress>),
    AppAddress,
    PrefetchHooks Function()>;
typedef $$AppNetworksTableCreateCompanionBuilder = AppNetworksCompanion
    Function({
  required AppNetworkAssetEntries assets,
  Value<int> id,
  required BlockChain blockChain,
  required String blockExplorerUrl,
  Value<int?> chainId,
  required String currencySymbol,
  required String name,
  required String url,
  required NetworkType type,
});
typedef $$AppNetworksTableUpdateCompanionBuilder = AppNetworksCompanion
    Function({
  Value<AppNetworkAssetEntries> assets,
  Value<int> id,
  Value<BlockChain> blockChain,
  Value<String> blockExplorerUrl,
  Value<int?> chainId,
  Value<String> currencySymbol,
  Value<String> name,
  Value<String> url,
  Value<NetworkType> type,
});

final class $$AppNetworksTableReferences
    extends BaseReferences<_$Database, $AppNetworksTable, AppNetwork> {
  $$AppNetworksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EthereumTxsTable, List<EthereumTx>>
      _ethereumTxsRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
          db.ethereumTxs,
          aliasName:
              $_aliasNameGenerator(db.appNetworks.id, db.ethereumTxs.network));

  $$EthereumTxsTableProcessedTableManager get ethereumTxsRefs {
    final manager = $$EthereumTxsTableTableManager($_db, $_db.ethereumTxs)
        .filter((f) => f.network.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_ethereumTxsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$NetworkAssetsTable, List<NetworkAsset>>
      _networkAssetsRefsTable(_$Database db) =>
          MultiTypedResultKey.fromTable(db.networkAssets,
              aliasName: $_aliasNameGenerator(
                  db.appNetworks.id, db.networkAssets.network));

  $$NetworkAssetsTableProcessedTableManager get networkAssetsRefs {
    final manager = $$NetworkAssetsTableTableManager($_db, $_db.networkAssets)
        .filter((f) => f.network.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_networkAssetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AppNetworksTableFilterComposer
    extends FilterComposer<_$Database, $AppNetworksTable> {
  $$AppNetworksTableFilterComposer(super.$state);
  ColumnWithTypeConverterFilters<AppNetworkAssetEntries, AppNetworkAssetEntries,
          String>
      get assets => $state.composableBuilder(
          column: $state.table.assets,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<BlockChain, BlockChain, int> get blockChain =>
      $state.composableBuilder(
          column: $state.table.blockChain,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<String> get blockExplorerUrl => $state.composableBuilder(
      column: $state.table.blockExplorerUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get chainId => $state.composableBuilder(
      column: $state.table.chainId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get currencySymbol => $state.composableBuilder(
      column: $state.table.currencySymbol,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<NetworkType, NetworkType, int> get type =>
      $state.composableBuilder(
          column: $state.table.type,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ComposableFilter ethereumTxsRefs(
      ComposableFilter Function($$EthereumTxsTableFilterComposer f) f) {
    final $$EthereumTxsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.ethereumTxs,
        getReferencedColumn: (t) => t.network,
        builder: (joinBuilder, parentComposers) =>
            $$EthereumTxsTableFilterComposer(ComposerState($state.db,
                $state.db.ethereumTxs, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter networkAssetsRefs(
      ComposableFilter Function($$NetworkAssetsTableFilterComposer f) f) {
    final $$NetworkAssetsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.networkAssets,
        getReferencedColumn: (t) => t.network,
        builder: (joinBuilder, parentComposers) =>
            $$NetworkAssetsTableFilterComposer(ComposerState($state.db,
                $state.db.networkAssets, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$AppNetworksTableOrderingComposer
    extends OrderingComposer<_$Database, $AppNetworksTable> {
  $$AppNetworksTableOrderingComposer(super.$state);
  ColumnOrderings<String> get assets => $state.composableBuilder(
      column: $state.table.assets,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get blockChain => $state.composableBuilder(
      column: $state.table.blockChain,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get blockExplorerUrl => $state.composableBuilder(
      column: $state.table.blockExplorerUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get chainId => $state.composableBuilder(
      column: $state.table.chainId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get currencySymbol => $state.composableBuilder(
      column: $state.table.currencySymbol,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$AppNetworksTableTableManager extends RootTableManager<
    _$Database,
    $AppNetworksTable,
    AppNetwork,
    $$AppNetworksTableFilterComposer,
    $$AppNetworksTableOrderingComposer,
    $$AppNetworksTableCreateCompanionBuilder,
    $$AppNetworksTableUpdateCompanionBuilder,
    (AppNetwork, $$AppNetworksTableReferences),
    AppNetwork,
    PrefetchHooks Function({bool ethereumTxsRefs, bool networkAssetsRefs})> {
  $$AppNetworksTableTableManager(_$Database db, $AppNetworksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AppNetworksTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AppNetworksTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<AppNetworkAssetEntries> assets = const Value.absent(),
            Value<int> id = const Value.absent(),
            Value<BlockChain> blockChain = const Value.absent(),
            Value<String> blockExplorerUrl = const Value.absent(),
            Value<int?> chainId = const Value.absent(),
            Value<String> currencySymbol = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<NetworkType> type = const Value.absent(),
          }) =>
              AppNetworksCompanion(
            assets: assets,
            id: id,
            blockChain: blockChain,
            blockExplorerUrl: blockExplorerUrl,
            chainId: chainId,
            currencySymbol: currencySymbol,
            name: name,
            url: url,
            type: type,
          ),
          createCompanionCallback: ({
            required AppNetworkAssetEntries assets,
            Value<int> id = const Value.absent(),
            required BlockChain blockChain,
            required String blockExplorerUrl,
            Value<int?> chainId = const Value.absent(),
            required String currencySymbol,
            required String name,
            required String url,
            required NetworkType type,
          }) =>
              AppNetworksCompanion.insert(
            assets: assets,
            id: id,
            blockChain: blockChain,
            blockExplorerUrl: blockExplorerUrl,
            chainId: chainId,
            currencySymbol: currencySymbol,
            name: name,
            url: url,
            type: type,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AppNetworksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {ethereumTxsRefs = false, networkAssetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ethereumTxsRefs) db.ethereumTxs,
                if (networkAssetsRefs) db.networkAssets
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ethereumTxsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$AppNetworksTableReferences
                            ._ethereumTxsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AppNetworksTableReferences(db, table, p0)
                                .ethereumTxsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.network == item.id),
                        typedResults: items),
                  if (networkAssetsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$AppNetworksTableReferences
                            ._networkAssetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AppNetworksTableReferences(db, table, p0)
                                .networkAssetsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.network == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AppNetworksTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $AppNetworksTable,
    AppNetwork,
    $$AppNetworksTableFilterComposer,
    $$AppNetworksTableOrderingComposer,
    $$AppNetworksTableCreateCompanionBuilder,
    $$AppNetworksTableUpdateCompanionBuilder,
    (AppNetwork, $$AppNetworksTableReferences),
    AppNetwork,
    PrefetchHooks Function({bool ethereumTxsRefs, bool networkAssetsRefs})>;
typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  Value<String?> faviconUrl,
  required String title,
  required String url,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  Value<String?> faviconUrl,
  Value<String> title,
  Value<String> url,
});

class $$BookmarksTableFilterComposer
    extends FilterComposer<_$Database, $BookmarksTable> {
  $$BookmarksTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get faviconUrl => $state.composableBuilder(
      column: $state.table.faviconUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$BookmarksTableOrderingComposer
    extends OrderingComposer<_$Database, $BookmarksTable> {
  $$BookmarksTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get faviconUrl => $state.composableBuilder(
      column: $state.table.faviconUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$BookmarksTableTableManager extends RootTableManager<
    _$Database,
    $BookmarksTable,
    Bookmark,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (Bookmark, BaseReferences<_$Database, $BookmarksTable, Bookmark>),
    Bookmark,
    PrefetchHooks Function()> {
  $$BookmarksTableTableManager(_$Database db, $BookmarksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$BookmarksTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$BookmarksTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> faviconUrl = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> url = const Value.absent(),
          }) =>
              BookmarksCompanion(
            id: id,
            faviconUrl: faviconUrl,
            title: title,
            url: url,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> faviconUrl = const Value.absent(),
            required String title,
            required String url,
          }) =>
              BookmarksCompanion.insert(
            id: id,
            faviconUrl: faviconUrl,
            title: title,
            url: url,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookmarksTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $BookmarksTable,
    Bookmark,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (Bookmark, BaseReferences<_$Database, $BookmarksTable, Bookmark>),
    Bookmark,
    PrefetchHooks Function()>;
typedef $$EthereumTxsTableCreateCompanionBuilder = EthereumTxsCompanion
    Function({
  Value<int> id,
  required String from,
  required int gas,
  required String hash,
  required String input,
  required int network,
  Value<String?> to,
  required BigInt value,
  required DateTime txDateTime,
  required EthereumTransactionStatus status,
});
typedef $$EthereumTxsTableUpdateCompanionBuilder = EthereumTxsCompanion
    Function({
  Value<int> id,
  Value<String> from,
  Value<int> gas,
  Value<String> hash,
  Value<String> input,
  Value<int> network,
  Value<String?> to,
  Value<BigInt> value,
  Value<DateTime> txDateTime,
  Value<EthereumTransactionStatus> status,
});

final class $$EthereumTxsTableReferences
    extends BaseReferences<_$Database, $EthereumTxsTable, EthereumTx> {
  $$EthereumTxsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppNetworksTable _networkTable(_$Database db) =>
      db.appNetworks.createAlias(
          $_aliasNameGenerator(db.ethereumTxs.network, db.appNetworks.id));

  $$AppNetworksTableProcessedTableManager? get network {
    if ($_item.network == null) return null;
    final manager = $$AppNetworksTableTableManager($_db, $_db.appNetworks)
        .filter((f) => f.id($_item.network!));
    final item = $_typedResult.readTableOrNull(_networkTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EthereumTxsTableFilterComposer
    extends FilterComposer<_$Database, $EthereumTxsTable> {
  $$EthereumTxsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get from => $state.composableBuilder(
      column: $state.table.from,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get gas => $state.composableBuilder(
      column: $state.table.gas,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get hash => $state.composableBuilder(
      column: $state.table.hash,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get input => $state.composableBuilder(
      column: $state.table.input,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get to => $state.composableBuilder(
      column: $state.table.to,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<BigInt> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get txDateTime => $state.composableBuilder(
      column: $state.table.txDateTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<EthereumTransactionStatus,
          EthereumTransactionStatus, int>
      get status => $state.composableBuilder(
          column: $state.table.status,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  $$AppNetworksTableFilterComposer get network {
    final $$AppNetworksTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.network,
        referencedTable: $state.db.appNetworks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$AppNetworksTableFilterComposer(ComposerState($state.db,
                $state.db.appNetworks, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$EthereumTxsTableOrderingComposer
    extends OrderingComposer<_$Database, $EthereumTxsTable> {
  $$EthereumTxsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get from => $state.composableBuilder(
      column: $state.table.from,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get gas => $state.composableBuilder(
      column: $state.table.gas,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get hash => $state.composableBuilder(
      column: $state.table.hash,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get input => $state.composableBuilder(
      column: $state.table.input,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get to => $state.composableBuilder(
      column: $state.table.to,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<BigInt> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get txDateTime => $state.composableBuilder(
      column: $state.table.txDateTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$AppNetworksTableOrderingComposer get network {
    final $$AppNetworksTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.network,
        referencedTable: $state.db.appNetworks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$AppNetworksTableOrderingComposer(ComposerState($state.db,
                $state.db.appNetworks, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$EthereumTxsTableTableManager extends RootTableManager<
    _$Database,
    $EthereumTxsTable,
    EthereumTx,
    $$EthereumTxsTableFilterComposer,
    $$EthereumTxsTableOrderingComposer,
    $$EthereumTxsTableCreateCompanionBuilder,
    $$EthereumTxsTableUpdateCompanionBuilder,
    (EthereumTx, $$EthereumTxsTableReferences),
    EthereumTx,
    PrefetchHooks Function({bool network})> {
  $$EthereumTxsTableTableManager(_$Database db, $EthereumTxsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$EthereumTxsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$EthereumTxsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> from = const Value.absent(),
            Value<int> gas = const Value.absent(),
            Value<String> hash = const Value.absent(),
            Value<String> input = const Value.absent(),
            Value<int> network = const Value.absent(),
            Value<String?> to = const Value.absent(),
            Value<BigInt> value = const Value.absent(),
            Value<DateTime> txDateTime = const Value.absent(),
            Value<EthereumTransactionStatus> status = const Value.absent(),
          }) =>
              EthereumTxsCompanion(
            id: id,
            from: from,
            gas: gas,
            hash: hash,
            input: input,
            network: network,
            to: to,
            value: value,
            txDateTime: txDateTime,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String from,
            required int gas,
            required String hash,
            required String input,
            required int network,
            Value<String?> to = const Value.absent(),
            required BigInt value,
            required DateTime txDateTime,
            required EthereumTransactionStatus status,
          }) =>
              EthereumTxsCompanion.insert(
            id: id,
            from: from,
            gas: gas,
            hash: hash,
            input: input,
            network: network,
            to: to,
            value: value,
            txDateTime: txDateTime,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EthereumTxsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({network = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (network) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.network,
                    referencedTable:
                        $$EthereumTxsTableReferences._networkTable(db),
                    referencedColumn:
                        $$EthereumTxsTableReferences._networkTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$EthereumTxsTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $EthereumTxsTable,
    EthereumTx,
    $$EthereumTxsTableFilterComposer,
    $$EthereumTxsTableOrderingComposer,
    $$EthereumTxsTableCreateCompanionBuilder,
    $$EthereumTxsTableUpdateCompanionBuilder,
    (EthereumTx, $$EthereumTxsTableReferences),
    EthereumTx,
    PrefetchHooks Function({bool network})>;
typedef $$NetworkAssetsTableCreateCompanionBuilder = NetworkAssetsCompanion
    Function({
  Value<int> id,
  Value<String?> contractAddressHex,
  required int decimals,
  Value<String?> logoUrl,
  Value<String?> name,
  required int network,
  required String symbol,
  required bool isCurrency,
});
typedef $$NetworkAssetsTableUpdateCompanionBuilder = NetworkAssetsCompanion
    Function({
  Value<int> id,
  Value<String?> contractAddressHex,
  Value<int> decimals,
  Value<String?> logoUrl,
  Value<String?> name,
  Value<int> network,
  Value<String> symbol,
  Value<bool> isCurrency,
});

final class $$NetworkAssetsTableReferences
    extends BaseReferences<_$Database, $NetworkAssetsTable, NetworkAsset> {
  $$NetworkAssetsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AppNetworksTable _networkTable(_$Database db) =>
      db.appNetworks.createAlias(
          $_aliasNameGenerator(db.networkAssets.network, db.appNetworks.id));

  $$AppNetworksTableProcessedTableManager? get network {
    if ($_item.network == null) return null;
    final manager = $$AppNetworksTableTableManager($_db, $_db.appNetworks)
        .filter((f) => f.id($_item.network!));
    final item = $_typedResult.readTableOrNull(_networkTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$NetworkAssetsTableFilterComposer
    extends FilterComposer<_$Database, $NetworkAssetsTable> {
  $$NetworkAssetsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get contractAddressHex => $state.composableBuilder(
      column: $state.table.contractAddressHex,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get decimals => $state.composableBuilder(
      column: $state.table.decimals,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get logoUrl => $state.composableBuilder(
      column: $state.table.logoUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get symbol => $state.composableBuilder(
      column: $state.table.symbol,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isCurrency => $state.composableBuilder(
      column: $state.table.isCurrency,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$AppNetworksTableFilterComposer get network {
    final $$AppNetworksTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.network,
        referencedTable: $state.db.appNetworks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$AppNetworksTableFilterComposer(ComposerState($state.db,
                $state.db.appNetworks, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$NetworkAssetsTableOrderingComposer
    extends OrderingComposer<_$Database, $NetworkAssetsTable> {
  $$NetworkAssetsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get contractAddressHex => $state.composableBuilder(
      column: $state.table.contractAddressHex,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get decimals => $state.composableBuilder(
      column: $state.table.decimals,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get logoUrl => $state.composableBuilder(
      column: $state.table.logoUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get symbol => $state.composableBuilder(
      column: $state.table.symbol,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isCurrency => $state.composableBuilder(
      column: $state.table.isCurrency,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$AppNetworksTableOrderingComposer get network {
    final $$AppNetworksTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.network,
        referencedTable: $state.db.appNetworks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$AppNetworksTableOrderingComposer(ComposerState($state.db,
                $state.db.appNetworks, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$NetworkAssetsTableTableManager extends RootTableManager<
    _$Database,
    $NetworkAssetsTable,
    NetworkAsset,
    $$NetworkAssetsTableFilterComposer,
    $$NetworkAssetsTableOrderingComposer,
    $$NetworkAssetsTableCreateCompanionBuilder,
    $$NetworkAssetsTableUpdateCompanionBuilder,
    (NetworkAsset, $$NetworkAssetsTableReferences),
    NetworkAsset,
    PrefetchHooks Function({bool network})> {
  $$NetworkAssetsTableTableManager(_$Database db, $NetworkAssetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$NetworkAssetsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$NetworkAssetsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> contractAddressHex = const Value.absent(),
            Value<int> decimals = const Value.absent(),
            Value<String?> logoUrl = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<int> network = const Value.absent(),
            Value<String> symbol = const Value.absent(),
            Value<bool> isCurrency = const Value.absent(),
          }) =>
              NetworkAssetsCompanion(
            id: id,
            contractAddressHex: contractAddressHex,
            decimals: decimals,
            logoUrl: logoUrl,
            name: name,
            network: network,
            symbol: symbol,
            isCurrency: isCurrency,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> contractAddressHex = const Value.absent(),
            required int decimals,
            Value<String?> logoUrl = const Value.absent(),
            Value<String?> name = const Value.absent(),
            required int network,
            required String symbol,
            required bool isCurrency,
          }) =>
              NetworkAssetsCompanion.insert(
            id: id,
            contractAddressHex: contractAddressHex,
            decimals: decimals,
            logoUrl: logoUrl,
            name: name,
            network: network,
            symbol: symbol,
            isCurrency: isCurrency,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$NetworkAssetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({network = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (network) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.network,
                    referencedTable:
                        $$NetworkAssetsTableReferences._networkTable(db),
                    referencedColumn:
                        $$NetworkAssetsTableReferences._networkTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$NetworkAssetsTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $NetworkAssetsTable,
    NetworkAsset,
    $$NetworkAssetsTableFilterComposer,
    $$NetworkAssetsTableOrderingComposer,
    $$NetworkAssetsTableCreateCompanionBuilder,
    $$NetworkAssetsTableUpdateCompanionBuilder,
    (NetworkAsset, $$NetworkAssetsTableReferences),
    NetworkAsset,
    PrefetchHooks Function({bool network})>;
typedef $$WalletNotificationsTableCreateCompanionBuilder
    = WalletNotificationsCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  required String title,
  required String details,
  required NotificationType type,
  Value<bool> isRead,
});
typedef $$WalletNotificationsTableUpdateCompanionBuilder
    = WalletNotificationsCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<String> title,
  Value<String> details,
  Value<NotificationType> type,
  Value<bool> isRead,
});

class $$WalletNotificationsTableFilterComposer
    extends FilterComposer<_$Database, $WalletNotificationsTable> {
  $$WalletNotificationsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get details => $state.composableBuilder(
      column: $state.table.details,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<NotificationType, NotificationType, int>
      get type => $state.composableBuilder(
          column: $state.table.type,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<bool> get isRead => $state.composableBuilder(
      column: $state.table.isRead,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$WalletNotificationsTableOrderingComposer
    extends OrderingComposer<_$Database, $WalletNotificationsTable> {
  $$WalletNotificationsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get details => $state.composableBuilder(
      column: $state.table.details,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isRead => $state.composableBuilder(
      column: $state.table.isRead,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$WalletNotificationsTableTableManager extends RootTableManager<
    _$Database,
    $WalletNotificationsTable,
    WalletNotification,
    $$WalletNotificationsTableFilterComposer,
    $$WalletNotificationsTableOrderingComposer,
    $$WalletNotificationsTableCreateCompanionBuilder,
    $$WalletNotificationsTableUpdateCompanionBuilder,
    (
      WalletNotification,
      BaseReferences<_$Database, $WalletNotificationsTable, WalletNotification>
    ),
    WalletNotification,
    PrefetchHooks Function()> {
  $$WalletNotificationsTableTableManager(
      _$Database db, $WalletNotificationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$WalletNotificationsTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$WalletNotificationsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> details = const Value.absent(),
            Value<NotificationType> type = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
          }) =>
              WalletNotificationsCompanion(
            id: id,
            createdAt: createdAt,
            title: title,
            details: details,
            type: type,
            isRead: isRead,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            required String title,
            required String details,
            required NotificationType type,
            Value<bool> isRead = const Value.absent(),
          }) =>
              WalletNotificationsCompanion.insert(
            id: id,
            createdAt: createdAt,
            title: title,
            details: details,
            type: type,
            isRead: isRead,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WalletNotificationsTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $WalletNotificationsTable,
    WalletNotification,
    $$WalletNotificationsTableFilterComposer,
    $$WalletNotificationsTableOrderingComposer,
    $$WalletNotificationsTableCreateCompanionBuilder,
    $$WalletNotificationsTableUpdateCompanionBuilder,
    (
      WalletNotification,
      BaseReferences<_$Database, $WalletNotificationsTable, WalletNotification>
    ),
    WalletNotification,
    PrefetchHooks Function()>;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$AppAddressesTableTableManager get appAddresses =>
      $$AppAddressesTableTableManager(_db, _db.appAddresses);
  $$AppNetworksTableTableManager get appNetworks =>
      $$AppNetworksTableTableManager(_db, _db.appNetworks);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$EthereumTxsTableTableManager get ethereumTxs =>
      $$EthereumTxsTableTableManager(_db, _db.ethereumTxs);
  $$NetworkAssetsTableTableManager get networkAssets =>
      $$NetworkAssetsTableTableManager(_db, _db.networkAssets);
  $$WalletNotificationsTableTableManager get walletNotifications =>
      $$WalletNotificationsTableTableManager(_db, _db.walletNotifications);
}
