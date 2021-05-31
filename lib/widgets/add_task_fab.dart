import 'package:flutter/material.dart';

import '../pages/add_task.dart';

class AddTaskFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed(EditTodoScreen.routeName);
      },
      backgroundColor: Color(0xff004e92),
      child: Icon(Icons.add),
    );
  }
}
