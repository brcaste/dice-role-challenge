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

class _DiceHomePageState extends State<DiceHomePage> {
  final _rng = Random();

  int _die1 = 1;
  int _die2 = 1;

  void _roll(){
    setState(() {
      _die1 = _rng.nextInt(6) + 1;// 1...6
      _die2 = _rng.nextInt(6) + 1 ;// 1...5
    });
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
              //Dice Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DiceFace(value: _die1),
                  const SizedBox(width: 24),
                  DiceFace(value: _die2),
                ],
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
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
        ),
        itemBuilder: (context, index){
          final isOn = active.contains(index);
          return Center(
            child: AnimatedOpacity(
                opacity: isOn? 1 : 0,
                duration: Duration.zero,
                child: Container(
                  width: _pipSize,
                  height: _pipSize,
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                )
            ),
          );
        },
      ),
    );
  }
}




