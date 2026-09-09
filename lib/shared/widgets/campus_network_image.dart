import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CampusNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final IconData fallbackIcon;
  final BoxFit fit;

  const CampusNetworkImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.fallbackIcon = Icons.image_not_supported_rounded,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validUrl = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: theme.colorScheme.outline.withValues(alpha: 0.15),
        child: validUrl
            ? Image.network(
                imageUrl!,
                width: width,
                height: height,
                fit: fit,
                // Restrict decoding buffer to 2x physical pixel density to conserve RAM
                cacheWidth: (width * 2).toInt(),
                cacheHeight: (height * 2).toInt(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => _buildFallback(),
              )
            : _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Icon(
        fallbackIcon,
        size: width * 0.4,
        color: AppColors.textMutedLight,
      ),
    );
  }
}
