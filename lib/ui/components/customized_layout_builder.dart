import 'dart:math';

import 'package:flutter/material.dart';
import 'package:place_search_and_map/ui/styles_constants_themes/constants.dart';

class CustomizedLayoutBuilder extends StatelessWidget {
  final double horizontalPadding;
  final double verticalPadding;

  const CustomizedLayoutBuilder(
      {Key? key,
      required this.children,
      this.horizontalPadding = kLayoutBuilderPadding,
      this.verticalPadding = kLayoutBuilderPadding})
      : super(key: key);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: min(constraints.maxWidth, kLayoutBuilderMaxWidth),
          padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );
      }),
    );
  }
}
