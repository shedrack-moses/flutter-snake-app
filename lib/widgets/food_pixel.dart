import 'package:flutter/material.dart';

class FoodPixel extends StatelessWidget {
  const FoodPixel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.green,
        ),
        child: Center(),
      ),
    );
  }
}
