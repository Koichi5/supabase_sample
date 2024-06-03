import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:supabase_sample/models/todo.dart';

class TodoDetailPage extends ConsumerWidget {
  const TodoDetailPage({
    super.key,
    required this.todo,
  });

  final Todo todo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime createdAt = DateTime.parse(todo.createdAt);
    String formattedCreatedAt = DateFormat('yyyy年M月d日H時m分').format(createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo.title,
              style: const TextStyle(fontSize: 20),
            ),
            const Gap(8),
            Text(todo.description),
            const Gap(8),
            Text(formattedCreatedAt),
          ],
        ),
      ),
    );
  }
}
