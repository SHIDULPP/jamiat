import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jamiat/src/data/apis/news_api.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/models/news_model.dart';
import 'package:jamiat/src/data/models/paginated_response.dart';
import 'package:jamiat/src/interfaces/news/news_list.dart';

class _NewsApi implements NewsApi {
  final calls = <({String search, int page})>[];
  final slow = Completer<ApiResponse<PaginatedResponse<NewsModel>>>();

  ApiResponse<PaginatedResponse<NewsModel>> result(
    String title,
    int page,
    int total,
  ) {
    return ApiResponse.success(
      PaginatedResponse(
        items: [NewsModel(id: title, title: title, description: 'Description')],
        totalCount: total,
        pageNo: page,
        limit: 10,
      ),
      200,
    );
  }

  @override
  Future<ApiResponse<PaginatedResponse<NewsModel>>> getNewsForUser({
    int pageNo = 1,
    int limit = 10,
    String? search,
  }) async {
    calls.add((search: search ?? '', page: pageNo));
    if (search == 'slow') return slow.future;
    return result(
      search?.isNotEmpty == true ? 'Match $search page $pageNo' : 'Latest news',
      pageNo,
      11,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'searches server, paginates, ignores stale responses and resets on clear',
    (tester) async {
      final api = _NewsApi();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [newsApiProvider.overrideWithValue(api)],
          child: const MaterialApp(home: NewsListScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Latest news'), findsOneWidget);
      final field = find.byType(TextField);
      await tester.enterText(field, 'slow');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      await tester.enterText(field, '  Medical  ');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.text('Match Medical page 1'), findsOneWidget);
      expect(api.calls.last, (search: 'Medical', page: 1));
      api.slow.complete(api.result('Stale result', 1, 1));
      await tester.pumpAndSettle();
      expect(find.text('Stale result'), findsNothing);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(api.calls.last, (search: 'Medical', page: 2));
      expect(find.text('Match Medical page 2'), findsOneWidget);
      await tester.enterText(field, '');
      await tester.pumpAndSettle();
      expect(api.calls.last, (search: '', page: 1));
      expect(find.text('Latest news'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
