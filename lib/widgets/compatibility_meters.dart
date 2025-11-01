// lib/widgets/compatibility_meters.dart
// Custom animated radial gauge for compatibility scores
// No external packages required.

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A polished, animated radial gauge for 0–100 scores.
class RadialCompatibilityMeter extends StatefulWidget {
  const RadialCompatibilityMeter({
    super.key,
    required this.value, // 0..100
    this.size = 200,
    this.label,
    this.subLabel,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.startAngle = -210, // degrees (nice 300° sweep)
    this.sweepAngle = 300,  // degrees
    this.showTicks = true,
    this.glow = true,
  });

  final double value;
  final double size;
  final String? label;
  final String? subLabel;
  final Duration animationDuration;
  final double startAngle;
  final double sweepAngle;
  final bool showTicks;
  final bool glow;

  @override
  State<RadialCompatibilityMeter> createState() => _RadialCompatibilityMeterState();
}

class _RadialCompatibilityMeterState extends State<RadialCompatibilityMeter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.animationDuration);
    final target = widget.value.clamp(0, 100) / 100.0;
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant RadialCompatibilityMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.animationDuration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: widget.value.clamp(0, 100)),
        duration: widget.animationDuration,
        curve: Curves.easeOutCubic,
        builder: (context, v, _) {
          final t = v / 100.0; // 0..1
          return CustomPaint(
            painter: _RadialPainter(
              progress: t,
              startDeg: widget.startAngle,
              sweepDeg: widget.sweepAngle,
              baseColor: theme.colorScheme.surfaceVariant,
              tickColor: theme.colorScheme.outline.withValues(alpha: 0.6),
              showTicks: widget.showTicks,
              glow: widget.glow,
            ),
            child: Center(
              child: _MeterCenterLabel(
                value: v,
                label: widget.label,
                subLabel: widget.subLabel,
                meterSize: widget.size,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RadialPainter extends CustomPainter {
  _RadialPainter({
    required this.progress,
    required this.startDeg,
    required this.sweepDeg,
    required this.baseColor,
    required this.tickColor,
    required this.showTicks,
    required this.glow,
  });

  final double progress; // 0..1
  final double startDeg;
  final double sweepDeg;
  final Color baseColor;
  final Color tickColor;
  final bool showTicks;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) * 0.82;

    final startRad = _deg2rad(startDeg);
    final sweepRad = _deg2rad(sweepDeg);

    // Base track
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.18
      ..strokeCap = StrokeCap.round
      ..color = baseColor;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startRad, sweepRad, false, track);

    // Progress arc with gradient (red -> yellow -> green)
    final gradient = SweepGradient(
      startAngle: startRad,
      endAngle: startRad + sweepRad,
      colors: [
        const Color(0xFFD32F2F), // red
        const Color(0xFFFBC02D), // amber
        const Color(0xFF388E3C), // green
      ],
      stops: const [0.0, 0.55, 1.0],
      transform: GradientRotation(-math.pi / 2),
    );

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.22
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);

    final currentSweep = sweepRad * progress;

    if (glow && progress > 0) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = radius * 0.22
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 12)
        ..shader = gradient.createShader(rect);
      canvas.drawArc(rect, startRad, currentSweep, false, glowPaint);
    }

    canvas.drawArc(rect, startRad, currentSweep, false, progressPaint);

    // Ticks
    if (showTicks) {
      final tickCount = 11; // 0,10,20,...,100
      final tickOuter = radius + (progress > 0.98 ? 0 : 0);
      final majorLen = radius * 0.14;
      final minorLen = radius * 0.08;
      final tickPaint = Paint()
        ..color = tickColor
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      // Major ticks
      for (int i = 0; i < tickCount; i++) {
        final frac = i / (tickCount - 1);
        final ang = startRad + sweepRad * frac;
        final p1 = center + Offset(math.cos(ang), math.sin(ang)) * (tickOuter - majorLen);
        final p2 = center + Offset(math.cos(ang), math.sin(ang)) * (tickOuter);
        canvas.drawLine(p1, p2, tickPaint);
      }

      // Minor ticks between majors
      final minorPerSegment = 4; // every 2.5%
      for (int seg = 0; seg < tickCount - 1; seg++) {
        for (int m = 1; m < minorPerSegment; m++) {
          final frac = (seg + m / minorPerSegment) / (tickCount - 1);
          final ang = startRad + sweepRad * frac;
          final p1 = center + Offset(math.cos(ang), math.sin(ang)) * (tickOuter - minorLen);
          final p2 = center + Offset(math.cos(ang), math.sin(ang)) * (tickOuter);
          canvas.drawLine(p1, p2, tickPaint..strokeWidth = 1.3);
        }
      }
    }

    // Needle dot at the end
    if (progress > 0) {
      final ang = startRad + currentSweep;
      final dotCenter = center + Offset(math.cos(ang), math.sin(ang)) * (radius);
      final dotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(dotCenter, radius * 0.06, dotPaint);
      canvas.drawCircle(dotCenter, radius * 0.04, Paint()..color = Colors.black.withValues(alpha: 0.12));
    }
  }

  @override
  bool shouldRepaint(covariant _RadialPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        startDeg != oldDelegate.startDeg ||
        sweepDeg != oldDelegate.sweepDeg ||
        baseColor != oldDelegate.baseColor ||
        tickColor != oldDelegate.tickColor ||
        showTicks != oldDelegate.showTicks ||
        glow != oldDelegate.glow;
  }

  double _deg2rad(double d) => d * math.pi / 180.0;
}

class _MeterCenterLabel extends StatelessWidget {
  const _MeterCenterLabel({
    required this.value,
    this.label,
    this.subLabel,
    required this.meterSize,
  });

  final double value;
  final String? label;
  final String? subLabel;
  final double meterSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = value.round();
    // Scale font sizes based on meter size (180 is the baseline)
    final scale = meterSize / 220;
    final scoreFontSize = (theme.textTheme.displayMedium?.fontSize ?? 48) * scale;
    final labelFontSize = (theme.textTheme.labelMedium?.fontSize ?? 12) * scale;
    final titleFontSize = (theme.textTheme.titleMedium?.fontSize ?? 16) * scale;
    final subLabelFontSize = (theme.textTheme.bodySmall?.fontSize ?? 12) * scale;
    
    return Padding(
      padding: EdgeInsets.all(meterSize * 0.1), // Add padding to prevent overlap
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$score',
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: scoreFontSize,
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            'compatibility',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: labelFontSize,
            ),
          ),
          if (label != null) ...[
            SizedBox(height: 8 * scale),
            Text(
              label!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: titleFontSize,
              ),
            ),
          ],
          if (subLabel != null) ...[
            SizedBox(height: 2 * scale),
            Text(
              subLabel!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: subLabelFontSize,
              ),
            ),
          ]
        ],
      ),
    );
  }
}

/// A slim, elegant animated bar meter for sub-scores.
class BarCompatibilityMeter extends StatelessWidget {
  const BarCompatibilityMeter({
    super.key,
    required this.label,
    required this.value, // 0..100
    this.height = 12,
  });

  final String label;
  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = value.clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text('${clamped.round()}%', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, constraints) {
          return Stack(children: [
            // Track
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
            // Animated progress
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: clamped / 100.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) {
                final w = constraints.maxWidth * t;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: height,
                  width: w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFD32F2F),
                        Color(0xFFFBC02D),
                        Color(0xFF388E3C),
                      ],
                      stops: [0.0, 0.55, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(height),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                );
              },
            ),
          ]);
        }),
      ],
    );
  }
}

/// Polished result card with a primary radial meter and a grid of sub-meters.
class CompatibilityResultCard extends StatelessWidget {
  const CompatibilityResultCard({
    super.key,
    required this.overall,
    required this.subscores, // Map<label, value>
    this.title = 'Your Compatibility',
  });

  final double overall;
  final Map<String, double> subscores;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final meterSize = (isWide 
                    ? math.min(220, (constraints.maxWidth * 0.4) - 40)
                    : math.min(180, constraints.maxWidth - 60)).toDouble();
                
                if (isWide) {
                  // Horizontal layout for wide screens
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: RadialCompatibilityMeter(
                            value: overall,
                            size: meterSize,
                            label: 'Overall',
                            subLabel: _labelFor(overall),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 7,
                        child: _SubscoresGrid(subscores: subscores),
                      ),
                    ],
                  );
                } else {
                  // Vertical layout for narrow screens
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RadialCompatibilityMeter(
                        value: overall,
                        size: meterSize,
                        label: 'Overall',
                        subLabel: _labelFor(overall),
                      ),
                      const SizedBox(height: 24),
                      _SubscoresGrid(subscores: subscores),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(double v) {
    if (v >= 85) return 'Excellent';
    if (v >= 70) return 'Great';
    if (v >= 55) return 'Good';
    if (v >= 40) return 'Okay';
    return 'Needs work';
  }
}

class _SubscoresGrid extends StatelessWidget {
  const _SubscoresGrid({required this.subscores});
  final Map<String, double> subscores;

  @override
  Widget build(BuildContext context) {
    final entries = subscores.entries.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 520 ? 2 : 1,
            mainAxisExtent: 64,
            crossAxisSpacing: 16,
            mainAxisSpacing: 14,
          ),
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final e = entries[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
              ),
              child: BarCompatibilityMeter(label: e.key, value: e.value),
            );
          },
        );
      },
    );
  }
}
