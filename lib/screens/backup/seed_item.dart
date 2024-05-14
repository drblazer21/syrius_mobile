import 'package:flutter/material.dart';
import 'package:syrius_mobile/utils/utils.dart';

class SeedItem extends StatelessWidget {
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onChange;
  final String text;

  const SeedItem({
    super.key,
    required this.isSelected,
    required this.onChange,
    required this.text,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onChange,
      child: SizedBox(
        width: size.width * 0.28,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: context.defaultCardShapeBorderRadius,
            side: BorderSide(
              color:
                  isSelected ? context.colorScheme.primary : Colors.transparent,
              width: isSelected ? 1.0 : 0.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: isDisabled ? context.colorScheme.outline : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SeedItemImportWallet extends StatelessWidget {
  final bool isDisabled;
  final VoidCallback onChange;
  final String text;

  const SeedItemImportWallet({
    super.key,
    required this.onChange,
    required this.text,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return InkWell(
      borderRadius: BorderRadius.circular(10.0),
      onTap: onChange,
      child: SizedBox(
        width: size.width * 0.28,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: context.colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: context.textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
