import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/services/services.dart';
import 'package:syrius_mobile/utils/constants.dart';

Route? currentRoute;

AppNetwork kSelectedNetwork = AppNetwork.znn;
AppCurrency kSelectedCurrency = AppCurrency.usd;

String? kCurrentNode;
List<String> kDbNodes = [];
List<String> kDefaultNodes = [
  kDefaultNode,
];

String? kSelectedAddress;
List<String> kDefaultAddressList = [];
Map<String, String> kAddressLabelMap = {};

bool kIsStrongboxSupported = false;
BiometricType? kBiometricTypeSupport;
