import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:syrius_mobile/main.dart';
import 'package:syrius_mobile/services/services.dart';
import 'package:syrius_mobile/widgets/widgets.dart';
import 'package:walletconnect_flutter_v2/apis/core/pairing/utils/pairing_models.dart';

class PairingWidget extends StatelessWidget {
  const PairingWidget({
    required this.pairingInfo,
    super.key,
  });

  final PairingInfo pairingInfo;

  @override
  Widget build(BuildContext context) {
    final String? iconUrl = pairingInfo.peerMetadata?.icons.first;
    final String dAppName = pairingInfo.peerMetadata?.name ?? '';
    final String dAppUrl = pairingInfo.peerMetadata?.url ?? '';
    final String pairingTopic = pairingInfo.topic;
    final Widget icon = iconUrl != null
        ? _buildIcon(imageUrl: iconUrl)
        : const SizedBox.shrink();

    return ListTile(
      leading: icon,
      subtitle: _buildDAppUrl(url: dAppUrl),
      title: _buildDAppName(name: dAppName),
      trailing: _buildClearIcon(topic: pairingTopic),
    );
  }

  Widget _buildIcon({required String imageUrl}) {
    return CircleAvatar(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (_, __) => const SyriusLoadingWidget(
            size: 25.0,
            strokeWidth: 2.0,
          ),
        ),
      ),
    );
  }

  Widget _buildDAppName({required String name}) {
    return Text(
      name,
    );
  }

  Widget _buildDAppUrl({required String url}) {
    return Text(
      url,
    );
  }

  Widget _buildClearIcon({required String topic}) {
    return IconButton(
      onPressed: () {
        final IWeb3WalletService walletConnectService =
            sl<IWeb3WalletService>();
        walletConnectService.deactivatePairing(topic: topic);
      },
      icon: const Icon(
        Icons.clear_rounded,
      ),
    );
  }
}
