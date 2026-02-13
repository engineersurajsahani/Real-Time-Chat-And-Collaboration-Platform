import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/user_model.dart';

class UserTile extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  final bool isSelected;
  final bool showOnlineStatus;

  const UserTile({
    Key? key,
    required this.user,
    required this.onTap,
    this.isSelected = false,
    this.showOnlineStatus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withOpacity(0.08)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.3)
              : AppTheme.borderColor,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 24,
                child: Text(
                  user.username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            if (showOnlineStatus)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: user.isOnline
                        ? AppTheme.successColor
                        : AppTheme.dividerColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.surfaceColor, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          user.username,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            fontSize: 16,
          ),
        ),
        subtitle: showOnlineStatus
            ? Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: user.isOnline
                        ? AppTheme.successColor
                        : AppTheme.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    user.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: user.isOnline
                          ? AppTheme.successColor
                          : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : null,
        trailing: isSelected
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              )
            : null,
      ),
    );
  }
}
