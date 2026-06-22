# LLMService - Usage Guide

## Overview

The `LLMService` provides AI-powered capabilities using Google Gemini 2.0 Flash for the Factual app. It handles sentiment analysis, fact verification, duplicate detection, and more.

## Quick Start

```dart
import 'package:factual/services/llm_service.dart';

// Initialize with API key (or use default)
final llm = LLMService(apiKey: 'your-api-key-here');
// OR use default key
final llm = LLMService();

// Check if ready
if (llm.isInitialized) {
  print('LLM Service ready!');
}
```

---

## Features & Usage

### 1. Sentiment Analysis

Analyze the emotional tone of text (queries, articles, comments).

```dart
final result = await llm.analyzeSentiment('Breaking political scandal!');

print('Sentiment: ${result['sentiment']}'); // positive|negative|neutral
print('Score: ${result['score']}'); // -1.0 to 1.0
print('Confidence: ${result['confidence']}'); // 0.0 to 1.0
```

**Use Cases:**
- Categorize user search queries by emotional intent
- Filter sensationalist vs. neutral news
- Track sentiment trends in news coverage

---

### 2. Fact Verification

Cross-reference articles against multiple sources to verify claims.

```dart
final mainArticle = NewsArticle(/* ... */);
final sources = [article1, article2, article3];

final verification = await llm.verifyFacts(mainArticle, sources);

print('Verified: ${verification['isVerified']}');
print('Credibility: ${verification['credibilityScore']}');
print('Consistent facts: ${verification['consistentFacts']}');
print('Verdict: ${verification['verdict']}');
```

**Response Format:**
```json
{
  "isVerified": true,
  "credibilityScore": 0.85,
  "consistentFacts": ["fact 1", "fact 2"],
  "inconsistentFacts": [],
  "verdict": "Article claims align with reference sources"
}
```

---

### 3. Duplicate Detection

Identify reproduced or plagiarized news across sources.

```dart
final article1 = NewsArticle(/* ... */);
final article2 = NewsArticle(/* ... */);

final result = await llm.detectDuplicate(article1, article2);

if (result['isDuplicate'] == true) {
  print('Type: ${result['type']}'); // exact_copy, paraphrase, etc.
  print('Similarity: ${result['similarityScore']}');
}
```

**Batch Duplicate Detection:**
```dart
final articles = [article1, article2, article3, article4];
final duplicates = await llm.findDuplicatesInList(articles);

for (var dup in duplicates) {
  print('${dup['article1'].title} matches ${dup['article2'].title}');
  print('Similarity: ${dup['result']['similarityScore']}');
}
```

---

### 4. Query Processing

Enhance user search queries with AI suggestions.

```dart
final processed = await llm.processQuery('trump news');

print('Enhanced: ${processed['enhancedQuery']}');
print('Intent: ${processed['intent']}');
print('Topics: ${processed['suggestedTopics']}');
print('Sentiment: ${processed['sentiment']}');
```

**Example Response:**
```json
{
  "enhancedQuery": "Donald Trump recent political news",
  "intent": "User wants latest political updates",
  "suggestedTopics": ["politics", "government", "elections"],
  "sentiment": "neutral"
}
```

---

### 5. Article Summarization

Generate concise summaries of long articles.

```dart
final article = NewsArticle(/* ... */);
final summary = await llm.summarizeArticle(article);

print(summary);
// "The White House announced new policy changes today..."
```

---

### 6. Bias Detection

Analyze articles for potential political, sensational, or commercial bias.

```dart
final biasAnalysis = await llm.detectBias(article);

if (biasAnalysis['hasBias'] == true) {
  print('Bias type: ${biasAnalysis['biasType']}');
  print('Score: ${biasAnalysis['biasScore']}');
  print('Indicators: ${biasAnalysis['indicators']}');
}
```

---

## Error Handling

### Using Try-Catch

```dart
try {
  final result = await llm.analyzeSentiment(text);
  // Use result
} on LLMServiceException catch (e) {
  print('LLM Error: ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
```

### Using LLMResult Wrapper

```dart
import 'package:factual/services/llm_service.dart';

LLMResult<Map<String, dynamic>> result = LLMResult.loading();

try {
  final data = await llm.analyzeSentiment(text);
  result = LLMResult.success(data);
} catch (e) {
  result = LLMResult.failure(e.toString());
}

if (result.isSuccess) {
  print('Data: ${result.data}');
} else if (result.isError) {
  print('Error: ${result.error}');
}
```

---

## Stream-Based Generation

For progressive UI updates:

```dart
await for (final chunk in llm.generateContentStream('Explain quantum physics')) {
  print(chunk); // Display incrementally
  setState(() {
    displayText += chunk;
  });
}
```

---

## Integration with Providers

### Example Provider using LLMService

```dart
import 'package:provider/provider.dart';
import 'package:factual/services/llm_service.dart';

class SearchProvider extends ChangeNotifier {
  final LLMService _llm = LLMService();
  
  String _sentiment = 'neutral';
  bool _isAnalyzing = false;

  String get sentiment => _sentiment;
  bool get isAnalyzing => _isAnalyzing;

  Future<void> analyzeQuery(String query) async {
    _isAnalyzing = true;
    notifyListeners();

    try {
      final result = await _llm.analyzeSentiment(query);
      _sentiment = result['sentiment'];
    } catch (e) {
      _sentiment = 'error';
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }
}
```

### Using in Widget

```dart
class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return Column(
      children: [
        TextField(
          onSubmitted: (query) => searchProvider.analyzeQuery(query),
        ),
        if (searchProvider.isAnalyzing) CircularProgressIndicator(),
        Text('Sentiment: ${searchProvider.sentiment}'),
      ],
    );
  }
}
```

---

## Loading States

Use the `LLMLoadingState` enum for UI feedback:

```dart
LLMLoadingState state = LLMLoadingState.idle;

setState(() {
  state = LLMLoadingState.processing;
});

try {
  final result = await llm.analyzeSentiment(text);
  setState(() {
    state = LLMLoadingState.completed;
  });
} catch (e) {
  setState(() {
    state = LLMLoadingState.error;
  });
}

// In UI
if (state == LLMLoadingState.processing) {
  return CircularProgressIndicator();
} else if (state == LLMLoadingState.error) {
  return Text('Error occurred');
}
```

---

## Best Practices

### 1. Cache Results

```dart
final _sentimentCache = <String, Map<String, dynamic>>{};

Future<Map<String, dynamic>> getCachedSentiment(String text) async {
  if (_sentimentCache.containsKey(text)) {
    return _sentimentCache[text]!;
  }
  
  final result = await llm.analyzeSentiment(text);
  _sentimentCache[text] = result;
  return result;
}
```

### 2. Batch Operations

```dart
// ✅ Good - Process in batches
final results = <Future<Map<String, dynamic>>>[];
for (var article in articles) {
  results.add(llm.detectBias(article));
}
final allResults = await Future.wait(results);

// ❌ Avoid - Sequential processing
for (var article in articles) {
  await llm.detectBias(article); // Slow!
}
```

### 3. Handle Rate Limits

```dart
int requestCount = 0;
const maxRequests = 60; // per minute

Future<void> withRateLimit(Future Function() operation) async {
  if (requestCount >= maxRequests) {
    await Future.delayed(Duration(minutes: 1));
    requestCount = 0;
  }
  
  requestCount++;
  await operation();
}
```

### 4. Timeout Protection

```dart
try {
  final result = await llm.analyzeSentiment(text)
      .timeout(Duration(seconds: 10));
} on TimeoutException {
  print('Request took too long');
} on LLMServiceException catch (e) {
  print('LLM error: ${e.message}');
}
```

---

## Complete Example - Search Flow

```dart
class NewsSearch {
  final LLMService llm = LLMService();
  final DatabaseService db = DatabaseService();

  Future<void> performSearch(String query, String userId) async {
    // 1. Process query
    final processed = await llm.processQuery(query);
    
    // 2. Analyze sentiment
    final sentiment = await llm.analyzeSentiment(query);
    
    // 3. Save to database
    final searchQuery = SearchQuery(
      id: uuid.v4(),
      userId: userId,
      query: processed['enhancedQuery'],
      sentiment: sentiment['sentiment'],
      timestamp: DateTime.now(),
    );
    await db.insertSearchQuery(searchQuery);
    
    // 4. Fetch articles from API
    final articles = await newsApi.search(processed['enhancedQuery']);
    
    // 5. Detect duplicates
    final duplicates = await llm.findDuplicatesInList(articles);
    
    // 6. Filter unique articles
    final uniqueArticles = articles.where((a) {
      return !duplicates.any((d) => 
        d['article2'].id == a.id
      );
    }).toList();
    
    // 7. Cache articles
    await db.insertArticles(uniqueArticles);
    
    return uniqueArticles;
  }
}
```

---

## API Key Management

### Option 1: Constructor Parameter

```dart
final llm = LLMService(apiKey: 'YOUR_API_KEY');
```

### Option 2: Environment Variable (Recommended)

```dart
// In .env file
GEMINI_API_KEY=your_key_here

// In code
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
final llm = LLMService(apiKey: dotenv.env['GEMINI_API_KEY']);
```

### Option 3: Secure Storage

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
final apiKey = await storage.read(key: 'gemini_api_key');
final llm = LLMService(apiKey: apiKey);
```

---

## Troubleshooting

### Empty Responses

```dart
// Always check for null
final response = await llm.analyzeSentiment(text);
if (response.isEmpty) {
  print('Warning: Empty response from API');
}
```

### JSON Parsing Errors

The service handles JSON extraction from markdown code blocks automatically:
- Removes ` ```json ` wrappers
- Parses common formats
- Returns empty map on failure

---

## Performance Tips

1. **Debounce user input** - Don't analyze every keystroke
2. **Use streams** for real-time updates
3. **Cache frequently used results**
4. **Batch similar requests** together
5. **Set reasonable timeouts** (10-30 seconds)

---

**The LLMService is production-ready and passes all Flutter analysis checks!** ✅
