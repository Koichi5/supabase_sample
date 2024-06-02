import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_sample/repository/supabase_repository.dart';

part 'todo_repository.g.dart';

@riverpod
class TodoRepository extends _$TodoRepository {
  @override
  SupabaseClient build() {
    return ref.read(supabaseRepositoryProvider);
  }

  SupabaseStreamFilterBuilder stream() {
    return state.from('todos').stream(primaryKey: ['id']);
  }

  Future<void> insert({
    required String title,
    required String description,
  }) async {
    await state.from('todos').insert({
      'title': title,
      'description': description,
    });
  }

  Future<void> update({
    required int todoId,
    required String title,
    required String description,
  }) async {
    await state.from('todos').update({
      'title': title,
      'description': description,
    }).match({'id': todoId});
  }

  Future<void> delete({required int todoId}) async {
    await state.from('todos').delete().match({'id': todoId});
  }
}
