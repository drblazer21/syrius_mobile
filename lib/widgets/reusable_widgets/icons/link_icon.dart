import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

class LinkIcon extends IconButton {
  LinkIcon({
    required String url,
    super.key,
  }) : super(
          icon: const Icon(
            Icons.open_in_new,
            size: 10.0,
            color: znnColor,
          ),
          onPressed: () => launchUrl(url),
        );
}
