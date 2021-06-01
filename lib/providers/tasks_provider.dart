import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../models/task.dart';

class TasksProvider with ChangeNotifier {
  final String authToken;
  final String userId;

  TasksProvider(this.authToken, this.userId);

  CollectionReference todosCollection =
      FirebaseFirestore.instance.collection("todos");

  Stream<List<Task>> streamCompletedTodos() {
    try {
      return todosCollection
          .doc(userId)
          .collection("todos")
          .where("completed", isEqualTo: true)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        if (snapshot != null) {
          List<Task> _tasks = [];
          snapshot.docs.forEach((todo) {
            _tasks.insert(
              0,
              Task(
                id: todo.id,
                title: todo['title'],
                description: todo['description'],
                createdAt: DateTime.parse(todo['createdAt']),
                completed: todo['completed'],
                // completedAt:  DateTime.parse(todo['completedAt']),
              ),
            );
          });
          return _tasks;
        } else {
          return [];
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Task>> streamAllTodos() {
    try {
      return todosCollection
          .doc(userId)
          .collection("todos")
          .snapshots()
          .map((QuerySnapshot snapshot) {
        if (snapshot != null) {
          List<Task> _tasks = [];
          snapshot.docs.forEach((todo) {
            _tasks.insert(
              0,
              Task(
                id: todo.id,
                title: todo['title'],
                description: todo['description'],
                createdAt: DateTime.parse(todo['createdAt']),
                completed: todo['completed'],
              ),
            );
          });
          return _tasks;
        } else {
          return [];
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<String>> getdates() {
    try {
      return todosCollection
          .doc(userId)
          .collection("todos")
          .snapshots()
          .map((QuerySnapshot snapshot) {
        if (snapshot != null) {
          List<String> _dates = [];
          snapshot.docs.forEach((todo) {
            if (!_dates.contains(todo['date'])) _dates.add(todo['date']);
          });
          _dates.sort((a, b) => b.compareTo(a));
          return _dates;
        } else {
          return [];
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Task>> streamTodosByDate(String date) {
    try {
      return todosCollection
          .doc(userId)
          .collection("todos")
          .where("completed", isEqualTo: false)
          .where("date", isEqualTo: date)
          .snapshots()
          .map((QuerySnapshot snapshot) {
        if (snapshot != null) {
          List<Task> _tasks = [];
          snapshot.docs.forEach((todo) {
            _tasks.insert(
              0,
              Task(
                id: todo.id,
                title: todo['title'],
                description: todo['description'],
                createdAt: DateTime.parse(todo['createdAt']),
                completed: todo['completed'],
              ),
            );
          });
          return _tasks;
        } else {
          return [];
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createTodo(Task task) async {
    // final timeStamp = DateTime.now();
    try {
      await todosCollection.doc(userId).collection("todos").add({
        'title': task.title,
        'description': task.description,
        'completed': task.completed,
        'createdAt': task.createdAt.toIso8601String(),
        'date': task.createdAt.toString().substring(0, 10),
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateTask(String id, Task updatedTask) async {
    try {
      await todosCollection.doc(userId).collection("todos").doc(id).update({
        'title': updatedTask.title,
        'description': updatedTask.description,
        'createdAt': updatedTask.createdAt.toIso8601String(),
        'date': updatedTask.createdAt.toString().substring(0, 10),
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await todosCollection.doc(userId).collection("todos").doc(id).delete();
    } catch (error) {
      throw error;
    }
  }

  Future<void> toggleComplete(String id, bool value) async {
    final timeStamp = DateTime.now();
    try {
      await todosCollection.doc(userId).collection("todos").doc(id).update({
        'completed': value,
        'completedAt': timeStamp.toIso8601String(),
      });
    } catch (error) {
      throw error;
    }
  }

  Future<Task> findById(String id) {
    try {
      return todosCollection
          .doc(userId)
          .collection("todos")
          .doc(id)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        Task todo = Task(
          id: documentSnapshot.id,
          title: documentSnapshot['title'],
          description: documentSnapshot['description'],
          completed: documentSnapshot['completed'],
          createdAt: DateTime.parse(documentSnapshot['createdAt']),
        );
        return todo;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> batchDelete() {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    return todosCollection
        .doc(userId)
        .collection("todos")
        .where("completed", isEqualTo: true)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        batch.delete(document.reference);
      });

      return batch.commit();
    });
  }
}
