import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../widgets/add_task_fab.dart';
import '../widgets/sectioned_list_builder.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo'),
        actions: [
          Consumer<Auth>(
            builder: (ctx, auth, _) => IconButton(
              icon: Icon(Icons.logout),
              onPressed: auth.logout,
            ),
          ),
        ],
      ),
      floatingActionButton: AddTaskFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SectionedListBuilder(),
    );
  }
}

