import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareTextFrom(BuildContext context, String text) async {
  final renderObject = context.findRenderObject();
  final screenSize = MediaQuery.sizeOf(context);
  final origin = renderObject is RenderBox && renderObject.hasSize
      ? renderObject.localToGlobal(Offset.zero) & renderObject.size
      : Rect.fromLTWH(
          screenSize.width / 2,
          screenSize.height / 2,
          1,
          1,
        );

  await Share.share(
    text,
    sharePositionOrigin: origin,
  );
}
