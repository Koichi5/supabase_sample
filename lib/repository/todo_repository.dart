import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_sample/models/filter_condition.dart';
import 'package:supabase_sample/repository/supabase_repository.dart';

part 'todo_repository.g.dart';

@Riverpod(keepAlive: true)
class TodoRepository extends _$TodoRepository {
  late final SupabaseClient supabaseClient;
  @override
  void build() {
    supabaseClient = ref.read(supabaseRepositoryProvider);
  }

  // リアルタイム取得
  SupabaseStreamBuilder? stream({
    required FilterCondition condition,
  }) {
    SupabaseStreamFilterBuilder query =
        supabaseClient.from('todos').stream(primaryKey: ['id']);

    // １週間前までのデータをフィルタリング
    if (condition.isFilteredByWeek) {
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      final oneWeekAgoStr =
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(oneWeekAgo);
      query =
          query.gt('created_at', oneWeekAgoStr) as SupabaseStreamFilterBuilder;
    }

    // タイトルが一致するもののみをフィルタリング
    if (condition.isFilteredByTitle) {
      query = query.eq('title', condition.filterTitle ?? '')
          as SupabaseStreamFilterBuilder;
    }

    // 作成日に応じて昇順、降順に並び替え
    if (condition.isOrderedByCreatedAt) {
      query = query.order('created_at', ascending: true)
          as SupabaseStreamFilterBuilder;
    } else {
      query = query.order('created_at', ascending: false)
          as SupabaseStreamFilterBuilder;
    }

    // 取得件数の制限
    if (condition.isLimited) {
      query = query.limit(condition.limitCount ?? 20)
          as SupabaseStreamFilterBuilder;
    }
    return query;
  }

  // 全データの取得
  Future<List<Map<String, dynamic>>> select() async {
    final data = await supabaseClient.from('todos').select();
    return data;
  }

  // データの追加
  Future<void> insert({
    required String title,
    required String description,
  }) async {
    await supabaseClient.from('todos').insert({
      'title': title,
      'description': description,
    });
  }

  // データの更新
  Future<void> update({
    required int todoId,
    required String title,
    required String description,
  }) async {
    await supabaseClient.from('todos').update({
      'title': title,
      'description': description,
    }).match({'id': todoId});
  }

  // データの追加 or 更新
  Future<void> upsert({
    int? todoId,
    required String title,
    required String description,
  }) async {
    await supabaseClient.from('todos').upsert({
      'id': todoId,
      'title': title,
      'description': description,
    });
  }

  // データの削除
  Future<void> delete({required int todoId}) async {
    await supabaseClient.from('todos').delete().match({'id': todoId});
  }
}
