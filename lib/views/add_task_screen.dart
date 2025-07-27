import 'package:flutter/material.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  final Function(Task) onAdd;

  const AddTaskScreen({super.key, required this.onAdd});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;

  void _submit() {
    if (_titleController.text.isEmpty || _selectedDate == null) return;

    final newTask = Task(
      id: DateTime.now().toString(),
      title: _titleController.text,
      description: _descController.text,
      dueDate: _selectedDate!,
    );

    widget.onAdd(newTask);
    Navigator.of(context).pop();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  _selectedDate == null
                      ? "No Date Chosen"
                      : "Due: ${_selectedDate!.toLocal().toString().split(' ')[0]}",
                ),
                const Spacer(),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text("Choose Date"),
                )
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Add Task"),
            )
          ],
        ),
      ),
    );
  }
}
