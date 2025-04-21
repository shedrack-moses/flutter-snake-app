import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snake/enum.dart';
import 'package:flutter_snake/widgets/blank_pixel.dart';
import 'package:flutter_snake/widgets/firebase_collection.dart';
import 'package:flutter_snake/widgets/food_pixel.dart';
import 'package:flutter_snake/widgets/score_tile.dart';
import 'package:flutter_snake/widgets/snake_pos.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FocusNode _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool isGameOver = false;
  Timer? gameTimer;
  bool isPlaying = false;
  int score = 0;
  int rowSize = 10;
  int totalRowSize = 100;
  List<int> snakePos = [
    0,
    1,
    2,
  ];
  //food position
  int foodPosition = 55;
  var initialDirection = SnakeDirection.right;
  void _startGame() {
    isPlaying = true;
    FocusScope.of(context).requestFocus(_focusNode);
    // Cancel any existing timer
    gameTimer?.cancel();

    gameTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!isGameOver) {
        setState(() {
          moveSnake();
        });
      } else {
        timer.cancel();
      }
    });
  }

  List<String> docIDs = [];
  late final Future? getDocs_Ids;
  @override
  void initState() {
    // TODO: implement initState
    getDocs_Ids = getdocId();
    super.initState();
  }

  Future getdocId() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(highScores)
        .orderBy('score', descending: true)
        .limit(10)
        .get();
    final listDocs = snapshot.docs;
    for (var element in listDocs) {
      var eachDocsId = element.reference.id;
      //add it to the list
      docIDs.add(eachDocsId);
    }
  }

  void submitScores() {
    //get access to firestore
    var database = FirebaseFirestore.instance;

    database.collection(highScores).add({
      'name': _nameController.text.trim(),
      'score': score,
    });
  }

  void generateNewFoodPosition() {
    List<int> possiblePositions = [];
    for (var i = 0; i < totalRowSize; i++) {
      if (!snakePos.contains(i)) {
        //add it to the list
        possiblePositions.add(i);
      }
    }
    if (possiblePositions.isNotEmpty) {
      foodPosition =
          possiblePositions[Random().nextInt(possiblePositions.length)];
    } else {
      gameOver();
    }
  }

  void eatFood() {
    score++;
    generateNewFoodPosition();
  }

  void gameOver() {
    setState(() {
      isGameOver = true;
    });

    // Cancel the game timer
    gameTimer?.cancel();

    // Show game over dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Game Over!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $score'),
            SizedBox(height: 10),
            Form(
              key: _formKey,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name cannot be empty!';
                  }
                  return null;
                },
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            child: Text('Play Again'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                submitScores();
                _nameController.clear();
                Navigator.of(ctx).pop();
                resetGame();
              }
            },
          ),
        ],
      ),
    );
  }

  void resetGame() async {
    docIDs = [];
    await getdocId();
    setState(() {
      initialDirection = SnakeDirection.right;
      snakePos = [0, 1, 2]; // Initial snake position
      isPlaying = false;
      isGameOver = false;
      score = 0;
      generateNewFoodPosition();
    });
  }

  void moveSnake() {
    if (isGameOver) {
      return;
    }

    int newHead;
    int currentHead = snakePos.last;

    // Calculate the potential new head position
    switch (initialDirection) {
      case SnakeDirection.right:
        {
          // If at right edge, game over
          if (currentHead % rowSize == rowSize - 1) {
            gameOver();
            return;
          }
          newHead = currentHead + 1;
        }
        break;

      case SnakeDirection.left:
        {
          // If at left edge, game over
          if (currentHead % rowSize == 0) {
            gameOver();
            return;
          }
          newHead = currentHead - 1;
        }
        break;

      case SnakeDirection.down:
        {
          // If at bottom edge, game over
          if (currentHead >= totalRowSize - rowSize) {
            gameOver();
            return;
          }
          newHead = currentHead + rowSize;
        }
        break;

      case SnakeDirection.up:
        {
          // If at top edge, game over
          if (currentHead < rowSize) {
            gameOver();
            return;
          }
          newHead = currentHead - rowSize;
        }
        break;
    }

    // Check if snake collides with itself
    if (snakePos.contains(newHead)) {
      gameOver();
      return;
    }

    // Add the new head position
    snakePos.add(newHead);

    // Check if snake eats food
    if (newHead == foodPosition) {
      eatFood();
    } else {
      // If not eating food, remove the tail
      snakePos.removeAt(0);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _nameController.dispose();
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        onKeyEvent: (value) {
          if (!isPlaying) return;
          if (value is KeyDownEvent) {
            if (value.logicalKey == LogicalKeyboardKey.arrowRight &&
                initialDirection != SnakeDirection.left) {
              setState(() {
                initialDirection = SnakeDirection.right;
              });
            } else if (value.logicalKey == LogicalKeyboardKey.arrowLeft &&
                initialDirection != SnakeDirection.right) {
              setState(() {
                initialDirection = SnakeDirection.left;
              });
            } else if (value.logicalKey == LogicalKeyboardKey.arrowDown &&
                initialDirection != SnakeDirection.up) {
              setState(() {
                initialDirection = SnakeDirection.down;
              });
            } else if (value.logicalKey == LogicalKeyboardKey.arrowUp &&
                initialDirection != SnakeDirection.down) {
              setState(() {
                initialDirection = SnakeDirection.up;
              });
            }
          }
        },
        focusNode: _focusNode,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            width: screenWidth > 420 ? 420 : screenWidth,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      spacing: 40,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Current Score!',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              score.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: isPlaying
                              ? SizedBox()
                              : FutureBuilder(
                                  future: getDocs_Ids,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return ListView.builder(
                                      itemCount: docIDs.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ScoreTile(
                                          documentID: docIDs[index],
                                        );
                                      },
                                    );
                                  }),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (details.delta.dy > 0 &&
                          initialDirection != SnakeDirection.up) {
                        initialDirection = SnakeDirection.down;
                      } else if (details.delta.dy < 0 &&
                          initialDirection != SnakeDirection.down) {
                        initialDirection = SnakeDirection.up;
                      }
                    },
                    onHorizontalDragUpdate: (details) {
                      if (details.delta.dx > 0 &&
                          initialDirection != SnakeDirection.left) {
                        initialDirection = SnakeDirection.right;
                      } else if (details.delta.dx < 0 &&
                          initialDirection != SnakeDirection.right) {
                        initialDirection = SnakeDirection.left;
                      }
                    },
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowSize,
                      ),
                      itemCount: totalRowSize,
                      itemBuilder: (BuildContext context, int index) {
                        if (snakePos.contains(index)) {
                          return SnakePos();
                        } else if (foodPosition == index) {
                          return FoodPixel();
                        } else {
                          return BlankPixel();
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Center(
                      child: MaterialButton(
                        color: isPlaying ? Colors.grey : Colors.amber,
                        onPressed: isPlaying ? () {} : _startGame,
                        child: Text(
                          isPlaying ? 'Playing' : 'Play',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
