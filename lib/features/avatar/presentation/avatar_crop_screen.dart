import 'dart:async';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

import '../domain/avatar_expression.dart';

typedef AvatarCropCallback = Future<Uint8List?> Function(Uint8List sourceBytes);

class AvatarCropScreen extends StatefulWidget {
  const AvatarCropScreen({
    super.key,
    required this.expression,
    required this.sourceBytes,
    this.onPerformCrop,
  });

  final AvatarExpression expression;
  final Uint8List sourceBytes;
  final AvatarCropCallback? onPerformCrop;

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  final CropController _cropController = CropController();

  Completer<Uint8List?>? _pendingCropCompleter;
  bool _isSaving = false;
  String? _errorText;

  Future<void> _saveCrop() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    Uint8List? croppedBytes;
    try {
      croppedBytes = await (widget.onPerformCrop?.call(widget.sourceBytes) ??
          _performDefaultCrop());
    } catch (_) {
      croppedBytes = null;
    }

    if (!mounted) {
      return;
    }

    if (croppedBytes == null || croppedBytes.isEmpty) {
      setState(() {
        _isSaving = false;
        _errorText = '사진을 다시 잘라주세요.';
      });
      return;
    }

    Navigator.of(context).pop(croppedBytes);
  }

  Future<Uint8List?> _performDefaultCrop() {
    final completer = Completer<Uint8List?>();
    _pendingCropCompleter = completer;
    _cropController.crop();
    return completer.future;
  }

  void _handleCropResult(CropResult result) {
    final completer = _pendingCropCompleter;
    if (completer == null || completer.isCompleted) {
      return;
    }

    switch (result) {
      case CropSuccess(:final croppedImage):
        completer.complete(croppedImage);
      case CropFailure():
        completer.complete(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.expression.label} 사진 자르기')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.expression.shortPrompt} 사진을 정사각형 안에 맞춰주세요.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: widget.onPerformCrop == null
                        ? Crop(
                            controller: _cropController,
                            image: widget.sourceBytes,
                            aspectRatio: 1,
                            onCropped: _handleCropResult,
                            withCircleUi: false,
                            baseColor: Colors.white,
                            maskColor: Colors.black45,
                            cornerDotBuilder: (size, edgeAlignment) {
                              return DotControl(
                                color: Theme.of(context).colorScheme.primary,
                              );
                            },
                          )
                        : Image.memory(
                            widget.sourceBytes,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorText!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              FilledButton(
                key: const Key('avatar-crop-save'),
                onPressed: _isSaving ? null : _saveCrop,
                child: Text(_isSaving ? '저장 중...' : '이 사진으로 저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
