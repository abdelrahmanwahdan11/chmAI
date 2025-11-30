import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// Simple 2D Molecular Structure Viewer
/// Displays molecules using ball-and-stick model
class MoleculeViewer2D extends StatefulWidget {
  final Map<String, dynamic> moleculeData;
  final double width;
  final double height;

  const MoleculeViewer2D({
    super.key,
    required this.moleculeData,
    this.width = 400,
    this.height = 400,
  });

  @override
  State<MoleculeViewer2D> createState() => _MoleculeViewer2DState();
}

class _MoleculeViewer2DState extends State<MoleculeViewer2D> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onScaleStart: (details) {
            _lastFocalPoint = details.focalPoint;
          },
          onScaleUpdate: (details) {
            setState(() {
              _scale = (_scale * details.scale).clamp(0.5, 5.0);
              _offset += details.focalPoint - _lastFocalPoint;
              _lastFocalPoint = details.focalPoint;
            });
          },
          child: CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _MoleculePainter(
              moleculeData: widget.moleculeData,
              scale: _scale,
              offset: _offset,
            ),
          ),
        ),
      ),
    );
  }
}

class _MoleculePainter extends CustomPainter {
  final Map<String, dynamic> moleculeData;
  final double scale;
  final Offset offset;

  _MoleculePainter({
    required this.moleculeData,
    required this.scale,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Get atoms and bonds from molecule data
    final atoms = moleculeData['atoms'] as List<dynamic>? ?? [];
    final bonds = moleculeData['bonds'] as List<dynamic>? ?? [];

    // If no structure data, draw a simple representation
    if (atoms.isEmpty) {
      _drawSimpleMolecule(canvas, size);
      return;
    }

    // Draw bonds first (so they appear behind atoms)
    for (var bond in bonds) {
      _drawBond(canvas, bond, centerX, centerY);
    }

    // Draw atoms
    for (var atom in atoms) {
      _drawAtom(canvas, atom, centerX, centerY);
    }

    // Draw legend
    _drawLegend(canvas, size);
  }

  void _drawBond(Canvas canvas, dynamic bond, double centerX, double centerY) {
    final atom1Index = bond['atom1'] as int;
    final atom2Index = bond['atom2'] as int;
    final bondType = (bond['type'] as num).toDouble();

    final atoms = moleculeData['atoms'] as List<dynamic>;
    final atom1 = atoms.firstWhere(
      (a) => a['id'] == atom1Index,
      orElse: () => atoms[atom1Index],
    );
    final atom2 = atoms.firstWhere(
      (a) => a['id'] == atom2Index,
      orElse: () => atoms[atom2Index],
    );

    // RDKit coordinates need scaling
    final x1 = centerX + (atom1['x'] as double) * scale * 40 + offset.dx;
    final y1 =
        centerY - (atom1['y'] as double) * scale * 40 + offset.dy; // Flip Y
    final x2 = centerX + (atom2['x'] as double) * scale * 40 + offset.dx;
    final y2 =
        centerY - (atom2['y'] as double) * scale * 40 + offset.dy; // Flip Y

    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 3.0 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (bondType == 1.0) {
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    } else if (bondType == 2.0 || bondType == 1.5) {
      // Double or Aromatic
      final dx = x2 - x1;
      final dy = y2 - y1;
      final length = math.sqrt(dx * dx + dy * dy);
      final offsetX = -dy / length * 4 * scale;
      final offsetY = dx / length * 4 * scale;

      canvas.drawLine(
        Offset(x1 + offsetX, y1 + offsetY),
        Offset(x2 + offsetX, y2 + offsetY),
        paint,
      );
      canvas.drawLine(
        Offset(x1 - offsetX, y1 - offsetY),
        Offset(x2 - offsetX, y2 - offsetY),
        paint,
      );
    } else if (bondType == 3.0) {
      final dx = x2 - x1;
      final dy = y2 - y1;
      final length = math.sqrt(dx * dx + dy * dy);
      final offsetX = -dy / length * 5 * scale;
      final offsetY = dx / length * 5 * scale;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      canvas.drawLine(
        Offset(x1 + offsetX, y1 + offsetY),
        Offset(x2 + offsetX, y2 + offsetY),
        paint,
      );
      canvas.drawLine(
        Offset(x1 - offsetX, y1 - offsetY),
        Offset(x2 - offsetX, y2 - offsetY),
        paint,
      );
    }
  }

  void _drawAtom(Canvas canvas, dynamic atom, double centerX, double centerY) {
    final symbol = atom['symbol'] as String;
    final x = centerX + (atom['x'] as double) * scale * 40 + offset.dx;
    final y = centerY - (atom['y'] as double) * scale * 40 + offset.dy;

    final color = _getAtomColor(symbol);
    final radius = 12.0 * scale;

    // Draw atom sphere
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), radius, paint);

    // Draw shading/gradient for 3D effect
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.4), Colors.transparent],
        center: const Alignment(-0.3, -0.3),
        radius: 0.5,
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));

    canvas.drawCircle(Offset(x, y), radius, gradientPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(x, y), radius, borderPaint);

    // Draw symbol
    if (symbol != 'C' || scale > 1.5) {
      // Hide Carbon unless zoomed in
      final textPainter = TextPainter(
        text: TextSpan(
          text: symbol,
          style: TextStyle(
            color: _getAtomTextColor(symbol),
            fontSize: 10 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawSimpleMolecule(Canvas canvas, Size size) {
    // Draw a simple example molecule (like water H2O)
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Oxygen atom (center)
    _drawSimpleAtom(
      canvas,
      'O',
      centerX + offset.dx,
      centerY + offset.dy,
      Colors.red,
    );

    // Hydrogen atoms
    final angle1 = -math.pi / 6; // 30 degrees
    final angle2 = math.pi + math.pi / 6; // 210 degrees
    final bondLength = 60.0 * scale;

    final h1X = centerX + math.cos(angle1) * bondLength + offset.dx;
    final h1Y = centerY + math.sin(angle1) * bondLength + offset.dy;
    final h2X = centerX + math.cos(angle2) * bondLength + offset.dx;
    final h2Y = centerY + math.sin(angle2) * bondLength + offset.dy;

    // Draw bonds
    final bondPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2.0 * scale;

    canvas.drawLine(
      Offset(centerX + offset.dx, centerY + offset.dy),
      Offset(h1X, h1Y),
      bondPaint,
    );
    canvas.drawLine(
      Offset(centerX + offset.dx, centerY + offset.dy),
      Offset(h2X, h2Y),
      bondPaint,
    );

    // Draw hydrogen atoms
    _drawSimpleAtom(canvas, 'H', h1X, h1Y, Colors.white);
    _drawSimpleAtom(canvas, 'H', h2X, h2Y, Colors.white);

    // Info text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Example: H₂O (Water)',
        style: TextStyle(color: Colors.cyan, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(10, 10));
  }

  void _drawSimpleAtom(
    Canvas canvas,
    String symbol,
    double x,
    double y,
    Color color,
  ) {
    final radius = 15.0 * scale;

    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(x, y), radius, paint);

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(x, y), radius, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          color: symbol == 'H' ? Colors.black : Colors.white,
          fontSize: 12 * scale,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  void _drawLegend(Canvas canvas, Size size) {
    final legendItems = [
      ('C', Colors.grey),
      ('H', Colors.white),
      ('O', Colors.red),
      ('N', Colors.blue),
    ];

    double x = 10;
    final y = size.height - 30;

    for (var item in legendItems) {
      final paint = Paint()..color = item.$2;
      canvas.drawCircle(Offset(x, y), 6, paint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: ' ${item.$1}',
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 8, y - 6));

      x += 35;
    }
  }

  Color _getAtomColor(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'C':
        return Colors.grey;
      case 'H':
        return Colors.white;
      case 'O':
        return Colors.red;
      case 'N':
        return Colors.blue;
      case 'S':
        return Colors.yellow;
      case 'P':
        return Colors.orange;
      case 'CL':
        return Colors.green;
      case 'BR':
        return Colors.brown;
      case 'F':
        return Colors.lightGreen;
      default:
        return Colors.purple;
    }
  }

  Color _getAtomTextColor(String symbol) {
    if (['H', 'C', 'Cl', 'F'].contains(symbol)) {
      return Colors.black;
    }
    return Colors.white;
  }

  @override
  bool shouldRepaint(_MoleculePainter oldDelegate) {
    return oldDelegate.scale != scale || oldDelegate.offset != offset;
  }
}

/// Controls for the molecule viewer
class MoleculeViewerControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;
  final VoidCallback? onRotate;

  const MoleculeViewerControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
    this.onRotate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.cyan),
            onPressed: onZoomIn,
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.cyan),
            onPressed: onZoomOut,
            tooltip: 'Zoom Out',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.cyan),
            onPressed: onReset,
            tooltip: 'Reset View',
          ),
          if (onRotate != null)
            IconButton(
              icon: const Icon(Icons.rotate_right, color: Colors.cyan),
              onPressed: onRotate,
              tooltip: 'Rotate',
            ),
        ],
      ),
    );
  }
}
