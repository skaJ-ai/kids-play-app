import 'dart:async';

import 'package:flutter/material.dart';

class TapCooldownGate {
  TapCooldownGate({this.cooldown = const Duration(milliseconds: 350)});

  final Duration cooldown;
  bool _locked = false;

  bool get isLocked => _locked;

  Future<void> trigger(FutureOr<void> Function() action) async {
    if (_locked) {
      return;
    }

    _locked = true;
    try {
      await action();
    } finally {
      Future<void>.delayed(cooldown).then((_) {
        _locked = false;
      });
    }
  }
}

class CooldownInkWell extends StatefulWidget {
  const CooldownInkWell({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.cooldown = const Duration(milliseconds: 350),
  });

  final Widget child;
  final FutureOr<void> Function()? onTap;
  final BorderRadius? borderRadius;
  final Duration cooldown;

  @override
  State<CooldownInkWell> createState() => _CooldownInkWellState();
}

class _CooldownInkWellState extends State<CooldownInkWell> {
  bool _locked = false;
  Timer? _unlockTimer;

  Future<void> _handleTap() async {
    if (_locked || widget.onTap == null) {
      return;
    }

    _unlockTimer?.cancel();
    setState(() {
      _locked = true;
    });

    try {
      await widget.onTap?.call();
    } finally {
      _unlockTimer = Timer(widget.cooldown, () {
        if (!mounted) {
          _locked = false;
          return;
        }
        setState(() {
          _locked = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _unlockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: widget.borderRadius,
      onTap: widget.onTap == null || _locked ? null : _handleTap,
      child: widget.child,
    );
  }
}
