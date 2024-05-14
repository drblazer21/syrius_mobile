import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syrius_mobile/model/model.dart';
import 'package:syrius_mobile/utils/utils.dart';

class PageCard extends StatelessWidget {
  final PageCardType type;

  const PageCard({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95.0,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: type.onClick(context),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: kDefaultPageCardLateralPadding,
                  right: type.svgWidth +
                      (type.rightMargin > 0 ? type.rightMargin : 0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      type.title(context),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      type.description(context),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: type.rightMargin,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      type.svgPath,
                      fit: BoxFit.fitWidth,
                      width: type.svgWidth,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
