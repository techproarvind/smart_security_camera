import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_security_camera/controllers/auth_controller.dart';
import 'package:smart_security_camera/screens/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _scanCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _dotsCtrl;
  late final AnimationController _rotCtrl;

  late final Animation<double> _iconFade;
  late final Animation<double> _iconScale;
  late final Animation<double> _pulse;
  late final Animation<double> _scan;
  late final Animation<double> _textFade;
  late final Animation<Offset>  _textSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset>  _subtitleSlide;
  late final Animation<double> _dotsOpacity;
  late final Animation<double> _ringOpacity;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _iconFade  = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _iconScale = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));

    _pulseCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
    _pulse       = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut);
    _ringOpacity = Tween<double>(begin: 0.7, end: 0.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));

    _scanCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();
    _scan     = CurvedAnimation(parent: _scanCtrl, curve: Curves.linear);

    _rotCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();

    _textCtrl      = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _textFade      = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _textSlide     = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _subtitleFade  = CurvedAnimation(parent: _textCtrl, curve: const Interval(0.4, 1.0));
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));

    _dotsCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _dotsOpacity = CurvedAnimation(parent: _dotsCtrl, curve: Curves.easeIn);

    _logoCtrl.forward().whenComplete(() {
      _textCtrl.forward().whenComplete(() {
        _dotsCtrl.forward();
        Future.delayed(const Duration(milliseconds: 1200), _navigate);
      });
    });
  }

  void _navigate() {
    if (!mounted) return;
    final auth = AuthController.to;
    if (auth.loggedIn) {
      if (auth.role != UserRole.none) {
        Get.offAllNamed('/dashboard');
      } else {
        Get.offAllNamed('/role');
      }
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose(); _pulseCtrl.dispose(); _scanCtrl.dispose();
    _rotCtrl.dispose();  _textCtrl.dispose();  _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          const _GridBackground(),
          AnimatedBuilder(
            animation: _scan,
            builder: (_, __) {
              final y = _scan.value * MediaQuery.of(context).size.height;
              return Positioned(
                top: y, left: 0, right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      AppTheme.primary.withOpacity(0.6),
                      AppTheme.primary.withOpacity(0.15),
                      Colors.transparent,
                    ]),
                  ),
                ),
              );
            },
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 180, height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, __) => Transform.scale(
                          scale: 0.8 + _pulse.value * 0.6,
                          child: Opacity(
                            opacity: _ringOpacity.value,
                            child: Container(
                              width: 160, height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, __) {
                          final v     = (_pulseCtrl.value + 0.4) % 1.0;
                          final curve = Curves.easeOut.transform(v);
                          return Transform.scale(
                            scale: 0.8 + curve * 0.6,
                            child: Opacity(
                              opacity: (1 - curve) * 0.4,
                              child: Container(
                                width: 160, height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1.5),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _rotCtrl,
                        builder: (_, __) => Transform.rotate(
                          angle: _rotCtrl.value * 2 * math.pi,
                          child: CustomPaint(size: const Size(130, 130), painter: _DashedCirclePainter(color: AppTheme.primary.withOpacity(0.25))),
                        ),
                      ),
                      ScaleTransition(
                        scale: _iconScale,
                        child: FadeTransition(
                          opacity: _iconFade,
                          child: Container(
                            width: 96, height: 96,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.12),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 2),
                              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 24, spreadRadius: 4)],
                            ),
                            child: const Icon(Icons.videocam, color: AppTheme.primary, size: 46),
                          ),
                        ),
                      ),
                      ..._brackets(),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: const Text('SmartCam', style: TextStyle(color: AppTheme.textPri, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: 2.0)),
                  ),
                ),
                const SizedBox(height: 8),
                SlideTransition(
                  position: _subtitleSlide,
                  child: FadeTransition(
                    opacity: _subtitleFade,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        const Text('Secure. Smart. Affordable.', style: TextStyle(color: AppTheme.textSec, fontSize: 14, letterSpacing: 0.5)),
                        const SizedBox(width: 8),
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                FadeTransition(opacity: _dotsOpacity, child: const _LoadingDots()),
              ],
            ),
          ),
          Positioned(
            bottom: 32, left: 0, right: 0,
            child: FadeTransition(
              opacity: _dotsOpacity,
              child: const Text('v1.0.0', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSec, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _brackets() {
    const size = 16.0; const thick = 2.5; const color = AppTheme.primary;
    Widget b(double top, double left, double rot) => Positioned(
      top: top, left: left,
      child: Transform.rotate(angle: rot, child: CustomPaint(size: const Size(size, size), painter: _BracketPainter(color: color, thickness: thick))),
    );
    return [b(12, 12, 0), b(12, 142, math.pi / 2), b(142, 12, -math.pi / 2), b(142, 142, math.pi)];
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  _DashedCirclePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    const dashes = 20; const gapRatio = 0.4;
    final r = size.width / 2; final cx = size.width / 2; final cy = size.height / 2;
    final step = (2 * math.pi) / dashes;
    for (int i = 0; i < dashes; i++) {
      final start = i * step; final end = start + step * (1 - gapRatio);
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), start, end - start, false, paint);
    }
  }
  @override bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}

class _BracketPainter extends CustomPainter {
  final Color color; final double thickness;
  _BracketPainter({required this.color, required this.thickness});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = thickness..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawPath(Path()..moveTo(0, size.height)..lineTo(0, 0)..lineTo(size.width, 0), paint);
  }
  @override bool shouldRepaint(_BracketPainter old) => false;
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();
  @override State<_LoadingDots> createState() => _LoadingDotsState();
}
class _LoadingDotsState extends State<_LoadingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final bounce = math.sin(((_ctrl.value - i * 0.2).clamp(0.0, 1.0)) * math.pi).clamp(0.0, 1.0);
        return Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: 7, height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary.withOpacity(0.3 + bounce * 0.7)));
      }),
    ),
  );
}

class _GridBackground extends StatelessWidget {
  const _GridBackground();
  @override Widget build(BuildContext context) => SizedBox.expand(child: CustomPaint(painter: _GridPainter()));
}
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF00E5A0).withOpacity(0.04)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += 40) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override bool shouldRepaint(_GridPainter old) => false;
}
