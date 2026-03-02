import 'package:flutter/material.dart';

class VerticalText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const VerticalText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveStyle = style ?? const TextStyle(fontSize: 12, color: Colors.black);
        final desiredSize = _measureDesiredSize(text, effectiveStyle);
        final width = constraints.hasBoundedWidth
            ? desiredSize.width.clamp(0.0, constraints.maxWidth)
            : desiredSize.width;
        final height = constraints.hasBoundedHeight
            ? desiredSize.height.clamp(0.0, constraints.maxHeight)
            : desiredSize.height;
        return SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: VerticalTextPainter(text: text, style: effectiveStyle),
          ),
        );
      },
    );
  }
}

class VerticalTextPainter extends CustomPainter {
  final String text;
  final TextStyle style;

  VerticalTextPainter({required this.text, TextStyle? style})
    : style = style ?? const TextStyle(fontSize: 12, color: Colors.black);

  @override
  void paint(Canvas canvas, Size size) {
    if (text.isEmpty) return;

    final lineHeight = _measureLineHeight();
    if (lineHeight <= 0) return;

    final maxLines = (size.height / lineHeight).floor();
    if (maxLines <= 0) return;

    final needsEllipsis = text.length > maxLines;
    final visibleLines = needsEllipsis ? (maxLines - 1).clamp(0, text.length) : text.length;

    var y = 0.0;
    for (var i = 0; i < visibleLines; i++) {
      final tp = _buildCharPainter(text[i]);
      tp.layout();
      final x = (size.width - tp.width) / 2;
      tp.paint(canvas, Offset(x, y));
      y += lineHeight;
      if (y > size.height) break;
    }

    if (needsEllipsis && maxLines > 0) {
      _paintVerticalEllipsis(canvas, size, y, lineHeight);
    }
  }

  TextPainter _buildCharPainter(String char) {
    final mappedChar = _shouldRotate[char] ?? char;
    return TextPainter(
      text: TextSpan(text: mappedChar, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
  }

  double _measureLineHeight() {
    final tp = _buildCharPainter('A');
    tp.layout();
    return tp.height == 0 ? style.fontSize ?? 12 : tp.height;
  }

  void _paintVerticalEllipsis(Canvas canvas, Size size, double startY, double lineHeight) {
    final paint = Paint()..color = style.color ?? Colors.black;
    final radius = (lineHeight * 0.04).clamp(0.8, 2.0);
    final centerX = size.width / 2;
    final gap = radius * 4;
    final topY = (startY + lineHeight / 2) - gap;
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(centerX, topY + (i + 0.5) * gap), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant VerticalTextPainter oldDelegate) {
    return oldDelegate.text != text || oldDelegate.style != style;
  }
}

Size _measureDesiredSize(String text, TextStyle style) {
  if (text.isEmpty) return Size.zero;
  var maxWidth = 0.0;
  var lineHeight = 0.0;
  for (var i = 0; i < text.length; i++) {
    final mappedChar = _shouldRotate[text[i]] ?? text[i];
    final tp = TextPainter(
      text: TextSpan(text: mappedChar, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    if (tp.width > maxWidth) maxWidth = tp.width;
    if (tp.height > lineHeight) lineHeight = tp.height;
  }
  if (lineHeight == 0) {
    lineHeight = style.fontSize ?? 12;
  }
  return Size(maxWidth, lineHeight * text.length);
}

const _shouldRotate = {
  ' ': '　',
  '↑': '→',
  '↓': '←',
  '←': '↑',
  '→': '↓',
  '。': '︒',
  '、': '︑',
  'ー': '丨',
  '─': '丨',
  '-': '丨',
  'ｰ': '丨',
  '_': '丨 ',
  '−': '丨',
  '－': '丨',
  '—': '丨',
  '〜': '丨',
  '～': '丨',
  '／': '＼',
  '…': '︙',
  '‥': '︰',
  '︙': '…',
  '：': '︓',
  ':': '︓',
  '；': '︔',
  ';': '︔',
  '＝': '॥',
  '=': '॥',
  '（': '︵',
  '(': '︵',
  '）': '︶',
  ')': '︶',
  '［': '﹇',
  '[': '﹇',
  '］': '﹈',
  ']': '﹈',
  '｛': '︷',
  '{': '︷',
  '＜': '︿',
  '<': '︿',
  '＞': '﹀',
  '>': '﹀',
  '｝': '︸',
  '}': '︸',
  '「': '﹁',
  '」': '﹂',
  '『': '﹃',
  '』': '﹄',
  '【': '︻',
  '】': '︼',
  '〖': '︗',
  '〗': '︘',
  '｢': '﹁',
  '｣': '﹂',
  ',': '︐',
  '､': '︑',
};
