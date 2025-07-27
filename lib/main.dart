import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/task.dart';
import 'views/add_task_screen.dart';

void main() {
  runApp(const TaskifyApp());
}

class TaskifyApp extends StatelessWidget {
  const TaskifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskify',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: TaskListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void addTask(Task newTask) {
    setState(() {
      tasks.add(newTask);
    });
    saveTasks();
  }

  void toggleComplete(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
    saveTasks();
  }

  void loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');
    if (data != null) {
      final List decoded = jsonDecode(data);
      setState(() {
        tasks = decoded.map((e) => Task(
          id: e['id'],
          title: e['title'],
          description: e['description'],
          dueDate: DateTime.parse(e['dueDate']),
          isCompleted: e['isCompleted'],
        )).toList();
      });
    }
  }

  void saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(tasks.map((e) => {
      'id': e.id,
      'title': e.title,
      'description': e.description,
      'dueDate': e.dueDate.toIso8601String(),
      'isCompleted': e.isCompleted,
    }).toList());
    prefs.setString('tasks', data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Taskify")),
      body: tasks.isEmpty
          ? const Center(child: Text("No tasks yet"))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (ctx, i) {
                return ListTile(
                  title: Text(
                    tasks[i].title,
                    style: TextStyle(
                      decoration: tasks[i].isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    "${tasks[i].description} | Due: ${tasks[i].dueDate.toLocal().toString().split(' ')[0]}",
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      tasks[i].isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: tasks[i].isCompleted ? Colors.green : null,
                    ),
                    onPressed: () => toggleComplete(i),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => AddTaskScreen(onAdd: addTask),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
