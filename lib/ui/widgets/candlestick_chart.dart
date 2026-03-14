// Свечной график OHLC: тени (low–high), тела (open–close), зелёные при росте, красные при падении.
import 'package:flutter/material.dart';
import '../../services/stocks_api.dart';

/// Виджет свечного графика по списку [CandlePoint]. Рисует классические японские свечи.
class CandlestickChart extends StatelessWidget {
  final List<CandlePoint> points;
  final double? currentPrice;

  const CandlestickChart({
    super.key,
    required this.points,
    this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    if (points.length == 1) {
      return Center(
        child: Text(
          'Недостаточно данных для графика',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _CandlestickPainter(
            points: points,
            currentPrice: currentPrice,
            upColor: Theme.of(context).colorScheme.primary,
            downColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
    );
  }
}

/// Рисует японские свечи: тень (линия low–high), тело (прямоугольник open–close); цвет по направлению (рост/падение).
class _CandlestickPainter extends CustomPainter {
  final List<CandlePoint> points;
  final double? currentPrice;
  final Color upColor;
  final Color downColor;

  _CandlestickPainter({
    required this.points,
    this.currentPrice,
    required this.upColor,
    required this.downColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Диапазон цен по Y с отступом 5% сверху/снизу.
    final minP = points.map((e) => e.low).reduce((a, b) => a < b ? a : b);
    final maxP = points.map((e) => e.high).reduce((a, b) => a > b ? a : b);
    final span = (maxP - minP).clamp(1e-9, double.infinity);
    final padding = span * 0.05;
    final minY = minP - padding;
    final maxY = maxP + padding;
    final priceSpan = (maxY - minY).clamp(1e-9, double.infinity);

    // Преобразование цены в Y: низ экрана = min, верх = max.
    double priceToY(double price) => size.height * (1 - (price - minY) / priceSpan);

    // Равномерное распределение свечей по ширине; ширина свечи 70% от шага.
    final n = points.length;
    final candleWidth = (size.width / n) * 0.7;
    final gap = size.width / n;
    final halfWidth = candleWidth / 2;

    for (var i = 0; i < n; i++) {
      final c = points[i];
      final x = gap * (i + 0.5);
      final isUp = c.close >= c.open;
      final color = isUp ? upColor : downColor;
      final openY = priceToY(c.open);
      final closeY = priceToY(c.close);
      final highY = priceToY(c.high);
      final lowY = priceToY(c.low);

      // Тень (фитиль): линия от low до high
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), linePaint);

      // Тело свечи: прямоугольник от open до close
      final bodyTop = openY < closeY ? openY : closeY;
      final bodyBottom = openY < closeY ? closeY : openY;
      final bodyHeight = (bodyBottom - bodyTop).clamp(1.0, double.infinity);
      canvas.drawRect(
        Rect.fromLTWH(x - halfWidth, bodyTop, candleWidth, bodyHeight),
        Paint()..color = color,
      );
      // Обводка тела
      canvas.drawRect(
        Rect.fromLTWH(x - halfWidth, bodyTop, candleWidth, bodyHeight),
        Paint()
          ..color = color.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.currentPrice != currentPrice ||
        oldDelegate.upColor != upColor ||
        oldDelegate.downColor != downColor;
  }
}
