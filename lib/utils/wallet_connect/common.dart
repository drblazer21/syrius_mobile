import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:walletconnect_flutter_v2/apis/core/pairing/utils/pairing_models.dart';

class CommonMethods {
  Future<bool> requestApproval({
    required String text,
    required PairingMetadata dAppMetadata,
}) async {
    final actionWasAccepted = await showDialogWithNoAndYesOptions<bool>(
      context: navState.currentContext!,
      title: dAppMetadata.name,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Approve request from ${dAppMetadata.name}'),
          kVerticalSpacer,
          Image(
            image: NetworkImage(dAppMetadata.icons.first),
            height: 100.0,
            fit: BoxFit.fitHeight,
          ),
          kVerticalSpacer,
          Text(dAppMetadata.description),
          kVerticalSpacer,
          Text(text),
          kVerticalSpacer,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(dAppMetadata.url),
              LinkIcon(
                url: dAppMetadata.url,
              ),
            ],
          ),
        ],
      ),
      onYesButtonPressed: () async {},
      onNoButtonPressed: () {},
    );

    return actionWasAccepted == true;
  }
}
