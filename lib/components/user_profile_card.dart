import 'package:cleaning_service_driver/core/utils/context_extensions.dart';
import 'package:cleaning_service_driver/data/models/auth/login_response.dart';
import 'package:flutter/material.dart';

class UserProfileCard extends StatelessWidget {
  final User user;

  final double avatarWidth;
  final double avatarHeight;

  const UserProfileCard({
    Key? key,
    required this.user,
    this.avatarWidth = 72,
    this.avatarHeight = 72,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username ?? "",
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // Bottom small label (repeat role, or whatever subtitle)
                  Row(
                    children: [
                      Text(
                        context.l10n.role,
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 15,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.6)),
                      ),
                      Text(
                        user.role ?? "",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: avatarWidth,
                height: avatarHeight,
                color: theme.colorScheme.primary.withOpacity(0.1),
                child: user.image != null && user.image!.isNotEmpty
                    ? Image.network(user.image!,
                        width: avatarWidth,
                        height: avatarHeight,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const ColoredBox(color: Color(0x11000000)))
                    : Icon(
                        Icons.person,
                        size: avatarWidth * 0.6,
                        color: theme.colorScheme.primary,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
