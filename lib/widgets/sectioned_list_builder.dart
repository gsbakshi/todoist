import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/tasks_provider.dart';

import 'todo_item.dart';
import 'section_heading.dart';
import 'sectioned_list_item.dart';

class SectionedListBuilder extends StatelessWidget {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasksProvider>(context);
    return SingleChildScrollView(
      controller: _controller,
      child: Column(
        children: [
          SectionHeading('Completed of Todos'),
          StreamBuilder<List<Task>>(
            stream: provider.streamCompletedTodos(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.6),
                ));
              } else if (snapshot.hasError) {
                return Center(child: Text('Something went wrong'));
              } else if (snapshot.data.isEmpty) {
                return Center(child: Text('Complete a Task'));
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return TodoItem(snapshot.data[index].id);
                  },
                );
              }
            },
          ),
          SectionHeading('List of Todos'),
          StreamBuilder(
            stream: provider.streamdates(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.6),
                ));
              } else if (snapshot.hasError) {
                return Center(child: Text('Something went wrong'));
              } else if (snapshot.data.isEmpty) {
                return Center(child: Text('Add a Task'));
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (ctx, i) {
                    return SectionedItem(snapshot.data[i]);
                  },
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(64),
          ),
        ],
      ),
    );
  }
}