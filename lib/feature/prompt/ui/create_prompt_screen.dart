import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../bloc/prompt_bloc.dart';

class CreatePromptScreen extends StatefulWidget {
  const CreatePromptScreen({super.key});

  @override
  _CreatePromptScreenState createState() => _CreatePromptScreenState();
}

class _CreatePromptScreenState extends State<CreatePromptScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _generate() {
    final prompt = _controller.text.trim();
    if (prompt.isNotEmpty) {
      context.read<PromptBloc>().add(PromptEnteredEvent(prompt: prompt));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 22,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFf093fb)],
              ).createShader(bounds),
              child: const Text(
                'SENSE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background with purple waves
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Colors.black],
              ),
            ),
          ),
          // Animated purple waves background
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                painter: WavesPainter(_waveController.value),
                size: Size.infinite,
              );
            },
          ),
          // Main content area
          Column(
            children: [
              // Center content area
              Expanded(
                child: BlocBuilder<PromptBloc, PromptState>(
                  builder: (context, state) {
                    if (state is PromptGeneratingImageLoadState) {
                      return _buildLoadingState();
                    } else if (state is PromptGeneratingImageSuccessState) {
                      return _buildSuccessState(state);
                    } else if (state is PromptGeneratingImageErrorState) {
                      return _buildErrorState();
                    }
                    return _buildInitialState();
                  },
                ),
              ),
              // Bottom input area
              _buildBottomInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large logo with glow effect
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.6),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.4),
                  blurRadius: 50,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 60,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Glowing text
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFFf093fb), Color(0xFF667eea)],
            ).createShader(bounds),
            child: const Text(
              'AI Image Generation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Describe your vision below',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Futuristic loading animation
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating ring
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _waveController.value * 2 * math.pi,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.transparent, width: 0),
                        gradient: SweepGradient(
                          colors: [
                            Colors.transparent,
                            Colors.purple.withValues(alpha: 0.3),
                            Color(0xFF667eea),
                            Color(0xFF764ba2),
                            Color(0xFFf093fb),
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Middle rotating ring (opposite direction)
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: -_waveController.value * 1.5 * math.pi,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.transparent, width: 0),
                        gradient: SweepGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFF667eea).withValues(alpha: 0.6),
                            Colors.transparent,
                            Color(0xFFf093fb).withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Inner pulsing circle
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  final pulseValue =
                      math.sin(_waveController.value * 4 * math.pi) * 0.1 + 0.9;
                  return Transform.scale(
                    scale: pulseValue,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFF667eea),
                            Color(0xFF764ba2),
                            Color(0xFFf093fb),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.8),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.6),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
              // Floating particles
              ...List.generate(6, (index) {
                return AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    final angle =
                        (index * 60 + _waveController.value * 120) *
                        math.pi /
                        180;
                    final radius =
                        70 +
                        math.sin(_waveController.value * 3 * math.pi + index) *
                            10;
                    return Positioned(
                      left: 75 + radius * math.cos(angle) - 3,
                      top: 75 + radius * math.sin(angle) - 3,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: [
                            Color(0xFF667eea),
                            Color(0xFF764ba2),
                            Color(0xFFf093fb),
                          ][index % 3].withValues(alpha: 0.8),
                          boxShadow: [
                            BoxShadow(
                              color: [
                                Color(0xFF667eea),
                                Color(0xFF764ba2),
                                Color(0xFFf093fb),
                              ][index % 3].withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 32),
          // Animated text with typing effect
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFFf093fb)],
            ).createShader(bounds),
            child: const Text(
              '🎨 Creating your masterpiece...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Pulsating subtitle
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              final opacity =
                  (math.sin(_waveController.value * 2 * math.pi) * 0.3 + 0.7);
              return Text(
                'Powered by Deviine.Ai',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: opacity),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(PromptGeneratingImageSuccessState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  state.uint8list,
                  fit: BoxFit.contain,
                  height: 300,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Image generated successfully!'),
                      backgroundColor: Color(0xFF667eea),
                    ),
                  );
                },
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text(
                  'Save Image',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.red.withValues(alpha: 0.2),
            ),
            child: const Icon(Icons.error_outline, size: 50, color: Colors.red),
          ),
          const SizedBox(height: 24),
          const Text(
            'Generation Failed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please try again in a moment',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputArea() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.purple.withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 3,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4A148C), // Dark purple color
                ),
                decoration: InputDecoration(
                  hintText:
                      '✨ Describe your vision...\n\nExample: "A mystical forest with glowing fireflies"',
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(
                      255,
                      96,
                      15,
                      147,
                    ).withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                    Color(0xFFf093fb),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _generate,
                icon: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
                label: const Text(
                  "✨ Generate Magic",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for animated purple waves
class WavesPainter extends CustomPainter {
  final double animationValue;

  WavesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.purple.withValues(alpha: 0.3),
          Colors.blue.withValues(alpha: 0.2),
          Colors.purple.withValues(alpha: 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final waveHeight = 50.0;
    final waveLength = size.width / 2;

    // First wave
    path.moveTo(0, size.height * 0.3);
    for (double x = 0; x <= size.width; x += 1) {
      double y =
          size.height * 0.3 +
          math.sin((x / waveLength + animationValue * 2) * 2 * math.pi) *
              waveHeight;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.blue.withValues(alpha: 0.2),
        Colors.purple.withValues(alpha: 0.15),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    for (double x = 0; x <= size.width; x += 1) {
      double y =
          size.height * 0.6 +
          math.sin((x / waveLength - animationValue * 1.5) * 2 * math.pi) *
              waveHeight *
              0.8;
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(WavesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
