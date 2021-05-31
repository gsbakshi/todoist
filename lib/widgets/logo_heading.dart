import 'dart:math';

import 'package:flutter/material.dart';

class LogoHeading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 94,
      ),
      transform: Matrix4.rotationZ(-8 * pi / 180)..translate(-10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).accentColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: -2,
            color: Colors.black,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'Todoist',
        style: TextStyle(
          fontSize: 50,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
