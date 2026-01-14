import 'package:flutter/foundation.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService;

  NewsProvider(this._newsService);

  // State
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  String? _error;
  String _currentQuery = '';
  String? _selectedSource;
  String? _selectedSentiment;

  // Getters
  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentQuery => _currentQuery;
  String? get selectedSource => _selectedSource;
  String? get selectedSentiment => _selectedSentiment;

  List<NewsArticle> get filteredArticles {
    var filtered = _articles;

    if (_selectedSource != null) {
      filtered = filtered.where((a) => a.source.name == _selectedSource).toList();
    }

    if (_selectedSentiment != null) {
      filtered = filtered.where((a) => a.sentiment == _selectedSentiment).toList();
    }

    return filtered;
  }

  // Methods
  Future<void> search(String query, {String? country, String? category}) async {
    _isLoading = true;
    _error = null;
    _currentQuery = query;
    notifyListeners();

    try {
      _articles = await _newsService.searchNews(
        query,
        country: country,
        category: category,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTopHeadlines({String? country, String? category}) async {
    _isLoading = true;
    _error = null;
    _currentQuery = 'Top Headlines';
    notifyListeners();

    try {
      _articles = await _newsService.getTopHeadlines(
        country: country ?? 'us',
        category: category ?? 'general',
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCachedArticles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _articles = await _newsService.getCachedArticles();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSourceFilter(String? source) {
    _selectedSource = source;
    notifyListeners();
  }

  void setSentimentFilter(String? sentiment) {
    _selectedSentiment = sentiment;
    notifyListeners();
  }

  void clearFilters() {
    _selectedSource = null;
    _selectedSentiment = null;
    notifyListeners();
  }

  void clearResults() {
    _articles = [];
    _currentQuery = '';
    _error = null;
    notifyListeners();
  }
}
