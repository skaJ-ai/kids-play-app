import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../app/services/app_services.dart';
import '../../domain/avatar_expression.dart';

Future<File?> resolveAvatarFaceFile(
  BuildContext context,
  Iterable<AvatarExpression> expressions,
) {
  return AppServicesScope.of(
    context,
  ).avatarPhotoService.resolveBestPhoto(expressions);
}

class AvatarFaceImage extends StatefulWidget {
  const AvatarFaceImage({
    super.key,
    required this.expressions,
    this.fit = BoxFit.contain,
    this.imageKey,
    this.excludeFromSemantics = false,
    this.fallbackAssetPath = placeholderAssetPath,
  });

  static const placeholderAssetPath =
      'assets/generated/images/hero/hero_face.png';

  final Iterable<AvatarExpression> expressions;
  final BoxFit fit;
  final Key? imageKey;
  final bool excludeFromSemantics;
  final String fallbackAssetPath;

  @override
  State<AvatarFaceImage> createState() => _AvatarFaceImageState();
}

class _AvatarFaceImageState extends State<AvatarFaceImage> {
  Future<Uint8List?>? _imageBytesFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _imageBytesFuture = _resolveImageBytes();
  }

  @override
  void didUpdateWidget(covariant AvatarFaceImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _imageBytesFuture = _resolveImageBytes();
  }

  Future<Uint8List?> _resolveImageBytes() async {
    final file = await resolveAvatarFaceFile(context, widget.expressions);
    if (file == null) {
      return null;
    }

    return file.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _imageBytesFuture,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        final ImageProvider<Object> imageProvider =
            bytes != null && bytes.isNotEmpty
            ? MemoryImage(bytes)
            : AssetImage(widget.fallbackAssetPath);

        return Image(
          key: widget.imageKey,
          image: imageProvider,
          excludeFromSemantics: widget.excludeFromSemantics,
          fit: widget.fit,
          gaplessPlayback: true,
        );
      },
    );
  }
}
