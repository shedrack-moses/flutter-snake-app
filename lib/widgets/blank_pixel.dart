import 'package:flutter/material.dart';

class BlankPixel extends StatelessWidget {
  const BlankPixel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey.shade900,
        ),
        child: Center(),
      ),
    );
  }
}
