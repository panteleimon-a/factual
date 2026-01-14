import 'package:flutter_test/flutter_test.dart';
import 'package:factual/providers/news_provider.dart';
import 'package:factual/models/news_article.dart';
import 'package:factual/models/news_source.dart';
import 'package:factual/services/news_service.dart';
import 'package:factual/services/llm_service.dart';
import 'package:mocktail/mocktail.dart';

class MockNewsService extends Mock implements NewsService {}
class MockLLMService extends Mock implements LLMService {}

void main() {
  late NewsProvider newsProvider;
  late MockNewsService mockNewsService;
  late MockLLMService mockLLMService;

  setUp(() {
    mockNewsService = MockNewsService();
    mockLLMService = MockLLMService();
    newsProvider = NewsProvider(mockNewsService);
  });

  test('loadGlobalContexts should cache results and not re-run for same ID', () async {
    final article = NewsArticle(
      id: '1',
      title: 'Test Article',
      summary: 'Summary',
      content: 'Content',
      url: 'url',
      publishedAt: DateTime.now(),
      source: NewsSource(
        id: 's1', 
        name: 'Source',
        url: 'surl',
        country: 'US',
        language: 'en',
      ),
    );

    // Initial state
    newsProvider.setArticlesForTest([article]);
    
    when(() => mockLLMService.generateGlobalContext(article))
        .thenAnswer((_) async => {'abstract': 'AI Summary', 'graphData': []});

    // First call
    await newsProvider.loadGlobalContexts(mockLLMService, count: 1);
    
    expect(newsProvider.globalContexts.containsKey('1'), true);
    verify(() => mockLLMService.generateGlobalContext(article)).called(1);

    // Second call - should skip because it's cached
    await newsProvider.loadGlobalContexts(mockLLMService, count: 1);
    
    // verifyNoMoreInteractions might fail if notifyListeners is called or similar, 
    // but here we check calls to generateGlobalContext specifically.
    verifyNever(() => mockLLMService.generateGlobalContext(article));
  });
}
