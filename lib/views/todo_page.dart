import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final todoStream =
        Supabase.instance.client.from('todos').stream(primaryKey: ['id']);
    TextEditingController todoController = TextEditingController();

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
          } else if (
              !snapshot.hasData) {
            return const Center(
              child: Text('データが登録されていません'),
            );
          } else {
            final todos = snapshot.data!;

            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(todos[index]['body']),
                  subtitle: Text(todos[index]['created_at']),
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
                                      controller: todoController,
                                    ),
                                    ElevatedButton(
                                        onPressed: () async {
                                          await Supabase.instance.client
                                              .from('todos')
                                              .update({
                                            'body': todoController.text
                                          }).match(
                                            {
                                              'id': todos[index]['id'],
                                            },
                                          );
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
                            await Supabase.instance.client
                                .from('todos')
                                .delete()
                                .match(
                              {
                                'id': todos[index]['id'],
                              },
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
                      controller: todoController,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await Supabase.instance.client
                              .from('todos')
                              .insert({'body': todoController.text});
                          Navigator.pop(context);
                        },
                        child: const Text('Post'))
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
