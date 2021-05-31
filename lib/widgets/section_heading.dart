import 'package:flutter/material.dart';

class SectionHeading extends StatelessWidget {
  SectionHeading(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          // color: Theme.of(context).primaryColor,
          gradient: LinearGradient(
            colors: [
              Color(0xff434343).withOpacity(0.5),
              Color(0xff000000).withOpacity(0.9),
            ],
            begin: Alignment(10, 4),
            end: Alignment(-4, -2),
            stops: [0, 1],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(title),
      ),
    );
  }
}
