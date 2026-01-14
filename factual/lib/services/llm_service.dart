import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/news_article.dart';

/// Service for interacting with Google Gemini AI
/// Handles sentiment analysis, fact-checking, and duplicate detection
class LLMService {
  static const String _defaultApiKey = 'AIzaSyCz2nTDLjXkO9N_HMXo34KiPWVkd6nPLU8';
  
  final GenerativeModel _model;
  bool _isInitialized = false;

  LLMService({String? apiKey}) 
      : _model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: apiKey ?? _defaultApiKey,
        ) {
    _isInitialized = true;
  }

  /// Check if service is ready
  bool get isInitialized => _isInitialized;

  // ==================== SENTIMENT ANALYSIS ====================

  /// Analyze sentiment of a search query or text
  /// Returns: {'sentiment': 'positive'|'negative'|'neutral', 'score': -1.0 to 1.0, 'confidence': 0.0 to 1.0}
  Future<Map<String, dynamic>> analyzeSentiment(String text) async {
    if (!_isInitialized) {
      throw LLMServiceException('LLM Service not initialized');
    }

    try {
      final prompt = '''
Analyze the sentiment of the following text and provide:
1. Overall sentiment (positive, negative, or neutral)
2. Sentiment score (-1.0 to 1.0, where -1 is very negative, 0 is neutral, 1 is very positive)
3. Confidence level (0.0 to 1.0)

Text: "$text"

Respond ONLY with JSON in this exact format:
{"sentiment": "positive|negative|neutral", "score": 0.0, "confidence": 0.0}
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text == null) {
        throw LLMServiceException('Empty response from Gemini API');
      }

      // Extract JSON from response (handle markdown code blocks)
      String jsonStr = response.text!.trim();
      jsonStr = jsonStr.replaceAll('```json', '').replaceAll('```', '').trim();
      
      // Parse and validate
      final Map<String, dynamic> result = _parseJson(jsonStr);
      
      return {
        'sentiment': result['sentiment'] ?? 'neutral',
        'score': (result['score'] ?? 0.0).toDouble(),
        'confidence': (result['confidence'] ?? 0.5).toDouble(),
      };
    } catch (e) {
      throw LLMServiceException('Sentiment analysis failed: $e');
    }
  }

  // ==================== FACT VERIFICATION ====================

  /// Verify facts in an article against other sources
  /// Returns verification result with credibility score
  Future<Map<String, dynamic>> verifyFacts(
    NewsArticle article,
    List<NewsArticle> referenceSources,
  ) async {
    if (!_isInitialized) {
      throw LLMServiceException('LLM Service not initialized');
    }

    try {
      final sourceTexts = referenceSources
          .map((a) => '- ${a.source.name}: ${a.summary}')
          .join('\n');

      final prompt = '''
You are a fact-checker. Verify the claims in the main article against reference sources.

Main Article:
Title: ${article.title}
Source: ${article.source.name}
Content: ${article.summary}

Reference Sources:
$sourceTexts

Analyze and respond with JSON only:
{
  "isVerified": true|false,
  "credibilityScore": 0.0-1.0,
  "consistentFacts": ["fact1", "fact2"],
  "inconsistentFacts": ["fact1"],
  "verdict": "brief explanation"
}
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw LLMServiceException('Empty response from Gemini API');
      }

      String jsonStr = response.text!.trim();
      jsonStr = jsonStr.replaceAll('```json', '').replaceAll('```', '').trim();
      
      return _parseJson(jsonStr);
    } catch (e) {
      throw LLMServiceException('Fact verification failed: $e');
    }
  }

  // ==================== DUPLICATE DETECTION ====================

  /// Detect if articles are duplicates or reproductions
  /// Returns similarity score and analysis
  Future<Map<String, dynamic>> detectDuplicate(
    NewsArticle article1,
    NewsArticle article2,
  ) async {
    if (!_isInitialized) {
      throw LLMServiceException('LLM Service not initialized');
    }

    try {
      final prompt = '''
Compare these two news articles and determine if they are duplicates or reproductions.

Article 1:
Title: ${article1.title}
Source: ${article1.source.name}
Summary: ${article1.summary}

Article 2:
Title: ${article2.title}
Source: ${article2.source.name}
Summary: ${article2.summary}

Respond with JSON only:
{
  "isDuplicate": true|false,
  "similarityScore": 0.0-1.0,
  "type": "exact_copy|paraphrase|different|similar_topic",
  "explanation": "brief explanation"
}
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw LLMServiceException('Empty response from Gemini API');
      }

      String jsonStr = response.text!.trim();
      jsonStr = jsonStr.replaceAll('```json', '').replaceAll('```', '').trim();
      
      return _parseJson(jsonStr);
    } catch (e) {
      throw LLMServiceException('Duplicate detection failed: $e');
    }
  }

  /// Find duplicates in a list of articles
  Future<List<Map<String, dynamic>>> findDuplicatesInList(
    List<NewsArticle> articles,
  ) async {
    List<Map<String, dynamic>> duplicates = [];

    for (int i = 0; i < articles.length; i++) {
      for (int j = i + 1; j < articles.length; j++) {
        final result = await detectDuplicate(articles[i], articles[j]);
        
        if (result['isDuplicate'] == true || 
            (result['similarityScore'] ?? 0.0) > 0.7) {
          duplicates.add({
            'article1': articles[i],
            'article2': articles[j],
            'result': result,
          });
        }
      }
    }

    return duplicates;
  }

  // ==================== QUERY PROCESSING ====================

  /// Process and enhance user search query
  /// Returns enhanced query with suggestions
  Future<Map<String, dynamic>> processQuery(String query) async {
    if (!_isInitialized) {
      throw LLMServiceException('LLM Service not initialized');
    }

    try {
      final prompt = '''
Analyze this search query and provide helpful suggestions.

Query: "$query"

Respond with JSON only:
{
  "enhancedQuery": "improved search terms",
  "intent": "what the user is looking for",
  "suggestedTopics": ["topic1", "topic2"],
  "sentiment": "positive|negative|neutral"
}
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw LLMServiceException('Empty response from Gemini API');
      }

      String jsonStr = response.text!.trim();
      jsonStr = jsonStr.replaceAll('```json', '').replaceAll('```', '').trim();
      
      return _parseJson(jsonStr);
    } catch (e) {
      throw LLMServiceException('Query processing failed: $e');
    }
  }

  // ==================== ARTICLE SUMMARIZATION ====================

  /// Generate a concise summary of an article
  Future<String> summarizeArticle(NewsArticle article) async {
    if (!_isInitialized) {
      throw LLMServiceException('LLM Service not initialized');
    }

    try {
      final prompt = '''
Summarize this news article in 2-3 sentences. Be concise and factual.

Title: ${article.title}
Content: ${article.content.isNotEmpty ? article.content : article.summary}

Provide ONLY the summary, no other text.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text?.trim() ?? 'Summary unavailable';
    } catch (e) {
      throw LLMServiceException('Summarization failed: $e');
    }
  }

  // ==================== BIAS DETECTION ====================

  /// Detect potential bias in news articles
  Future<Map<String, dynamic>> detectBias(NewsArticle article) async {
    if (!_isInitialized) {
      throw LLMServiceException('LLM Service not initialized');
    }

    try {
      final prompt = '''
Analyze this news article for potential bias.

Title: ${article.title}
Source: ${article.source.name}
Content: ${article.summary}

Respond with JSON only:
{
  "hasBias": true|false,
  "biasType": "political|sensational|commercial|none",
  "biasScore": 0.0-1.0,
  "indicators": ["indicator1", "indicator2"],
  "analysis": "brief explanation"
}
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw LLMServiceException('Empty response from Gemini API');
      }

      String jsonStr = response.text!.trim();
      jsonStr = jsonStr.replaceAll('```json', '').replaceAll('```', '').trim();
      
      return _parseJson(jsonStr);
    } catch (e) {
      throw LLMServiceException('Bias detection failed: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  Map<String, dynamic> _parseJson(String jsonStr) {
    try {
      // Remove any potential BOM or whitespace
      jsonStr = jsonStr.trim();
      
      // Basic JSON parsing
      // In production, use dart:convert properly
      if (jsonStr.startsWith('{') && jsonStr.endsWith('}')) {
        // Simple regex-based parsing for demo
        // Replace with proper JSON parser in production
        final Map<String, dynamic> result = {};
        
        // Extract key-value pairs
        final kvPattern = RegExp(r'"(\w+)"\s*:\s*([^,}\]]+|\[[^\]]+\])');
        final matches = kvPattern.allMatches(jsonStr);
        
        for (var match in matches) {
          final key = match.group(1)!;
          var value = match.group(2)!.trim();
          
          // Remove quotes if string
          if (value.startsWith('"') && value.endsWith('"')) {
            value = value.substring(1, value.length - 1);
          }
          
          // Parse booleans
          if (value == 'true') {
            result[key] = true;
          } else if (value == 'false') {
            result[key] = false;
          }
          // Parse numbers
          else if (RegExp(r'^-?\d+\.?\d*$').hasMatch(value)) {
            result[key] = double.tryParse(value) ?? value;
          }
          // Parse arrays
          else if (value.startsWith('[')) {
            final items = value
                .substring(1, value.length - 1)
                .split(',')
                .map((s) => s.trim().replaceAll('"', ''))
                .toList();
            result[key] = items;
          }
          // Keep as string
          else {
            result[key] = value;
          }
        }
        
        return result;
      }
      
      return {};
    } catch (e) {
      throw LLMServiceException('Failed to parse JSON response: $e');
    }
  }

  /// Stream-based content generation for progressive updates
  Stream<String> generateContentStream(String prompt) async* {
    if (!_isInitialized) {
      throw LLMServiceException('LLM Service not initialized');
    }

    try {
      final content = [Content.text(prompt)];
      final response = _model.generateContentStream(content);

      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      throw LLMServiceException('Stream generation failed: $e');
    }
  }
}

/// Custom exception for LLM service errors
class LLMServiceException implements Exception {
  final String message;
  LLMServiceException(this.message);

  @override
  String toString() => 'LLMServiceException: $message';
}

/// Loading state for LLM operations
enum LLMLoadingState {
  idle,
  processing,
  completed,
  error,
}

/// Result wrapper with loading state
class LLMResult<T> {
  final T? data;
  final LLMLoadingState state;
  final String? error;

  LLMResult({
    this.data,
    required this.state,
    this.error,
  });

  factory LLMResult.loading() => LLMResult(state: LLMLoadingState.processing);
  factory LLMResult.success(T data) => LLMResult(data: data, state: LLMLoadingState.completed);
  factory LLMResult.failure(String error) => LLMResult(state: LLMLoadingState.error, error: error);

  bool get isLoading => state == LLMLoadingState.processing;
  bool get isSuccess => state == LLMLoadingState.completed;
  bool get isError => state == LLMLoadingState.error;
}
