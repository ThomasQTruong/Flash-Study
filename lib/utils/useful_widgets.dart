import 'package:flutter/material.dart';

class UsefulWidgets {
  static Widget addButtonDesign() {
    return Container(
      width: 50.0,
      height: 50.0,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 7.0,
            offset: Offset(0.0, 2.0),
          ),
        ],
        color: Colors.lightGreen,
        borderRadius: BorderRadius.all(Radius.circular(100.0)),
      ),
      child: const Icon(
        Icons.add,
        shadows: <Shadow>[
          Shadow(
            color: Colors.black45, blurRadius: 20.0, offset: Offset(0.0, 2.0),
          ),
        ],
        color: Colors.white,
        size: 50.0,
      ),
    );
  }
}