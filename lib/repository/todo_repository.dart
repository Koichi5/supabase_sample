import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_sample/models/filter_condition.dart';
import 'package:supabase_sample/repository/supabase_repository.dart';

part 'todo_repository.g.dart';

@riverpod
class TodoRepository extends _$TodoRepository {
  @override
  SupabaseClient build() {
    return ref.read(supabaseRepositoryProvider);
  }

  SupabaseStreamBuilder? stream({
    required FilterCondition condition,
  }) {
    SupabaseStreamFilterBuilder query =
        state.from('todos').stream(primaryKey: ['id']);
    if (condition.isFilteredByWeek) {
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      final oneWeekAgoStr =
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(oneWeekAgo);
      query =
          query.gt('created_at', oneWeekAgoStr) as SupabaseStreamFilterBuilder;
    }

    if (condition.isFilteredByTitle) {
      query = query.eq('title', condition.filterTitle ?? '')
          as SupabaseStreamFilterBuilder;
    }

    if (condition.isFilteredByTitleContain) {
      query = query.contains(condition.filterTitleContain)
          as SupabaseStreamFilterBuilder;
    }

    if (condition.isOrderedByCreatedAt) {
      query = query.order('created_at', ascending: true)
          as SupabaseStreamFilterBuilder;
    }

    if (condition.isLimited) {
      query = query.limit(condition.limitCount ?? 20)
          as SupabaseStreamFilterBuilder;
    }
    return query;
  }

  Future<List<Map<String, dynamic>>> select() async {
    final data = await state.from('todos').select();
    return data;
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

  Future<void> upsert({
    int? todoId,
    required String title,
    required String description,
  }) async {
    await state.from('todos').upsert({
      'id': todoId,
      'title': title,
      'description': description,
    });
  }

  Future<void> delete({required int todoId}) async {
    await state.from('todos').delete().match({'id': todoId});
  }
}
