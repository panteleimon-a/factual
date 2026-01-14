import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/news_article.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  final DatabaseService _db = DatabaseService();
  
  // Map state
  LatLng _currentPosition = const LatLng(37.7749, -122.4194); // Default: San Francisco
  LatLng? _selectedPosition;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  
  // Data
  List<NewsArticle> _newsArticles = [];
  List<NewsArticle> _filteredArticles = [];
  bool _isLoading = true;
  String? _selectedRegion;
  double _searchRadius = 50.0; // km
  
  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);

    try {
      // Get user's current location
      final position = await _locationService.determinePosition();
      
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Load news articles
      await _loadNewsArticles();
      
      // Move camera to user location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 12),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to get location: $e');
    }
  }

  Future<void> _loadNewsArticles() async {
    try {
      // Load cached articles from database
      final articles = await _db.getArticles(limit: 100);
      
      setState(() {
        _newsArticles = articles.where((a) => 
          a.latitude != null && a.longitude != null
        ).toList();
        _filteredArticles = _newsArticles;
      });

      // Create markers for all articles
      _updateMarkers();
    } catch (e) {
      _showError('Failed to load news: $e');
    }
  }

  void _updateMarkers() {
    final markers = <Marker>{};

    // Add user location marker
    markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: _currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    // Add news article markers
    for (var article in _filteredArticles) {
      if (article.latitude != null && article.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(article.id),
            position: LatLng(article.latitude!, article.longitude!),
            icon: _getMarkerIcon(article.sentiment),
            infoWindow: InfoWindow(
              title: article.title,
              snippet: '${article.source.name} • ${article.timeAgo}',
            ),
            onTap: () => _onArticleMarkerTapped(article),
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  BitmapDescriptor _getMarkerIcon(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'negative':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
  }

  void _onArticleMarkerTapped(NewsArticle article) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildArticlePreview(article),
    );
  }

  Widget _buildArticlePreview(NewsArticle article) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                article.source.name,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSentimentColor(article.sentiment),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  article.sentiment,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            article.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to article details
            },
            child: const Text('Read Full Article'),
          ),
        ],
      ),
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });

    // Create search circle
    _circles = {
      Circle(
        circleId: const CircleId('search_area'),
        center: position,
        radius: _searchRadius * 1000, // Convert km to meters
        fillColor: Colors.blue.withValues(alpha: 0.2),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ),
    };

    // Filter articles within radius
    _filterArticlesByLocation(position);
    
    // Reverse geocode to get region name
    _getRegionName(position);
  }

  void _filterArticlesByLocation(LatLng center) {
    final filtered = _newsArticles.where((article) {
      if (article.latitude == null || article.longitude == null) return false;

      final distance = Geolocator.distanceBetween(
        center.latitude,
        center.longitude,
        article.latitude!,
        article.longitude!,
      );

      return distance <= _searchRadius * 1000; // Convert km to meters
    }).toList();

    setState(() {
      _filteredArticles = filtered;
    });

    _updateMarkers();
    
    _showSnackBar('Found ${filtered.length} articles within ${_searchRadius}km');
  }

  Future<void> _getRegionName(LatLng position) async {
    // In production, use proper geocoding service
    setState(() {
      _selectedRegion = 'Selected Area (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
    });
  }

  void _resetFilter() {
    setState(() {
      _selectedPosition = null;
      _selectedRegion = null;
      _filteredArticles = _newsArticles;
      _circles = {};
    });
    _updateMarkers();
  }

  void _showRadiusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Radius'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${_searchRadius.toInt()} km'),
              Slider(
                value: _searchRadius,
                min: 5,
                max: 200,
                divisions: 39,
                label: '${_searchRadius.toInt()} km',
                onChanged: (value) {
                  setDialogState(() => _searchRadius = value);
                  setState(() => _searchRadius = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_selectedPosition != null) {
                _onMapTapped(_selectedPosition!);
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showClusterAnalysis() {
    // Analyze spatio-temporal patterns
    final Map<String, List<NewsArticle>> clusters = {};
    
    for (var article in _filteredArticles) {
      final key = article.location ?? 'Unknown';
      clusters[key] = (clusters[key] ?? [])..add(article);
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'News Clusters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: clusters.length,
                itemBuilder: (context, index) {
                  final region = clusters.keys.elementAt(index);
                  final articles = clusters[region]!;
                  return ListTile(
                    title: Text(region),
                    subtitle: Text('${articles.length} articles'),
                    trailing: Text(
                      _getTimeRange(articles),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeRange(List<NewsArticle> articles) {
    if (articles.isEmpty) return '';
    
    final sorted = articles.toList()..sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
    final oldest = sorted.first.publishedAt;
    final newest = sorted.last.publishedAt;
    
    final diff = newest.difference(oldest);
    if (diff.inHours < 24) {
      return '${diff.inHours}h span';
    } else {
      return '${diff.inDays}d span';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Map'),
        actions: [
          if (_selectedRegion != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _resetFilter,
              tooltip: 'Clear Filter',
            ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showClusterAnalysis,
            tooltip: 'Cluster Analysis',
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showRadiusDialog,
            tooltip: 'Search Radius',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 12,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  onTap: _onMapTapped,
                  markers: _markers,
                  circles: _circles,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                ),

          // Info panel
          if (_selectedRegion != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedRegion!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_filteredArticles.length} articles within ${_searchRadius.toInt()}km',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Legend
          Positioned(
            bottom: 16,
            left: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sentiment',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    _buildLegendItem('Positive', Colors.green),
                    _buildLegendItem('Neutral', Colors.orange),
                    _buildLegendItem('Negative', Colors.red),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
