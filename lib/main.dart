
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dino Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DinoGame(),
    );
  }
}

class DinoGame extends StatefulWidget {
  const DinoGame({super.key});

  @override
  State<DinoGame> createState() => _DinoGameState();
}

class _DinoGameState extends State<DinoGame> {
  static double dinoYaxis = 0;
  double time = 0;
  double height = 0;
  double initialHeight = 0;
  bool gameHasStarted = false;
  static double obstacleXaxis = 1;
  int score = 0;
  bool gameOver = false;
  
  bool isJumping = false;

  void jump() {
    if (!isJumping && dinoYaxis >= 0) {
      setState(() {
        isJumping = true;
        time = 0;
        initialHeight = dinoYaxis;
      });
    }
  }

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      time += 0.04;
      height = -4.9 * time * time + 2.5 * time;
      setState(() {
        dinoYaxis = initialHeight - height;
        obstacleXaxis -= 0.05;
      });

      if (obstacleXaxis < -1.5) {
        obstacleXaxis = 1.1;
        score++;
      }

      if (dinoYaxis > 1) {
        timer.cancel();
        gameHasStarted = false;
        gameOver = true;
      } else if (dinoYaxis >= 0) {
        setState(() {
          dinoYaxis = 0;
          isJumping = false;
          time = 0;
          height = 0;
        });
      }

      // Check for collision
      if (obstacleXaxis <= 0.2 && obstacleXaxis >= -0.2) {
        if (dinoYaxis >= 0) {
          timer.cancel();
          gameHasStarted = false;
          gameOver = true;
        }
      }
    });
  }

  void resetGame() {
    setState(() {
      dinoYaxis = 0;
      gameHasStarted = false;
      time = 0;
      initialHeight = dinoYaxis;
      obstacleXaxis = 1;
      score = 0;
      gameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (gameHasStarted) {
          jump();
        } else {
          startGame();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  AnimatedContainer(
                    alignment: Alignment(0, dinoYaxis),
                    duration: const Duration(milliseconds: 0),
                    child: const SizedBox(
                      height: 60,
                      width: 60,
                      child: Text(
                        '🦖',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(obstacleXaxis, 1),
                    duration: const Duration(milliseconds: 0),
                    child: const SizedBox(
                      height: 60,
                      width: 60,
                      child: Text(
                        '🌵',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  Container(
                    alignment: const Alignment(0, 1),
                    child: Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 150,
              color: Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Score: $score',
                      style: const TextStyle(fontSize: 20),
                    ),
                    if (!gameHasStarted) ...[
                      const Text(
                        'TAP TO PLAY',
                        style: TextStyle(fontSize: 20),
                      ),
                      if (gameOver)
                        ElevatedButton(
                          onPressed: resetGame,
                          child: const Text('Play Again'),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
