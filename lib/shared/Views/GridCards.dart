import 'package:flutter/material.dart';

import 'Responsive.dart';


class GridCards extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int mobileCount;
  final int nonMobileCount;
  final double mainAxisExtent;

  const GridCards({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.mobileCount = 2,
    this.nonMobileCount = 4,
    this.mainAxisExtent = 200,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isMobile(context)
            ? mobileCount
            : nonMobileCount,
        mainAxisExtent: mainAxisExtent,
      ),
      itemBuilder: itemBuilder,
    );
  }
}