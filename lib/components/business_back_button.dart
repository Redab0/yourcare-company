import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BusinessBackButton extends StatelessWidget {
  final String fallbackRouteName;

  const BusinessBackButton({
    super.key,
    required this.fallbackRouteName,
  });

  @override
  Widget build(BuildContext context) {
    return BackButton(
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed(fallbackRouteName);
        }
      },
    );
  }
}
