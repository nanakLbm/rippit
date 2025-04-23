import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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
  int highScore = 0;
  bool gameOver = false;
  bool isJumping = false;

  @override
  void initState() {
    super.initState();
    loadHighScore();
  }

  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  Future<void> updateHighScore() async {
    if (score > highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', score);
      setState(() {
        highScore = score;
      });
    }
  }

  void jump() {
    if (!isJumping && dinoYaxis >= 0 && !gameOver) {
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
        // Increase speed based on score (0.05 base speed + 0.01 per 5 points)
        double speedMultiplier = 1.0 + (score / 5) * 0.2;
        obstacleXaxis -= 0.05 * speedMultiplier;
      });

      if (obstacleXaxis < -1.5) {
        obstacleXaxis = 1.1;
        score++;
      }

      if (dinoYaxis > 1) {
        timer.cancel();
        gameHasStarted = false;
        gameOver = true;
        updateHighScore(); // Update high score when game over
      } else if (height < 0) {
        // Landed (height becomes negative at end of jump)
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
          updateHighScore(); // Update high score when game over
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Positioned(
                        left: constraints.maxWidth * 0.2,
                        bottom: (constraints.maxHeight * 0.7) * (1 - dinoYaxis),
                        child: const SizedBox(
                          height: 60,
                          width: 60,
                      child: Transform(
                        transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                        alignment: Alignment.center,
                        child: Text(
                          '🦖',
                          style: TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                        left: constraints.maxWidth * (0.8 + obstacleXaxis),
                        bottom: constraints.maxHeight * 0.7,
                        child: const SizedBox(
                          height: 50,
                          width: 50,
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
                    Column(
                      children: [
                        Text(
                          'Score: $score',
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          'High Score: $highScore',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
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