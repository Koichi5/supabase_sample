import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_sample/repository/todo_repository.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoRepositoryNotifier = ref.read(todoRepositoryProvider.notifier);
    final todoStream = todoRepositoryNotifier.stream();
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: todoStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('データが登録されていません'),
            );
          } else {
            final todos = snapshot.data!;
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(todos[index]['title']),
                  subtitle: Text(todos[index]['description']),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SimpleDialog(
                                  title: const Text('Edit Todo'),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  children: [
                                    TextFormField(
                                      controller: titleController,
                                    ),
                                    TextFormField(
                                      controller: descriptionController,
                                    ),
                                    ElevatedButton(
                                        onPressed: () async {
                                          await todoRepositoryNotifier.update(
                                            todoId: todos[index]['id'],
                                            title: titleController.text,
                                            description:
                                                descriptionController.text,
                                          );
                                          if (!context.mounted) return;
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Put'))
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.edit,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await todoRepositoryNotifier.delete(
                              todoId: todos[index]['id'],
                            );
                          },
                          icon: const Icon(
                            Icons.delete,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: const Text('Add Todo'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  TextFormField(
                    controller: titleController,
                  ),
                  TextFormField(
                    controller: descriptionController,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await todoRepositoryNotifier.insert(
                        title: titleController.text,
                        description: descriptionController.text,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Post',
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
