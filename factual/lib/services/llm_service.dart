import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/news_article.dart';
import '../config/api_config.dart';

/// Service for interacting with Google Gemini AI
/// Handles sentiment analysis, fact-checking, and duplicate detection
class LLMService {
  final GenerativeModel _model;
  bool _isInitialized = false;

  LLMService({String? apiKey}) 
      : _model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: apiKey ?? ApiConfig.geminiApiKey,
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

  // ==================== QUERY PROCESSING & FACT CHECKING ====================

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

  /// Perform a fact-check search using SR Protocol Utility B
  Future<Map<String, dynamic>> performFactCheck(String query) async {
    if (!_isInitialized) {
      throw LLMServiceException('LLM Service not initialized');
    } // Protocol B: User Query / Fact-Check implementation

    try {
      final prompt = '''
--- SR EDITORIAL PROTOCOL: UTILITY B ---
Perform a rigorous fact-check on this user query.

Query: "$query"

INSTRUCTIONS:
1. Search Phase: Retrieve information primarily from Tier 1 (Official Data) and Tier 2 (Public Service like Reuters, BBC, SR) sources.
2. Synthesis: 
   - If sources agree: State as fact.
   - If sources disagree: State the controversy (Source A vs Source B).
   - If unverified: Explicitly state "No credible evidence found."
3. Tone: Clinical, non-judgmental, precise.

Respond with JSON only:
{
  "answer": "Direct, verified answer...",
  "certainty": "High|Medium|Low",
  "sources": ["Source 1", "Source 2"],
  "controversy": "None|Details of disagreement",
  "verdict": "Verified|Disputed|Debunked|Unverified"
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
      throw LLMServiceException('Fact check failed: $e');
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

  // ==================== FULL ARTICLE ANALYSIS ====================
  
  /// Generate comprehensive analysis for an article
  Future<Map<String, dynamic>> generateAnalysis(NewsArticle article) async {
    if (!_isInitialized) {
      throw LLMServiceException('LLM Service not initialized');
    }

    try {
      final prompt = '''
--- SR EDITORIAL PROTOCOL MODE ---
You are an impartial analyst following the Sveriges Radio (SR) Editorial Handbook.
Core Directives:
- Prioritize Tier 1/2 sources (Public Service, established agencies).
- Distinguish between bias of selection and bias of presentation.
- Use the Two-Source Rule for verification.
- Output Clinical, non-judgmental tone.

Analyze the following news article for the "factual" platform:
1. Concise, factual summary (2-3 sentences, neutral language).
2. Bias detection: Identify publisher tier (1-5) and presentation bias (emotive adjectives, omissions). Provide score (0.0=Neutral, 1.0=Highly Biased).
3. Sentiment analysis: Clinical assessment (-1.0 to 1.0).
4. Key facts: List 3-5 claims. Graded by verification status (Verified by consensus / Outlier).
5. Credibility verdict: Based strictly on source tier and fact consistency.

Title: ${article.title}
Source: ${article.source.name}
Content: ${article.content.isNotEmpty ? article.content : article.summary}

Respond ONLY with JSON in this exact format:
{
  "summary": "...",
  "bias": {"type": "...", "score": 0.0, "analysis": "Source Tier X. Presentation: ..."},
  "sentiment": {"type": "...", "score": 0.0},
  "keyFacts": ["[VERIFIED] ...", "[OUTLIER] ..."],
  "verdict": "Credibility: High/Medium/Low. Reason: ..."
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
      throw LLMServiceException('Full analysis failed: $e');
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

  Future<Map<String, dynamic>> generateGlobalContext(NewsArticle article) async {
    final prompt = '''
--- SR EDITORIAL PROTOCOL: UTILITY C ---
Analyze this trending global article:
Title: ${article.title}
Source: ${article.source.name}

1. Create a <100 word abstract using neutral, clinical language. Focus on the hard news event.
2. Generate reproduction graph data (Life cycle). 
Identify at least 4 key points in time (e.g., 0h, 2h, 6h, 12h) and the volume/spread at each.

Respond ONLY with JSON:
{
  "abstract": "...",
  "graphData": [
    {"time": "0h", "volume": 1, "source": "..."},
    {"time": "2h", "volume": 15, "source": "Reuters/AP"},
    ...
  ]
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) return {};
      
      final cleaned = text.replaceAll('```json', '').replaceAll('```', '').trim();
      return json.decode(cleaned);
    } catch (e) {
      print('Global context generation failed: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getReproductionGraph(NewsArticle article) async {
    final prompt = '''
--- SR EDITORIAL PROTOCOL: REPRODUCTION GRAPH ---
Trace the life cycle of this news story:
Title: ${article.title}
Source: ${article.source.name}

Identify:
1. Originating source (if possible).
2. Key secondary reports (agencies, major outlets).
3. Propagation timeline (Estimated).
4. Major changes in framing/bias across outlets.

Respond ONLY with a JSON list of steps:
[
  {"time": "0h", "source": "...", "action": "First reported", "framing": "..."},
  {"time": "+2h", "source": "Reuters", "action": "Confirmed with agency report", "framing": "Clinical"},
  ...
]
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) return [];
      
      final cleaned = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> list = json.decode(cleaned);
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Reproduction graph failed: $e');
      return [];
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
