import 'dart:math';

import 'package:flutter/material.dart';

/// ピンチジェスチャー検出コンポーネント
class BSchedulerGestureDetecter extends StatefulWidget {
  final Function(double? scaleFactor)? onScaleUpdate;
  final Function(double? scaleFactor)? onScaleEnd;
  final Function(double? scaleFactor)? onScaleTriggered;
  final double scaleActionThreshold;

  const BSchedulerGestureDetecter({
    super.key,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onScaleTriggered,
    this.scaleActionThreshold = 200.0,
  });

  @override
  State<BSchedulerGestureDetecter> createState() => _BSchedulerGestureDetecterState();
}

class _BSchedulerGestureDetecterState extends State<BSchedulerGestureDetecter> {
  double get scaleActionThreshold => widget.scaleActionThreshold; // 拡大・縮小完了とみなす距離の閾値

  final Map<int, Offset> _activePointers = {}; // アクティブなポインタ
  bool _scaleActionTriggered = false; // 拡大・縮小アクションが既にトリガーされたか
  double? _startDistance; // ピンチ動作開始時の距離

  bool get _isScaling => _activePointers.length == 2 && !_scaleActionTriggered; // ピンチ動作中判定

  // ポインター間距離
  double? get currentDistance {
    if (_activePointers.length != 2) return null;
    final positions = _activePointers.values.toList();
    final dx = positions[0].dx - positions[1].dx;
    final dy = positions[0].dy - positions[1].dy;
    return sqrt(dx * dx + dy * dy);
  }

  // 拡大・縮小ピクセル
  double? get _delta {
    if (_startDistance == null || currentDistance == null) return null;
    return currentDistance! - _startDistance!;
  }

  // 拡大・縮小率 (-1.0 ~ 1.0)
  double? get _scaleFactor {
    if (_delta == null) return null;
    return (_delta! / scaleActionThreshold).clamp(-1, 1);
  }

  // ピンチ動作開始
  void _getReadyForScale() {
    _scaleActionTriggered = false;
    _startDistance = currentDistance;
  }

  // ピンチ動作終了
  void _initScaleState() {
    _scaleActionTriggered = false;
    _startDistance = null;
  }

  // 完全リセット
  void _resetScaleState() {
    _scaleActionTriggered = false;
    _startDistance = null;
    _activePointers.clear();
  }

  // ポインタ追加
  void _addPointer(int pointerId, Offset position) {
    if (_activePointers.length >= 2) return;
    _activePointers[pointerId] = position;

    if (_activePointers.length == 2) {
      _getReadyForScale();
    } else {
      _initScaleState();
    }
  }

  // ポインタ削除
  void _removePointer(int pointerId) {
    _activePointers.remove(pointerId);
    _initScaleState();
    if (_activePointers.isEmpty && widget.onScaleEnd != null) widget.onScaleEnd!(_scaleFactor);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent, // 下のウィジェットにもイベントを通す
      onPointerDown: (event) => _addPointer(event.pointer, event.position),
      onPointerUp: (event) => _removePointer(event.pointer),
      onPointerMove: (event) {
        if (_activePointers[event.pointer] != null) _activePointers[event.pointer] = event.position;

        // ピンチ動作中でない or 完了後は無視
        if (!_isScaling) return;
        // コールバック
        if (widget.onScaleUpdate != null) widget.onScaleUpdate!(_scaleFactor);

        // 閾値超過で拡大・縮小アクションをトリガー
        if ((_delta ?? 0).abs() >= scaleActionThreshold && widget.onScaleTriggered != null) {
          widget.onScaleTriggered!(_scaleFactor);
          _scaleActionTriggered = true;
        }
      },
      onPointerCancel: (_) => _resetScaleState(),
      child: IgnorePointer(child: Container(color: Colors.transparent)),
    );
  }
}
