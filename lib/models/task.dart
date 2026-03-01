enum Priority { alta, media, baixa }

class Task {
  String title;
  String category; // Trabalho, Estudo, Pessoal, etc. [cite: 14]
  Priority priority; // Alta, Média, Baixa [cite: 15]
  bool isCompleted;

  Task({
    required this.title,
    required this.category,
    this.priority = Priority.media,
    this.isCompleted = false,
  });
}
