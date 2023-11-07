import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = (Get.isDarkMode ? Colors.grey[700] : Colors.black.withOpacity(0.7))!
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16.0;

    final squarePaint = Paint()
      ..color = (Get.isDarkMode ? Colors.grey[800] : Colors.grey[50])! // 배경 색과 같은 색으로 한다.
      ..style = PaintingStyle.fill;

    final lineY = size.height / 2;
    final lineWidth = size.width;

    final lineWidthFloor = lineWidth.floor();
    double leftPadding = 0;
    if(lineWidthFloor % 16 < 8) {
      leftPadding = ((lineWidthFloor % 16) + 8) / 2;
    } else {
      leftPadding = ((lineWidthFloor % 16) - 8) / 2;
    }

    const squareSize = 8;
    final numSquares = (lineWidthFloor % 16 < 8)
        ? ((lineWidthFloor - leftPadding * 2) ~/ 16)
        : ((lineWidthFloor - leftPadding * 2) ~/ 16) + 1;

    canvas.drawLine(Offset(0, lineY), Offset(lineWidth, lineY), linePaint);

    for (int i = 0; i < numSquares + 1; i++) {
      final squareX = leftPadding + (i * (squareSize + 8));
      final squareRect = RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(squareX.toDouble(), lineY - squareSize / 2),
            Offset((squareX + squareSize).toDouble(), lineY + squareSize / 2),
          ),
          const Radius.circular(2.7),
      );
      canvas.drawRRect(squareRect, squarePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}