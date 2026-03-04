import 'package:flutter/material.dart';

void main() => runApp(const TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const TodoListScreen(),
    );
  }
}

/* ================= MODEL ================= */

enum Priority { alta, media, baixa }

class LabelModel {
  String name;
  Color color;

  LabelModel({required this.name, required this.color});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelModel &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class Task {
  String title;
  String folder;
  List<LabelModel> labels;
  Priority priority;
  bool isCompleted;

  Task({
    required this.title,
    required this.folder,
    required this.labels,
    required this.priority,
    this.isCompleted = false,
  });
}

/* ================= SCREEN ================= */

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Task> _tasks = [];
  final List<String> _folders = ['Geral', 'Concluídas'];

  final List<LabelModel> _labels = [];

  final _taskController = TextEditingController();
  final _newLabelController = TextEditingController();

  String _selectedFolder = 'Geral';
  Priority _selectedPriority = Priority.media;
  List<LabelModel> _selectedLabels = [];

  int _selectedIndex = 0;

  /* ================= TAREFAS ================= */

  void _showTaskForm({Task? task}) {
    if (task != null) {
      _taskController.text = task.title;
      _selectedFolder = task.folder;
      _selectedPriority = task.priority;
      _selectedLabels = List.from(task.labels);
    } else {
      _taskController.clear();
      _selectedFolder = 'Geral';
      _selectedPriority = Priority.media;
      _selectedLabels = [];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                task == null ? "Nova Tarefa" : "Editar Tarefa",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  labelText: "Título",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _selectedFolder,
                items: _folders
                    .where((f) => f != "Concluídas")
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedFolder = val!),
                decoration: const InputDecoration(labelText: "Pasta"),
              ),

              const SizedBox(height: 15),

              Wrap(
                spacing: 8,
                children: _labels.map((label) {
                  return FilterChip(
                    label: Text(label.name),
                    backgroundColor: label.color.withValues(alpha: 0.3),
                    selected: _selectedLabels.contains(label),
                    selectedColor: label.color,
                    onSelected: (val) {
                      setState(() {
                        val
                            ? _selectedLabels.add(label)
                            : _selectedLabels.remove(label);
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_taskController.text.isEmpty) return;

                  setState(() {
                    if (task == null) {
                      _tasks.add(
                        Task(
                          title: _taskController.text,
                          folder: _selectedFolder,
                          labels: List.from(_selectedLabels),
                          priority: _selectedPriority,
                        ),
                      );
                    } else {
                      task.title = _taskController.text;
                      task.folder = _selectedFolder;
                      task.labels = List.from(_selectedLabels);
                    }
                  });

                  Navigator.pop(context);
                },
                child: const Text("Salvar"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= HOME ================= */

  Widget _buildHome() {
    final activeTasks = _tasks.where((t) => t.folder != "Concluídas").toList();

    if (activeTasks.isEmpty) {
      return const Center(child: Text("Sem tarefas."));
    }

    return ListView.builder(
      itemCount: activeTasks.length,
      itemBuilder: (_, i) {
        final task = activeTasks[i];
        return Card(
          child: ListTile(
            title: Text(task.title),
            subtitle: Wrap(
              spacing: 6,
              children: task.labels
                  .map(
                    (l) => Chip(
                      label: Text(l.name),
                      backgroundColor: l.color.withValues(alpha: 0.3),
                    ),
                  )
                  .toList(),
            ),
            trailing: Checkbox(
              value: task.isCompleted,
              onChanged: (val) {
                setState(() {
                  task.isCompleted = val!;
                  task.folder = task.isCompleted ? "Concluídas" : "Geral";
                });
              },
            ),
            onTap: () => _showTaskForm(task: task),
          ),
        );
      },
    );
  }

  /* ================= PASTAS ================= */

  Widget _buildFolders() {
    return ListView(
      children: _folders.map((folder) {
        return ListTile(
          title: Text(folder),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    FolderDetailScreen(folder: folder, tasks: _tasks),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  /* ================= ETIQUETAS ================= */

  Widget _buildLabels() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: _labels.map((label) {
              return ListTile(
                leading: CircleAvatar(backgroundColor: label.color),
                title: Text(label.name),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: _newLabelController,
                decoration: const InputDecoration(
                  labelText: "Nome da etiqueta",
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  Color selectedColor = Colors.blue;

                  await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Escolha uma cor"),
                      content: Wrap(
                        spacing: 8,
                        children: Colors.primaries.map((color) {
                          return GestureDetector(
                            onTap: () {
                              selectedColor = color;
                              Navigator.pop(context);
                            },
                            child: CircleAvatar(backgroundColor: color),
                          );
                        }).toList(),
                      ),
                    ),
                  );

                  if (_newLabelController.text.isEmpty) return;
                  if (_labels.any((l) => l.name == _newLabelController.text))
                    return;

                  setState(() {
                    _labels.add(
                      LabelModel(
                        name: _newLabelController.text,
                        color: selectedColor,
                      ),
                    );
                  });

                  _newLabelController.clear();
                },
                child: const Text("Criar Etiqueta"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return _buildFolders();
      case 2:
        return _buildLabels();
      default:
        return _buildHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gerenciador Inteligente")),
      body: _buildBody(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showTaskForm(),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.folder), label: "Pastas"),
          NavigationDestination(icon: Icon(Icons.label), label: "Etiquetas"),
        ],
      ),
    );
  }
}

/* ================= DETALHE PASTA ================= */

class FolderDetailScreen extends StatefulWidget {
  final String folder;
  final List<Task> tasks;

  const FolderDetailScreen({
    super.key,
    required this.folder,
    required this.tasks,
  });

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  String search = "";

  @override
  Widget build(BuildContext context) {
    final filtered = widget.tasks.where((t) {
      return t.folder == widget.folder &&
          (t.title.toLowerCase().contains(search.toLowerCase()) ||
              t.labels.any(
                (l) => l.name.toLowerCase().contains(search.toLowerCase()),
              ));
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.folder)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Buscar por nome ou etiqueta",
              ),
              onChanged: (val) => setState(() => search = val),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final task = filtered[i];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Wrap(
                    spacing: 6,
                    children: task.labels
                        .map(
                          (l) => Chip(
                            label: Text(l.name),
                            backgroundColor: l.color.withValues(alpha: 0.3),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
