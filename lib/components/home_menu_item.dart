import 'package:flutter/material.dart';

class HomeMenuItem extends StatelessWidget {
  const HomeMenuItem({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.onTap,
    this.badge,
    this.large = false,
  });

  final String imageAsset;
  final String title;
  final VoidCallback onTap;
  final String? badge;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: large ? _buildLarge(context) : _buildStandard(context),
        ),
      ),
    );
  }

  Widget _badge(BuildContext context) {
    if (badge == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        badge!,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _icon(BuildContext context) => AspectRatio(
        aspectRatio: 1,
        child: Image.asset(
          imageAsset,
          fit: BoxFit.contain,
          color: Theme.of(context).primaryColor,
        ),
      );

  Widget _buildStandard(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            _icon(context),
            Positioned(
              top: 4,
              right: 4,
              child: _badge(context),
            ),
          ],
        ),
        Expanded(
          child: Text(
            overflow: TextOverflow.visible,
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildLarge(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 72, child: _icon(context)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        _badge(context),
      ],
    );
  }
}
