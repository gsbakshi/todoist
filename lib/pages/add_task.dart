import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoist/models/task.dart';
import 'package:todoist/providers/tasks_provider.dart';

class EditTodoScreen extends StatefulWidget {
  static const routeName = '/edit-task';

  @override
  _EditTodoScreenState createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  final _formState = GlobalKey<FormState>();
  final _descriptionFocusNode = FocusNode();

  var _isLoading = false;
  var _editedTask = Task(
    id: null,
    title: '',
    description: '',
  );
  var _initValues = {
    'title': '',
    'description': '',
    'createdAt': '',
  };
  // var _isInit = true;
  String appBarTitle = 'Add Todo';

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _formState.currentState.validate();
    if (!isValid) {
      return;
    }
    _formState.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedTask.id != null) {
      print('update');
      await Provider.of<TasksProvider>(
        context,
        listen: false,
      ).updateTask(_editedTask.id, _editedTask);
    } else {
      try {
        print('create');
        await Provider.of<TasksProvider>(context, listen: false)
            .createTodo(_editedTask);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     final todo = ModalRoute.of(context).settings.arguments as Task;
  //     // final todoId = todo.id;
  //     if (todo.id == null) {
  //       return;
  //     }
  //     if (todo.id != null) {
  //       appBarTitle = 'Edit Product';
  //       _editedTask = Task(
  //         id: todo.id,
  //         title: todo.title,
  //         description: todo.description,
  //         createdAt: todo.createdAt,
  //         completed: todo.completed,
  //         completedAt: todo.completedAt,
  //       );
  //       _initValues = {
  //         'title': todo.title,
  //         'description': todo.description,
  //       };
  //     }
  //   }
  //   _isInit = false;
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formState,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a value';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedTask = Task(
                            id: _editedTask.id,
                            title: value,
                            description: _editedTask.description,
                            createdAt: _editedTask.createdAt,
                            completed: _editedTask.completed,
                            completedAt: _editedTask.completedAt,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a description';
                          }
                          if (value.length < 10) {
                            return 'Description should be atleast 10 characters long';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedTask = Task(
                            id: _editedTask.id,
                            title: _editedTask.title,
                            description: value,
                            createdAt: _editedTask.createdAt,
                            completed: _editedTask.completed,
                            completedAt: _editedTask.completedAt,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
