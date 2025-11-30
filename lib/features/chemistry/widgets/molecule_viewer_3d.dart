import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Advanced 3D Molecular Viewer Widget
/// Displays molecules in 3D space with interactive rotation
class MoleculeViewer3D extends StatefulWidget {
  final Map<String, dynamic> moleculeData;
  final double width;
  final double height;
  final Color backgroundColor;

  const MoleculeViewer3D({
    super.key,
    required this.moleculeData,
    this.width = 500,
    this.height = 500,
    this.backgroundColor = Colors.black,
  });

  @override
  State<MoleculeViewer3D> createState() => _MoleculeViewer3DState();
}

class _MoleculeViewer3DState extends State<MoleculeViewer3D>
    with SingleTickerProviderStateMixin {
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _scale = 1.0;
  Offset _lastPanPosition = Offset.zero;
  late AnimationController _autoRotateController;
  bool _autoRotate = false;

  @override
  void initState() {
    super.initState();
    _autoRotateController =
        AnimationController(duration: const Duration(seconds: 10), vsync: this)
          ..addListener(() {
            if (_autoRotate) {
              setState(() {
                _rotationY = _autoRotateController.value * 2 * math.pi;
              });
            }
          });
  }

  @override
  void dispose() {
    _autoRotateController.dispose();
    super.dispose();
  }

  void _toggleAutoRotate() {
    setState(() {
      _autoRotate = !_autoRotate;
      if (_autoRotate) {
        _autoRotateController.repeat();
      } else {
        _autoRotateController.stop();
      }
    });
  }

  void _resetView() {
    setState(() {
      _rotationX = 0.0;
      _rotationY = 0.0;
      _scale = 1.0;
      _autoRotate = false;
      _autoRotateController.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.cyan.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: GestureDetector(
              onPanStart: (details) {
                _lastPanPosition = details.localPosition;
              },
              onPanUpdate: (details) {
                setState(() {
                  final delta = details.localPosition - _lastPanPosition;
                  _rotationY += delta.dx * 0.01;
                  _rotationX += delta.dy * 0.01;
                  _lastPanPosition = details.localPosition;
                });
              },
              onScaleUpdate: (details) {
                setState(() {
                  _scale = (_scale * details.scale).clamp(0.3, 3.0);
                });
              },
              child: CustomPaint(
                size: Size(widget.width, widget.height),
                painter: _Molecule3DPainter(
                  moleculeData: widget.moleculeData,
                  rotationX: _rotationX,
                  rotationY: _rotationY,
                  scale: _scale,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildControls(),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            icon: Icons.zoom_in,
            label: 'Zoom In',
            onPressed: () {
              setState(() {
                _scale = (_scale * 1.2).clamp(0.3, 3.0);
              });
            },
          ),
          const SizedBox(width: 8),
          _buildControlButton(
            icon: Icons.zoom_out,
            label: 'Zoom Out',
            onPressed: () {
              setState(() {
                _scale = (_scale / 1.2).clamp(0.3, 3.0);
              });
            },
          ),
          const SizedBox(width: 8),
          _buildControlButton(
            icon: _autoRotate ? Icons.pause : Icons.play_arrow,
            label: _autoRotate ? 'Pause' : 'Auto Rotate',
            onPressed: _toggleAutoRotate,
            isActive: _autoRotate,
          ),
          const SizedBox(width: 8),
          _buildControlButton(
            icon: Icons.refresh,
            label: 'Reset',
            onPressed: _resetView,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.cyan.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? Colors.cyan : Colors.white.withOpacity(0.3),
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.cyan : Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _Molecule3DPainter extends CustomPainter {
  final Map<String, dynamic> moleculeData;
  final double rotationX;
  final double rotationY;
  final double scale;

  _Molecule3DPainter({
    required this.moleculeData,
    required this.rotationX,
    required this.rotationY,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Get atoms and bonds from molecule data
    final atoms = moleculeData['atoms'] as List<dynamic>? ?? [];
    final bonds = moleculeData['bonds'] as List<dynamic>? ?? [];

    if (atoms.isEmpty) {
      _drawPlaceholder(canvas, size);
      return;
    }

    // Transform atoms to 3D space
    final transformedAtoms = atoms.map((atom) {
      final x = (atom['x'] as num).toDouble();
      final y = (atom['y'] as num).toDouble();
      final z = (atom['z'] as num?)?.toDouble() ?? 0.0;

      // Apply rotations
      final rotated = _rotate3D(x, y, z, rotationX, rotationY);

      // Project to 2D
      final projected = _project3D(rotated, centerX, centerY, scale);

      return {
        ...atom,
        'screenX': projected['x'],
        'screenY': projected['y'],
        'screenZ': rotated['z'],
      };
    }).toList();

    // Sort atoms by depth (z-coordinate) for proper rendering
    transformedAtoms.sort(
      (a, b) => (a['screenZ'] as double).compareTo(b['screenZ'] as double),
    );

    // Draw bonds first
    for (var bond in bonds) {
      _drawBond3D(canvas, bond, transformedAtoms);
    }

    // Draw atoms
    for (var atom in transformedAtoms) {
      _drawAtom3D(canvas, atom);
    }

    // Draw legend
    _drawLegend(canvas, size);
  }

  Map<String, double> _rotate3D(
    double x,
    double y,
    double z,
    double rx,
    double ry,
  ) {
    // Rotate around X axis
    final cosX = math.cos(rx);
    final sinX = math.sin(rx);
    final y1 = y * cosX - z * sinX;
    final z1 = y * sinX + z * cosX;

    // Rotate around Y axis
    final cosY = math.cos(ry);
    final sinY = math.sin(ry);
    final x2 = x * cosY + z1 * sinY;
    final z2 = -x * sinY + z1 * cosY;

    return {'x': x2, 'y': y1, 'z': z2};
  }

  Map<String, double> _project3D(
    Map<String, double> point,
    double cx,
    double cy,
    double scale,
  ) {
    final perspective = 400.0; // Perspective distance
    final z = point['z']! + 5; // Offset z to avoid division by zero
    final factor = perspective / (perspective + z);

    return {
      'x': cx + (point['x']! * scale * 50 * factor),
      'y': cy + (point['y']! * scale * 50 * factor),
      'depth': factor,
    };
  }

  void _drawBond3D(
    Canvas canvas,
    dynamic bond,
    List<dynamic> transformedAtoms,
  ) {
    final atom1Index = bond['atom1'] as int;
    final atom2Index = bond['atom2'] as int;

    if (atom1Index >= transformedAtoms.length ||
        atom2Index >= transformedAtoms.length) {
      return;
    }

    final atom1 = transformedAtoms.firstWhere(
      (a) => (a['id'] ?? transformedAtoms.indexOf(a)) == atom1Index,
      orElse: () =>
          transformedAtoms[math.min(atom1Index, transformedAtoms.length - 1)],
    );
    final atom2 = transformedAtoms.firstWhere(
      (a) => (a['id'] ?? transformedAtoms.indexOf(a)) == atom2Index,
      orElse: () =>
          transformedAtoms[math.min(atom2Index, transformedAtoms.length - 1)],
    );

    final x1 = atom1['screenX'] as double;
    final y1 = atom1['screenY'] as double;
    final x2 = atom2['screenX'] as double;
    final y2 = atom2['screenY'] as double;

    final depth1 = atom1['screenZ'] as double;
    final depth2 = atom2['screenZ'] as double;
    final avgDepth = (depth1 + depth2) / 2;

    // Adjust bond appearance based on depth
    final opacity = (0.3 + (avgDepth + 5) / 10).clamp(0.3, 1.0);

    final paint = Paint()
      ..color = Colors.grey.withOpacity(opacity)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }

  void _drawAtom3D(Canvas canvas, dynamic atom) {
    final symbol = atom['symbol'] as String;
    final x = atom['screenX'] as double;
    final y = atom['screenY'] as double;
    final depth = atom['screenZ'] as double;

    // Adjust size based on depth
    final depthFactor = (5 + depth) / 10;
    final radius = (15.0 * depthFactor).clamp(8.0, 25.0);

    // Adjust opacity based on depth
    final opacity = (0.5 + depthFactor).clamp(0.5, 1.0);

    final color = _getAtomColor(symbol).withOpacity(opacity);

    // Draw atom sphere with gradient
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(x, y), radius, paint);

    // Add gradient for 3D effect
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.6 * opacity), Colors.transparent],
        center: const Alignment(-0.4, -0.4),
        radius: 0.6,
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));

    canvas.drawCircle(Offset(x, y), radius, gradientPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.3 * opacity)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(x, y), radius, borderPaint);

    // Draw symbol
    if (symbol != 'C' || radius > 12) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: symbol,
          style: TextStyle(
            color: _getAtomTextColor(symbol).withOpacity(opacity),
            fontSize: (12 * depthFactor).clamp(8.0, 14.0),
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

  void _drawPlaceholder(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'No 3D structure data available\nPan to rotate • Pinch to zoom',
        style: TextStyle(color: Colors.white70, fontSize: 16),
        children: [TextSpan(text: '\n\n🧬', style: TextStyle(fontSize: 48))],
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: size.width - 40);
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void _drawLegend(Canvas canvas, Size size) {
    final legendItems = [
      ('C', Colors.grey),
      ('H', Colors.white),
      ('O', Colors.red),
      ('N', Colors.blue),
      ('S', Colors.yellow),
    ];

    double x = 10;
    final y = size.height - 30;

    for (var item in legendItems) {
      final paint = Paint()..color = item.$2;
      canvas.drawCircle(Offset(x, y), 6, paint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: ' ${item.$1}',
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 8, y - 6));

      x += 40;
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
    if (['H', 'C', 'S', 'F'].contains(symbol.toUpperCase())) {
      return Colors.black;
    }
    return Colors.white;
  }

  @override
  bool shouldRepaint(_Molecule3DPainter oldDelegate) {
    return oldDelegate.rotationX != rotationX ||
        oldDelegate.rotationY != rotationY ||
        oldDelegate.scale != scale;
  }
}
