import 'package:flutter/material.dart';

class SnakePos extends StatelessWidget {
  const SnakePos({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        child: Center(),
      ),
    );
  }
}
