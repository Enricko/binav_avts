import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class VesselDrawer extends StatefulWidget {
  final String link;
  const VesselDrawer({Key? key, required this.link}) : super(key: key);
  @override
  _VesselDrawerState createState() => _VesselDrawerState();
}

class _VesselDrawerState extends State<VesselDrawer> {
  double length = 0.0;
  double width = 0.0;
  Color bowLineColor = Colors.blue;
  double lengthBowToBreakM = 0.0;
  var load = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        load = false;
      });
    });
    loadVesselParameters();
  }

  Future<void> loadVesselParameters() async {
    try {
      final response = await http.get(Uri.parse(widget.link),headers: {'Accept': 'application/xml'});
      // final xmlString = await rootBundle.("https://api.binav-avts.id/storage/xml/2023_10_06_12_37_50_YDBU04.xml");
      final document = XmlDocument.parse(response.body);

      final vesselShape = document.findAllElements('VesselShape').first;
      length = double.parse(
          vesselShape.getElement('LengthM')!.getAttribute('Value').toString());
      width = double.parse(
          vesselShape.getElement('WidthM')!.getAttribute('Value').toString());

      final bowLine = document.findAllElements('BowLine').first;
      bowLineColor = Color(int.parse(bowLine.getAttribute('Color').toString()));

      lengthBowToBreakM = double.parse(vesselShape
          .getElement('LengthBowToBreakM')!
          .getAttribute('Value')
          .toString());
    } catch (e) {
      print('Error loading XML: $e');
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return load == true
        ? const CircularProgressIndicator()
        : Container(
            width: 300,
            height: 300,
            padding: EdgeInsets.only(top: 75),
            child: CustomPaint(
              size: const Size(200, 200),
              painter: VesselPainter(
                  length, width, lengthBowToBreakM, bowLineColor),
              child: Container(
              ),
            ),
          );
  }
}

class VesselPainter extends CustomPainter {
  final double length;
  final double width;
  final double lengthBowToBreakM;
  final Color bowLineColor;

  VesselPainter(
      this.length, this.width, this.lengthBowToBreakM, this.bowLineColor);

  @override
  void paint(Canvas canvas, Size size) {
    var margin = 15;
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final path = Path();

    // Define the dimensions of the boat's hull (rectangle)
    final scale = 30;

    final lengthBow = (lengthBowToBreakM / length) * 10;
    final lengthBowToBreak = (length - lengthBowToBreakM);

    double hullWidth = double.parse((10 * scale).toString());
    double hullHeight =
        double.parse((3 * scale).toString()); // Adjust this ratio as needed

    // Draw the boat's hull (rectangle)
    path.addRect(Rect.fromPoints(
        const Offset(0, 0), Offset(lengthBow * scale, hullHeight)));

    // Define the dimensions of the boat's bow (triangle)
    final bowWidth = hullWidth; // Adjust this ratio as needed
    final bowHeight = hullHeight; // Adjust this ratio as needed

    // Draw the boat's bow (triangle) on the right side
    path.moveTo(lengthBow * scale, bowHeight / 2);
    path.lineTo(lengthBow * scale, bowHeight / 2 - bowHeight / 2);
    path.lineTo(bowWidth, bowHeight / 2);
    path.lineTo(lengthBow * scale, bowHeight / 2 + bowHeight / 2);
    path.close();

    canvas.drawPath(path, paint);

    // Draw line for vessel Measure
    canvas.drawLine(Offset(0, hullHeight + margin),
        Offset(lengthBow * scale, hullHeight + margin), paint);
    canvas.drawLine(Offset(0, hullHeight + margin - 5),
        Offset(0, hullHeight + margin + 5), paint);
    canvas.drawLine(Offset(lengthBow * scale, hullHeight + margin - 5),
        Offset(lengthBow * scale, hullHeight + margin + 5), paint);
    TextPainter(
      text: TextSpan(
        text: "${lengthBow.toStringAsFixed(2)} m",
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout(maxWidth: size.width)
      ..paint(canvas,
          Offset((lengthBow * scale) / 2 - 20, hullHeight + margin + 5));

    final marginBelowLine = margin * 2.5;

    canvas.drawLine(Offset(0, hullHeight + marginBelowLine),
        Offset(hullWidth, hullHeight + marginBelowLine), paint);
    canvas.drawLine(Offset(0, hullHeight + marginBelowLine - 5),
        Offset(0, hullHeight + marginBelowLine + 5), paint);
    canvas.drawLine(Offset(hullWidth, hullHeight + marginBelowLine - 5),
        Offset(hullWidth, hullHeight + marginBelowLine + 5), paint);
    TextPainter(
      text: TextSpan(
        text: "${length.toStringAsFixed(2)} m",
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout(maxWidth: size.width)
      ..paint(
          canvas, Offset(hullWidth / 2 - 20, hullHeight + marginBelowLine + 5));

    // Draw vertical line for vessel width
    canvas.drawLine(const Offset(0 - 15, 0), Offset(0 - 15, hullHeight), paint);
    canvas.drawLine(
        const Offset(0 - 15 + 5, 0), const Offset(0 - 15 - 5, 0), paint);
    canvas.drawLine(
        Offset(0 - 15 + 5, hullHeight), Offset(0 - 15 - 5, hullHeight), paint);

    // Rotate the width label by 90 degrees
    final textSpan = TextSpan(
      text: "${width.toStringAsFixed(2)} m",
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    canvas.save();
    canvas.translate(0 - 20, hullHeight / 2.5);
    canvas.rotate(-math.pi / 2 * 3);
    textPainter.paint(canvas, Offset(0, 0));
    canvas.restore();

    canvas.drawPath(path, paint);

    // Draw grid lines for width and length
    final gridSpacing = 10; // Adjust the spacing as needed
    final numWidthLines = ((hullHeight * 1.5) / gridSpacing).floor();
    final numLengthLines = ((hullWidth * 1.5) / gridSpacing).floor();

    paint.color = Colors.grey.withOpacity(0.3);
    // Draw vertical grid lines for width
    for (double i = -5; i <= numWidthLines + 5; i++) {
      final x = i * gridSpacing;
      canvas.drawLine(Offset(-((hullWidth * 1.3) - hullWidth), x),
          Offset(hullWidth * 1.3, x), paint);
    }

    // Draw horizontal grid lines for length
    for (double i = -9; i <= numLengthLines - 6; i++) {
      final y = i * gridSpacing;
      canvas.drawLine(Offset(y, -((hullHeight * 1.55) - hullHeight)),
          Offset(y, hullHeight * 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
