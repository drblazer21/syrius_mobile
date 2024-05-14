import 'package:flutter/material.dart';

class SyriusErrorWidget extends StatelessWidget {
  final Object error;

  const SyriusErrorWidget(
    this.error, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(
                Icons.blur_on_sharp,
                size: 40.0,
              ),
              const SizedBox(
                height: 5.0,
              ),
              Text(
                _getErrorText(error.toString()),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getErrorText(String errorText) =>
      errorText.toLowerCase().contains('bad state: the client is closed')
          ? 'Not connected to the network'
          : errorText;
}
