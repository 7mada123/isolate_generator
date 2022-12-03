import 'dart:math' as math;

import 'package:example/simple_isolate.dart';
import 'package:flutter/material.dart';

final defualtClass = MyClass();
final genratedClass = MyClassIsolate();

Future<void> main() async {
  await genratedClass.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  int fibNumber = 40;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) => Transform.rotate(
                angle: math.pi * 2 * animationController.value,
                child: child!,
              ),
              child: const FlutterLogo(size: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Fibonacci number = 40",
              ),
              onChanged: (value) {
                setState(() => fibNumber = int.tryParse(value) ?? fibNumber);
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("defualt class"),
                      ElevatedButton(
                        onPressed: () {
                          final res = defualtClass.fib(fibNumber);
                          print(res);
                        },
                        child: const Text("Fibonacci"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          defualtClass.fibStream(fibNumber).listen((event) {
                            print(event);
                          });
                        },
                        child: const Text("Fibonacci Stream"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("Genrated class"),
                      ElevatedButton(
                        onPressed: () async {
                          final res = await genratedClass.fib(fibNumber);
                          print(res);
                        },
                        child: const Text("Fibonacci"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          genratedClass.fibStream(fibNumber).listen((event) {
                            print(event);
                          });
                        },
                        child: const Text("Fibonacci Stream"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
