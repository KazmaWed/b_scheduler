/// double型の不透明度（0.0〜1.0）をalpha値（0〜255）に変換する拡張
extension OpacityToAlpha on double {
  /// 不透明度からalpha値（0-255）を計算
  int toAlpha() => (255 * this).clamp(0, 255).toInt();
}
