import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shelfstack/core/utils/files_helper.dart';

class ExpandableDynamicImage extends StatelessWidget {
  final String? imageUrl;
  final IconData placeholderIcon;
  final double iconSize;
  final Color iconColor;
  final BoxFit imageFit;
  final String? heroTag;

  const ExpandableDynamicImage({
    super.key,
    required this.imageUrl,
    this.placeholderIcon = Icons.hide_image,
    this.iconSize = 50,
    this.iconColor = Colors.black,
    this.imageFit = BoxFit.cover,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      ImageUrlType urlType = getImageUrlType(imageUrl!);

      // Don't make placeholder clickable
      if (urlType == ImageUrlType.unknown) {
        return _buildPlaceholderImage();
      }

      Widget imageWidget = _buildImageWidget(urlType);

      // Wrap with Hero animation if heroTag is provided
      if (heroTag != null) {
        imageWidget = Hero(tag: heroTag!, child: imageWidget);
      }

      // Make the image tappable to open in fullscreen
      return GestureDetector(
        onTap: () => _openImageViewer(context),
        child: imageWidget,
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildImageWidget(ImageUrlType urlType) {
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
  }

  Widget _buildErrorImage(context, error, stackTrace) {
    return Icon(Icons.broken_image, size: iconSize, color: iconColor);
  }

  Widget _buildPlaceholderImage() {
    return Icon(placeholderIcon, size: iconSize, color: iconColor);
  }

  void _openImageViewer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            _ImageViewerScreen(imageUrl: imageUrl!, heroTag: heroTag),
      ),
    );
  }
}

class _ImageViewerScreen extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;

  const _ImageViewerScreen({required this.imageUrl, this.heroTag});

  @override
  State<_ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<_ImageViewerScreen> {
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      // Reset zoom
      _transformationController.value = Matrix4.identity();
    } else {
      // Zoom in to 2x at the tap position
      final position = _doubleTapDetails!.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..scale(2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageUrlType urlType = getImageUrlType(widget.imageUrl);

    Widget imageWidget = _buildZoomableImage(urlType);

    // Wrap with Hero animation if heroTag is provided
    if (widget.heroTag != null) {
      imageWidget = Hero(tag: widget.heroTag!, child: imageWidget);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onDoubleTapDown: _handleDoubleTapDown,
        onDoubleTap: _handleDoubleTap,
        child: Center(
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 4.0,
            child: imageWidget,
          ),
        ),
      ),
    );
  }

  Widget _buildZoomableImage(ImageUrlType urlType) {
    switch (urlType) {
      case ImageUrlType.network:
        return Image.network(
          widget.imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 100, color: Colors.white),
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
                color: Colors.white,
              ),
            );
          },
        );
      case ImageUrlType.localFile:
        return Image.file(
          File(widget.imageUrl),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 100, color: Colors.white),
        );
      case ImageUrlType.unknown:
        return const Icon(Icons.hide_image, size: 100, color: Colors.white);
    }
  }
}
