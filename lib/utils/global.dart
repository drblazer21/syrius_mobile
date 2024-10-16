import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:syrius_mobile/database/app_network_asset_entries.dart';
import 'package:syrius_mobile/database/export.dart';
import 'package:syrius_mobile/model/model.dart';

Route? currentRoute;

AppNetworkWithAssets? kSelectedAppNetworkWithAssets;
AppCurrency kSelectedCurrency = AppCurrency.usd;

AppAddress? kBtcTestSelectedAddress;
AppAddress? kBtcTaprootSelectedAddress;
AppAddress? kSelectedAddress;
AppAddress? kEthSelectedAddress;
List<AppAddress> kBtcTestAddressList = [];
List<AppAddress> kBtcTaprootAddressList = [];
List<AppAddress> kDefaultAddressList = [];
List<AppAddress> kEthDefaultAddressList = [];

bool kIsStrongboxSupported = false;
BiometricType? kBiometricTypeSupport;

int? kNumOfPillars;
