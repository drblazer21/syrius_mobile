import 'package:flutter/material.dart';
import 'package:syrius_mobile/blocs/blocs.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/utils/constants.dart';

class BtcEstimateFeeWidget extends StatelessWidget {
  const BtcEstimateFeeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BtcEstimateFeeState>(
      initialData: BtcEstimateFeeInitial(),
      stream: sl.get<BtcEstimateFeeBloc>().stream,
      builder: (_, snapshot) {
        var message = '? sats/vB';

        switch (snapshot.data!) {
          case BtcEstimateFeeInitial _:
            break;
          case BtcEstimateFeeLoaded _:
            final BtcEstimateFeeLoaded fee =
                snapshot.data! as BtcEstimateFeeLoaded;
            message = '${fee.satoshiEstimateFeePerBytes} sats/vB';
          case BtcEstimateFeeError _:
            message =
                'Error: ${(snapshot.data! as BtcEstimateFeeError).message}';
        }
        return Padding(
          padding: const EdgeInsets.only(
            left: kHorizontalPagePaddingDimension / 2,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
