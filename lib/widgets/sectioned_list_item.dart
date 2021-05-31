import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/tasks_provider.dart';

import 'todo_item.dart';

class SectionedItem extends StatelessWidget {
  SectionedItem(this.date);

  final String date;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasksProvider>(context);
    return StreamBuilder<List<Task>>(
        stream: provider.streamTodosByDate(date.toString().substring(0, 10)),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          } else if (snapshot.data.isEmpty) {
            return Container();
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                  child: Text(
                      DateFormat.yMMMMEEEEd().format(DateTime.parse(date))),
                ),
                Divider(
                  indent: 16,
                  endIndent: 200,
                  thickness: 2,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return TodoItem(snapshot.data[index].id);
                  },
                ),
              ],
            );
          }
        });
  }
}
