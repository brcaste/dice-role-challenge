import 'package:flutter/material.dart';
import 'dart:math';

void main(){
  runApp(const DiceApp());
}

class DiceApp extends StatelessWidget{
  const DiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice Roller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
      ),
      home: const DiceHomePage(),
    );
  }
}

class DiceHomePage extends StatefulWidget{
  const DiceHomePage({super.key});
  @override
  State<DiceHomePage> createState() => _DiceHomePageState();
}

class _DiceHomePageState extends State<DiceHomePage>
  with SingleTickerProviderStateMixin{

  final _rng = Random();

  int _die1 = 1;
  int _die2 = 1;

  late final AnimationController _shakeController;
  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }
  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }
  void _roll(){
    setState(() {
      _die1 = _rng.nextInt(6) + 1;// 1...6
      _die2 = _rng.nextInt(6) + 1 ;// 1...5
    });

    // Trigger a quick shake
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dice Roller")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Shake(
                controller: _shakeController,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DiceFace(value: _die1),
                    const SizedBox(width: 24),
                    DiceFace(value: _die2),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              //Single button
              SizedBox(
                width: 180,
                height: 52,
                child: ElevatedButton(
                    onPressed: _roll,
                    child: const Text(
                      'Roll',
                      style: TextStyle(fontSize: 18),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/// Quick shake effectd: tiny left/right + slight rotation
class Shake extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  const Shake({super.key, required this.controller, required this.child});

  double _shakeCurve(double t) {
    // a few oscillations that decar (hand-tuned).
    //t in [0,1]
    final oscillations = sin(t * pi * 10); // 5 full wiggles
    final decay = (1 - t) * (1 - t);
    return oscillations * decay;
  }

  double _bounceCurve(double t) {
    if (t < 0.3){
      return -sin((t/0.3) * (pi / 2));
    }else {
      final fallT = (t - 0.3) / 0.7;
      return sin(fallT * pi) * 0.3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final t = controller.value;
          final s = _shakeCurve(t);

          //keep subtle - small movement reads as "shake" without being annoying.
          final dx = s* 24; //px
          final dy = _bounceCurve(t) * 12;
          final rot = s* 0.14; //radians (~3.4 degrees peak)

          return Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.rotate(
              angle: rot,
              child: child,
            ),
          );
        },
    );
  }
}
/// Simple placeholder dice UI (no images, no animation)
class DiceFace extends StatelessWidget {
  final int value;
  const DiceFace({super.key, required this.value});

  static const double _pipSize = 14;

  // Each die value maps to which pip positions are "on" in a 3x3 grid.
  // Grid index layout:
  // 0 1 2
  // 3 4 5
  // 6 7 8
  static const Map<int, List<int>> _pipMap ={
    1: [4],
    2: [0,8],
    3: [0,4,8],
    4: [0,2,6,8],
    5: [0,2,4,6,8],
    6: [0,2,3,5,6,8],
  };

  @override
  Widget build(BuildContext context) {
    final active = _pipMap[value] ?? const [4];

    return Container(
      width: 96,
      height: 96,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 2),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 6),
            color: Colors.black12,
          ),
        ]
      ),
      child: ClipRRect(
        borderRadius : BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(color: Colors.white),

            // Inner bevel: gentle highlight (top-left) + shade (bottom-right)
            Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.85),
                          Colors.white.withOpacity(0.0),
                          Colors.black.withOpacity(0.06),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
            ),
            Positioned.fill(
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.06),
                            width: 1.5,
                          ),
                        ),
                    ),
                  ),
                ),
            ),

            //Pips
            Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3
                ),
                itemBuilder: (context, index) {
                  final isOn = active.contains(index);
                  if (!isOn) return const SizedBox.shrink();

                  final isRedCasinoOne = (value == 1 && index == 4);
                  final pipColor =
                      isRedCasinoOne ? Colors.red.shade700 : Colors.black87;

                  return Center(
                    child: Container(
                      width: _pipSize,
                      height: _pipSize,
                      decoration: BoxDecoration(
                        color: pipColor,
                        shape: BoxShape.circle,
                        boxShadow: const[
                          BoxShadow(
                            blurRadius: 2,
                            offset: Offset(0, 1),
                            color: Colors.black26
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}




