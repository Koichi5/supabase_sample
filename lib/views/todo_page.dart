import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_sample/models/filter_condition.dart';
import 'package:supabase_sample/models/todo.dart';
import 'package:supabase_sample/repository/todo_repository.dart';
import 'package:supabase_sample/views/todo_detail_page.dart';

class TodoPage extends HookConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const limitCount = 3;
    final isFilteredByWeek = useState(false);
    final isFilteredByTitle = useState(false);
    final isFilteredByTitleContain = useState(false);
    final isLimited = useState(false);
    final isOrderedByCreatedAt = useState(false);
    final filterTitleController = useTextEditingController();
    final filterTitleContainController = useTextEditingController();
    final todoRepositoryNotifier = ref.read(todoRepositoryProvider.notifier);
    final todoStream = todoRepositoryNotifier.stream(
      condition: FilterCondition(
        isFilteredByWeek: isFilteredByWeek.value,
        isFilteredByTitle: isFilteredByTitle.value,
        isFilteredByTitleContain: isFilteredByTitleContain.value,
        isLimited: isLimited.value,
        isOrderedByCreatedAt: isOrderedByCreatedAt.value,
        filterTitle: filterTitleController.text,
        filterTitleContain: filterTitleContainController.text,
        limitCount: limitCount,
      ),
    );
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    StatefulBuilder(builder: (context, setState) {
                  return SimpleDialog(
                    title: const Text('フィルター'),
                    contentPadding: const EdgeInsets.all(24),
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              const Text('１週間前まで'),
                              const Spacer(),
                              Switch(
                                value: isFilteredByWeek.value,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      isFilteredByWeek.value = value;
                                    },
                                  );
                                },
                              )
                            ],
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('タイトル名（完全一致）'),
                                  if (isFilteredByTitle.value)
                                    SizedBox(
                                      width: 150,
                                      height: 50,
                                      child: TextField(
                                        controller: filterTitleController,
                                      ),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              Switch(
                                value: isFilteredByTitle.value,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      isFilteredByTitle.value = value;
                                    },
                                  );
                                },
                              )
                            ],
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('タイトル名（部分一致）'),
                                  if (isFilteredByTitleContain.value)
                                    SizedBox(
                                      width: 150,
                                      height: 50,
                                      child: TextField(
                                        controller:
                                            filterTitleContainController,
                                      ),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              Switch(
                                value: isFilteredByTitleContain.value,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      isFilteredByTitleContain.value = value;
                                    },
                                  );
                                },
                              )
                            ],
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              const Text('作成日時 昇順'),
                              const Spacer(),
                              Switch(
                                value: isOrderedByCreatedAt.value,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      isOrderedByCreatedAt.value = value;
                                    },
                                  );
                                },
                              )
                            ],
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              const Text('TODOを3つに絞る'),
                              const Spacer(),
                              Switch(
                                value: isLimited.value,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      isLimited.value = value;
                                    },
                                  );
                                },
                              )
                            ],
                          ),
                          const Gap(8),
                        ],
                      )
                    ],
                  );
                }),
              );
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
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
                DateTime createdAt = DateTime.parse(todos[index]['created_at']);
                String formattedCreatedAt =
                    DateFormat('yyyy年M月d日H時m分').format(createdAt);
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TodoDetailPage(
                          todo: Todo(
                            id: todos[index]['id'],
                            title: todos[index]['title'],
                            description: todos[index]['description'],
                            createdAt: todos[index]['created_at'],
                            isDone: todos[index]['is_done'],
                          ),
                        ),
                      ),
                    );
                  },
                  title: Text(todos[index]['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(todos[index]['description']),
                      Text(formattedCreatedAt),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              titleController.text = todos[index]['title'];
                              descriptionController.text =
                                  todos[index]['description'];
                              return SimpleDialog(
                                title: const Text('Edit Todo'),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                children: [
                                  const Gap(8),
                                  TextFormField(
                                    controller: titleController,
                                  ),
                                  const Gap(8),
                                  TextFormField(
                                    controller: descriptionController,
                                  ),
                                  const Gap(16),
                                  TextButton(
                                    onPressed: () async {
                                      await todoRepositoryNotifier.update(
                                        todoId: todos[index]['id'],
                                        title: titleController.text,
                                        description: descriptionController.text,
                                      );
                                      if (!context.mounted) return;
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Update'),
                                  ),
                                  const Gap(24),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
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
