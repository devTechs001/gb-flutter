import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

enum EditorTool { none, crop, draw, filter }

class MediaEditorScreen extends StatefulWidget {
  final File imageFile;
  final void Function(File editedFile) onSave;

  const MediaEditorScreen({
    super.key,
    required this.imageFile,
    required this.onSave,
  });

  @override
  State<MediaEditorScreen> createState() => _MediaEditorScreenState();
}

class _MediaEditorScreenState extends State<MediaEditorScreen> {
  EditorTool _activeTool = EditorTool.none;
  int _selectedFilter = -1;
  Color _drawColor = Colors.white;
  double _drawSize = 4;
  List<_DrawPoint> _drawingPoints = [];
  final TransformationController _transformController =
      TransformationController();

  final List<ColorFilter> _filters = [
    ColorFilter.matrix(Identity),
    ColorFilter.matrix(Grayscale),
    ColorFilter.matrix(Sepia),
    ColorFilter.matrix(Warm),
    ColorFilter.matrix(Cool),
    ColorFilter.matrix(Vintage),
    ColorFilter.matrix(Invert),
    ColorFilter.matrix(BlueTint),
    ColorFilter.matrix(GreenTint),
    ColorFilter.matrix(RedTint),
  ];

  final List<String> _filterNames = [
    'Original', 'Grayscale', 'Sepia', 'Warm', 'Cool',
    'Vintage', 'Invert', 'Blue', 'Green', 'Red',
  ];

  Rect _cropRect = const Rect.fromLTWH(0, 0, 1, 1);
  bool _isDragging = false;
  String? _dragHandle;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _apply() {
    widget.onSave(widget.imageFile);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D0D1A) : const Color(0xFF1A1A2E);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _activeTool == EditorTool.crop ? 'Crop' :
          _activeTool == EditorTool.draw ? 'Draw' :
          _activeTool == EditorTool.filter ? 'Filter' : 'Edit',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _apply,
            child: const Text(
              'Send',
              style: TextStyle(
                color: Color(0xFF00CEC9),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: RepaintBoundary(
                    child: _buildFilteredImage(),
                  ),
                ),
                if (_activeTool == EditorTool.crop)
                  _buildCropOverlay(),
                if (_activeTool == EditorTool.draw)
                  _buildDrawingOverlay(),
              ],
            ),
          ),
          _buildToolbar(bg),
        ],
      ),
    );
  }

  Widget _buildFilteredImage() {
    Widget image = Image.file(
      widget.imageFile,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (_selectedFilter >= 0 && _selectedFilter < _filters.length) {
      image = ColorFiltered(
        colorFilter: _filters[_selectedFilter],
        child: image,
      );
    }

    return image;
  }

  Widget _buildCropOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return GestureDetector(
          onPanStart: (d) => _onCropDragStart(d, w, h),
          onPanUpdate: (d) => _onCropDragUpdate(d, w, h),
          onPanEnd: (_) => _isDragging = false,
          child: CustomPaint(
            painter: _CropPainter(
              cropRect: Rect.fromLTWH(
                _cropRect.left * w,
                _cropRect.top * h,
                _cropRect.width * w,
                _cropRect.height * h,
              ),
            ),
          ),
        );
      },
    );
  }

  void _onCropDragStart(DragStartDetails d, double w, double h) {
    final x = d.localPosition.dx / w;
    final y = d.localPosition.dy / h;
    _isDragging = true;

    if ((x - _cropRect.left).abs() < 0.04) _dragHandle = 'left';
    else if ((x - _cropRect.right).abs() < 0.04) _dragHandle = 'right';
    else if ((y - _cropRect.top).abs() < 0.04) _dragHandle = 'top';
    else if ((y - _cropRect.bottom).abs() < 0.04) _dragHandle = 'bottom';
    else _dragHandle = 'move';
  }

  void _onCropDragUpdate(DragUpdateDetails d, double w, double h) {
    final dx = d.delta.dx / w;
    final dy = d.delta.dy / h;
    setState(() {
      switch (_dragHandle) {
        case 'left':
          _cropRect = Rect.fromLTRB(
            (_cropRect.left + dx).clamp(0, _cropRect.right - 0.1),
            _cropRect.top,
            _cropRect.right,
            _cropRect.bottom,
          );
        case 'right':
          _cropRect = Rect.fromLTRB(
            _cropRect.left,
            _cropRect.top,
            (_cropRect.right + dx).clamp(_cropRect.left + 0.1, 1),
            _cropRect.bottom,
          );
        case 'top':
          _cropRect = Rect.fromLTRB(
            _cropRect.left,
            (_cropRect.top + dy).clamp(0, _cropRect.bottom - 0.1),
            _cropRect.right,
            _cropRect.bottom,
          );
        case 'bottom':
          _cropRect = Rect.fromLTRB(
            _cropRect.left,
            _cropRect.top,
            _cropRect.right,
            (_cropRect.bottom + dy).clamp(_cropRect.top + 0.1, 1),
          );
        case 'move':
          final rw = _cropRect.width;
          final rh = _cropRect.height;
          final l = (_cropRect.left + dx).clamp(0.0, 1.0 - rw);
          final t = (_cropRect.top + dy).clamp(0.0, 1.0 - rh);
          _cropRect = Rect.fromLTWH(l, t, rw, rh);
      }
    });
  }

  Widget _buildDrawingOverlay() {
    return GestureDetector(
      onPanStart: (d) {
        setState(() {
          _drawingPoints.add(_DrawPoint(
            d.localPosition.dx, d.localPosition.dy, _drawColor, _drawSize, true,
          ));
        });
      },
      onPanUpdate: (d) {
        setState(() {
          _drawingPoints.add(_DrawPoint(
            d.localPosition.dx, d.localPosition.dy, _drawColor, _drawSize, false,
          ));
        });
      },
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _DrawPainter(_drawingPoints),
          size: Size.infinite,
        ),
      ),
    );
  }

  Widget _buildToolbar(Color bg) {
    return Container(
      color: bg,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_activeTool == EditorTool.draw) _buildDrawOptions(),
          if (_activeTool == EditorTool.filter) _buildFilterOptions(),
          if (_activeTool == EditorTool.crop) _buildCropOptions(),
          const SizedBox(height: 4),
          _buildToolIcons(),
        ],
      ),
    );
  }

  Widget _buildDrawOptions() {
    final colors = [
      Colors.white, Colors.black, Colors.red, Colors.orange,
      Colors.yellow, Colors.green, Colors.blue, Colors.purple,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: colors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final sel = _drawColor.value == colors[i].value;
                  return GestureDetector(
                    onTap: () => setState(() => _drawColor = colors[i]),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors[i],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: sel ? const Color(0xFF00CEC9) : Colors.white24,
                          width: sel ? 3 : 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 80,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _drawSize = (_drawSize - 1).clamp(1, 20)),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.remove, color: Colors.white70, size: 16),
                  ),
                ),
                Text('${_drawSize.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                GestureDetector(
                  onTap: () => setState(() => _drawSize = (_drawSize + 1).clamp(1, 20)),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.add, color: Colors.white70, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _drawingPoints.clear()),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.undo, color: Colors.white70, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = _selectedFilter == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? const Color(0xFF00CEC9) : Colors.white24,
                      width: sel ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ColorFiltered(
                    colorFilter: _filters[i],
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _filterNames[i],
                  style: TextStyle(
                    fontSize: 10,
                    color: sel ? const Color(0xFF00CEC9) : Colors.white60,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCropOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _cropAspectBtn('Free', 0),
          const SizedBox(width: 8),
          _cropAspectBtn('1:1', 1),
          const SizedBox(width: 8),
          _cropAspectBtn('4:3', 4 / 3),
          const SizedBox(width: 8),
          _cropAspectBtn('16:9', 16 / 9),
          const SizedBox(width: 8),
          _cropAspectBtn('3:4', 3 / 4),
        ],
      ),
    );
  }

  Widget _cropAspectBtn(String label, double aspect) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (aspect == 0) {
            _cropRect = const Rect.fromLTWH(0, 0, 1, 1);
          } else {
            final cw = _cropRect.width;
            final nh = cw / aspect;
            if (nh <= 1) {
              final t = (1 - nh) / 2;
              _cropRect = Rect.fromLTWH(0, t, 1, nh);
            } else {
              final nw = 1 * aspect;
              final l = (1 - nw) / 2;
              _cropRect = Rect.fromLTWH(l, 0, nw, 1);
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildToolIcons() {
    final tools = [
      (EditorTool.none, Icons.check_circle_outline, 'Done'),
      (EditorTool.crop, Icons.crop, 'Crop'),
      (EditorTool.draw, Icons.brush, 'Draw'),
      (EditorTool.filter, Icons.filter_vintage, 'Filter'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: tools.map((t) {
        final tool = t.$1;
        final icon = t.$2;
        final name = t.$3;
        final active = _activeTool == tool;
        final canActivate = tool == EditorTool.none || _activeTool != tool;
        return GestureDetector(
          onTap: () => setState(() {
            _activeTool = active ? EditorTool.none : tool;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF6C5CE7).withValues(alpha: 0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: active ? const Color(0xFF6C5CE7) : Colors.white60,
                  size: 22,
                ),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 10,
                    color: active ? const Color(0xFF6C5CE7) : Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DrawPoint {
  final double x, y;
  final Color color;
  final double size;
  final bool isStart;

  _DrawPoint(this.x, this.y, this.color, this.size, this.isStart);
}

class _DrawPainter extends CustomPainter {
  final List<_DrawPoint> points;

  _DrawPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final paint = Paint()
        ..color = p.color
        ..strokeWidth = p.size
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (p.isStart || i == 0) {
        canvas.drawCircle(Offset(p.x, p.y), p.size / 2, paint);
      } else {
        final prev = points[i - 1];
        canvas.drawLine(
          Offset(prev.x, prev.y),
          Offset(p.x, p.y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawPainter old) => true;
}

class _CropPainter extends CustomPainter {
  final Rect cropRect;

  _CropPainter({required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0x99000000)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRect(cropRect),
      ),
      bgPaint,
    );
    canvas.restore();

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(cropRect, borderPaint);

    final handlePaint = Paint()
      ..color = const Color(0xFF00CEC9)
      ..style = PaintingStyle.fill;
    const handleSize = 8.0;
    final corners = [
      cropRect.topLeft, cropRect.topRight,
      cropRect.bottomLeft, cropRect.bottomRight,
    ];
    for (final c in corners) {
      canvas.drawRect(
        Rect.fromCenter(center: c, width: handleSize, height: handleSize),
        handlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CropPainter old) => old.cropRect != cropRect;
}

const List<double> Identity = [
  1, 0, 0, 0, 0,
  0, 1, 0, 0, 0,
  0, 0, 1, 0, 0,
  0, 0, 0, 1, 0,
];

const List<double> Grayscale = [
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
];

const List<double> Sepia = [
  0.393, 0.769, 0.189, 0, 0,
  0.349, 0.686, 0.168, 0, 0,
  0.272, 0.534, 0.131, 0, 0,
  0, 0, 0, 1, 0,
];

const List<double> Warm = [
  1.2, 0.1, 0, 0, 0,
  0, 1, 0.1, 0, 0,
  0, 0, 0.9, 0, 0,
  0, 0, 0, 1, 0,
];

const List<double> Cool = [
  0.9, 0, 0, 0, 0,
  0, 1, 0.1, 0, 0,
  0, 0.1, 1.2, 0, 0,
  0, 0, 0, 1, 0,
];

const List<double> Vintage = [
  0.9, 0.5, 0.1, 0, 0,
  0.3, 0.8, 0.1, 0, 0,
  0.2, 0.3, 0.6, 0, 0,
  0, 0, 0, 1, 0,
];

const List<double> Invert = [
  -1, 0, 0, 0, 255,
  0, -1, 0, 0, 255,
  0, 0, -1, 0, 255,
  0, 0, 0, 1, 0,
];

const List<double> BlueTint = [
  0.9, 0, 0, 0, 0,
  0, 0.8, 0, 0, 0,
  0, 0, 1.3, 0, 0,
  0, 0, 0, 1, 0,
];

const List<double> GreenTint = [
  0.8, 0, 0, 0, 0,
  0, 1.3, 0, 0, 0,
  0, 0, 0.8, 0, 0,
  0, 0, 0, 1, 0,
];

const List<double> RedTint = [
  1.3, 0, 0, 0, 0,
  0, 0.8, 0, 0, 0,
  0, 0, 0.8, 0, 0,
  0, 0, 0, 1, 0,
];
