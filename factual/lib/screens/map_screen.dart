import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/news_article.dart';
import '../providers/news_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/factual_header.dart';
import '../widgets/news_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  
  // Map state
  LatLng _lastPosition = const LatLng(37.7749, -122.4194); // Default
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  double _searchRadius = 50.0; // km
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    // Fetch initial location if not available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locProvider = Provider.of<LocationProvider>(context, listen: false);
      if (locProvider.currentLocation == null) {
        locProvider.getCurrentLocation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NewsProvider, LocationProvider>(
      builder: (context, newsProvider, locProvider, child) {
        
        final currentPos = locProvider.currentLocation != null 
          ? LatLng(locProvider.currentLocation!.latitude, locProvider.currentLocation!.longitude)
          : _lastPosition;

        // Update markers if data changed
        if (newsProvider.articles.isNotEmpty) {
           _updateMarkers(newsProvider.articles);
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const factualHeader(),
          body: Stack(
            children: [
              // Google Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentPos,
                  zoom: 11,
                ),
                onMapCreated: (controller) => _mapController = controller,
                onTap: (pos) => _onMapTapped(pos, newsProvider),
                markers: _markers,
                circles: _circles,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                // style: _mapStyle, 
              ),

              // Controls Overlay
              Positioned(
                top: 20,
                right: 20,
                child: _buildMapControls(locProvider),
              ),

              // Loading Overlay
              if (newsProvider.isLoading || locProvider.isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.black)),
            ],
          ),
        );
      },
    );
  }

  void _updateMarkers(List<NewsArticle> articles) {
    final markers = <Marker>{};
    for (var article in articles) {
      if (article.latitude != null && article.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(article.id),
            position: LatLng(article.latitude!, article.longitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              article.sentiment == 'negative' ? BitmapDescriptor.hueRed : 
              article.sentiment == 'positive' ? BitmapDescriptor.hueGreen : 
              BitmapDescriptor.hueOrange
            ),
            onTap: () => _showArticlePreview(article),
          ),
        );
      }
    }
    if (_markers.length != markers.length) {
       setState(() => _markers = markers);
    }
  }

  void _showArticlePreview(NewsArticle article) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            NewsCard(
              article: article,
              onTap: () {
                Navigator.pop(context);
                context.push('/article-detail', extra: article);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onMapTapped(LatLng pos, NewsProvider provider) {
    setState(() {
      _circles = {
        Circle(
          circleId: const CircleId('search'),
          center: pos,
          radius: _searchRadius * 1000,
          fillColor: Colors.black.withOpacity(0.05),
          strokeColor: Colors.black12,
          strokeWidth: 1,
        ),
      };
    });
    // Trigger news search for this region
    // provider.searchAtLocation(pos.latitude, pos.longitude, _searchRadius);
  }

  Widget _buildMapControls(LocationProvider locProvider) {
    return Column(
      children: [
        _buildRoundButton(Icons.my_location, () => locProvider.getCurrentLocation()),
        const SizedBox(height: 12),
        _buildRoundButton(Icons.add, () => _mapController?.animateCamera(CameraUpdate.zoomIn())),
        const SizedBox(height: 8),
        _buildRoundButton(Icons.remove, () => _mapController?.animateCamera(CameraUpdate.zoomOut())),
      ],
    );
  }

  Widget _buildRoundButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black, size: 20),
        onPressed: onTap,
      ),
    );
  }



  static const String _mapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]
''';
}
