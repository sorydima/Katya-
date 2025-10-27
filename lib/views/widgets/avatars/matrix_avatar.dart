import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MatrixAvatar extends StatelessWidget {
  final String? userId;
  final String? displayName;
  final String? avatarUrl;
  final double size;
  final VoidCallback? onTap;
  final bool showPresence;
  final bool isSelected;
  final bool isHighlighted;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderWidth;
  final BoxFit? fit;
  final bool useDisplayName;
  final String? customTooltip;

  const MatrixAvatar({
    super.key,
    this.userId,
    this.displayName,
    this.avatarUrl,
    this.size = 40.0,
    this.onTap,
    this.showPresence = true,
    this.isSelected = false,
    this.isHighlighted = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderWidth = 0.0,
    this.fit,
    this.useDisplayName = true,
    this.customTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final colorScheme = theme.colorScheme;
    final defaultBg = backgroundColor ?? (isDark ? colorScheme.surface : colorScheme.surfaceContainerHighest);

    final defaultFg = foregroundColor ?? (isDark ? colorScheme.onSurface : colorScheme.onSurfaceVariant);

    final borderColor = isSelected ? colorScheme.primary : (isHighlighted ? colorScheme.secondary : Colors.transparent);

    final avatar = _buildAvatarContent(
      context,
      defaultBg,
      defaultFg,
      borderColor,
    );

    if (onTap == null) return avatar;

    return Tooltip(
      message: customTooltip ?? displayName ?? userId ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: avatar,
      ),
    );
  }

  Widget _buildAvatarContent(
    BuildContext context,
    Color defaultBg,
    Color defaultFg,
    Color borderColor,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth > 0 ? borderWidth : (isSelected ? 2.0 : 0.0),
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: theme.colorScheme.secondary.withOpacity(0.5),
                  blurRadius: 8.0,
                  spreadRadius: 2.0,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Avatar image or initials
          _buildAvatarImageOrInitials(defaultBg, defaultFg),

          // Online status indicator
          if (showPresence && _isUserOnline())
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: defaultBg,
                    width: 2.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarImageOrInitials(Color defaultBg, Color defaultFg) {
    // If no avatar URL, show initials
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return _buildInitials(defaultBg, defaultFg);
    }

    // Try to load the avatar image
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: avatarUrl!,
        width: size,
        height: size,
        fit: fit ?? BoxFit.cover,
        placeholder: (context, url) => _buildInitials(defaultBg, defaultFg),
        errorWidget: (context, url, error) => _buildInitials(defaultBg, defaultFg),
        cacheKey: avatarUrl,
        memCacheWidth: (size * 2).toInt(),
        memCacheHeight: (size * 2).toInt(),
      ),
    );
  }

  Widget _buildInitials(Color bgColor, Color fgColor) {
    // Get initials from display name or user ID
    String initials = '';

    if (useDisplayName && displayName != null && displayName!.isNotEmpty) {
      final nameParts = displayName!.trim().split(' ');
      if (nameParts.length > 1) {
        initials = '${nameParts[0][0]}${nameParts[1][0]}';
      } else if (nameParts[0].isNotEmpty) {
        initials = nameParts[0][0];
      }
    } else if (userId != null && userId!.isNotEmpty) {
      // Fall back to first letter of user ID
      final cleanId = userId!.startsWith('@') ? userId!.substring(1) : userId!;
      if (cleanId.isNotEmpty) {
        initials = cleanId[0].toUpperCase();
      }
    }

    // If we still don't have initials, use a generic icon
    if (initials.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person,
          size: size * 0.6,
          color: fgColor,
        ),
      );
    }

    // Show initials
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: fgColor,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  bool _isUserOnline() {
    // TODO: Implement actual presence checking with Matrix
    // This is a placeholder - in a real app, you'd check the user's presence
    // status from the Matrix client
    return false;
  }
}
