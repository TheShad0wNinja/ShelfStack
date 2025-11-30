import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shelfstack/core/utils/files_helper.dart';

class DynamicImage extends StatelessWidget {
  final String? imageUrl;
  final IconData placeholderIcon;
  final double iconSize;
  final Color iconColor;
  final BoxFit imageFit;


  const DynamicImage({
    super.key,
    required this.imageUrl,
    this.placeholderIcon = Icons.photo_library,
    this.iconSize = 50,
    this.iconColor = Colors.black,
    this.imageFit = BoxFit.cover
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      ImageUrlType urlType = getImageUrlType(imageUrl!);
      switch (urlType) {
        case ImageUrlType.network:
          return Image.network(
            imageUrl!,
            fit: imageFit,
            errorBuilder: (context, error, stackTrace) =>
                _buildErrorImage(context, error, stackTrace),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          );
        case ImageUrlType.localFile:
          return Image.file(
            File(imageUrl!),
            fit: imageFit,
            errorBuilder: (context, error, stackTrace) =>
                _buildErrorImage(context, error, stackTrace),
          );
        case ImageUrlType.unknown:
          return _buildPlaceholderImage();
      }
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildErrorImage(context, error, stackTrace) {
    return Icon(Icons.broken_image, size: iconSize, color: iconColor);
  }

  Widget _buildPlaceholderImage() {
    return Icon(placeholderIcon, size: iconSize, color: iconColor);
  }
}
