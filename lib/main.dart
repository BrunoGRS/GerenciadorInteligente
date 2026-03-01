import 'package:flutter/material.dart';
import 'package:todo/models/task.dart'; // Ajuste conforme o nome do seu projeto

void main() => runApp(const MaterialApp(home: TodoListScreen()));

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Task> _tasks = []; // Lista que armazena as tarefas
  final _textController = TextEditingController();
  String _selectedCategory = 'Trabalho';
  Priority _selectedPriority = Priority.media;

  void _addNewTask() {
    if (_textController.text.isEmpty) return;

    setState(() {
      _tasks.add(
        Task(
          title: _textController.text,
          category: _selectedCategory,
          priority: _selectedPriority,
        ),
      );
    });

    _textController.clear();
    Navigator.pop(context); // Fecha o formulário após salvar
  }

  void _showForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: 'Título da Tarefa'),
            ),
            DropdownButton<String>(
              value: _selectedCategory,
              items: [
                'Trabalho',
                'Estudo',
                'Pessoal',
                'Esporte',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            ElevatedButton(
              onPressed: _addNewTask,
              child: const Text('Adicionar Tarefa'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciador de Tarefas inteligente')),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (ctx, i) => ListTile(
          title: Text(_tasks[i].title),
          subtitle: Text(
            '${_tasks[i].category} - Prioridade: ${_tasks[i].priority.name}',
          ),
          trailing: Checkbox(
            value: _tasks[i].isCompleted,
            onChanged: (val) => setState(() => _tasks[i].isCompleted = val!),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
