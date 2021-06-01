import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/tasks_provider.dart';

import '../pages/add_task.dart';

class TodoItem extends StatefulWidget {
  final String id;
  TodoItem(this.id);

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Consumer<TasksProvider>(
          builder: (ctx, task, _) {
            return FutureBuilder<Task>(
              future: task.findById(widget.id),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    tileColor: Color(0xff004e92).withOpacity(0.4),
                    title: Text('Loading...'),
                  );
                } else if (snapshot.data == null) {
                  return Center(child: Text('Something went wrong'));
                } else {
                  return ListTile(
                    tileColor: snapshot.data.completed
                        ? Theme.of(context).primaryColor
                        : Color(0xff004e92).withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      // side: BorderSide(width: 2, color: Colors.white),
                    ),
                    leading: IconButton(
                      onPressed: () async {
                        try {
                          await Provider.of<TasksProvider>(context,
                                  listen: false)
                              .toggleComplete(
                            snapshot.data.id,
                            !snapshot.data.completed,
                          );
                        } catch (error) {
                          const errorMessage = 'Could not complete task';
                          _showErrorDialog(errorMessage);
                        }
                      },
                      icon: Icon(
                        snapshot.data.completed
                            ? Icons.check_box
                            : Icons.check_box_outline_blank_rounded,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    title: Text(snapshot.data.title),
                    subtitle: Text(
                      snapshot.data.description,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          onPressed: () {
                            print(snapshot.data.id + 'd');
                            Navigator.of(context).pushNamed(
                              EditTodoScreen.routeName,
                              arguments: snapshot.data,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          onPressed: () async {
                            try {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Are you sure?'),
                                  content: Text(
                                      'You are about the delete this task'),
                                  actions: [
                                    TextButton(
                                      child: Text('Yes'),
                                      onPressed: () async {
                                        Navigator.of(ctx).pop();
                                        await Provider.of<TasksProvider>(
                                                context,
                                                listen: false)
                                            .deleteTask(snapshot.data.id);
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Close'),
                                      onPressed: () => Navigator.of(ctx).pop(),
                                    ),
                                  ],
                                ),
                              );
                            } catch (error) {
                              const errorMessage = 'Could not delete task';
                              _showErrorDialog(errorMessage);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
