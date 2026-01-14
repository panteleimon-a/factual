# Map Feature - Geographic News Filtering

## Overview

The Map Screen provides an interactive Google Maps interface for discovering and filtering news articles based on geographic location. It leverages geolocator for user location and implements spatio-temporal analysis of news coverage.

## Features

### 1. **Interactive Google Maps**
- Full-screen map interface
- User location tracking
- Smooth camera animations
- Custom markers for news articles

### 2. **News Markers**
- Color-coded by sentiment:
  - 🟢 **Green**: Positive news
  - 🟡 **Yellow**: Neutral news
  - 🔴 **Red**: Negative news
- Tap markers to see article preview
- Bottom sheet with article details

### 3. **Geographic Filtering**
- **Tap anywhere** on the map to select a region
- Creates a search radius circle (blue overlay)
- Filters news within the selected radius
- Adjustable radius: 5km to 200km

### 4. **Spatio-Temporal Cluster Analysis**
- Groups articles by geographic region
- Shows time span for each cluster
- Helps identify news hotspots
- Reveals temporal patterns in coverage

### 5. **Smart Features**
- Auto-load user's current location
- Permission requests for location access
- Info panel showing filtered article count
- Visual legend for sentiment colors
- Reset button to clear filters

---

## Usage

### Accessing the Map

Navigate to the Map screen from the home screen using the navigation button or route to `/map`.

### Basic Operations

#### View News Near You
1. Launch the app (location permission will be requested)
2. Map centers on your current location
3. See all nearby news articles as markers

#### Filter by Region
1. **Tap anywhere** on the map
2. A blue circle appears showing search radius
3. News is filtered to only show articles within that radius
4. Info panel displays: region name and article count

#### Adjust Search Radius
1. Tap the **tune icon** (⚙️) in the app bar
2. Use slider to select radius (5-200km)
3. Tap **Apply**
4. Filter automatically updates

#### View Article Details
1. Tap any **news marker**
2. Bottom sheet appears with:
   - Article title
   - Source name
   - Sentiment badge
   - Summary (3 lines max)
3. Tap **"Read Full Article"** to navigate to details

#### Cluster Analysis
1. Tap the **analytics icon** (📊) in app bar
2. See news grouped by geographic regions
3. View article count per region
4. See time span (how long news has been happening)

#### Reset Filters
1. Tap the **clear icon** (✕) in app bar
2. All articles become visible again
3. Search circle disappears

---

## Technical Details

###  Location Services

Uses `geolocator` package to:
- Determine user's current position
- Calculate distances between coordinates
- Filter articles within radius

**Permissions Required:**
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`

### Google Maps Integration

**Configuration:**
- API key must be set in `AndroidManifest.xml`
- See `CONFIGURATION.md` for setup instructions

**Map Settings:**
- `myLocationEnabled: true` - Shows blue dot for user
- `myLocationButtonEnabled: true` - Location button
- `zoomControlsEnabled: true` - +/- zoom controls

### Data Flow

```
1. App Launch
   ↓
2. Request Location Permission
   ↓
3. Get User's GPS Coordinates
   ↓
4. Load Cached Articles from DatabaseService
   ↓
5. Filter Articles with Lat/Lng Data
   ↓
6. Create Markers on Map
   ↓
7. User Taps Map Location
   ↓
8. Create Search Circle
   ↓
9. Calculate Distances (Geolocator.distanceBetween)
   ↓
10. Filter Articles Within Radius
   ↓
11. Update Markers
```

---

## Code Examples

### Filtering Articles by Location

```dart
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
}
```

### Creating Markers

```dart
void _updateMarkers() {
  final markers = <Marker>{};

  // User location
  markers.add(
    Marker(
      markerId: const MarkerId('user_location'),
      position: _currentPosition,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ),
  );

  // News articles
  for (var article in _filteredArticles) {
    markers.add(
      Marker(
        markerId: MarkerId(article.id),
        position: LatLng(article.latitude!, article.longitude!),
        icon: _getMarkerIcon(article.sentiment),
        infoWindow: InfoWindow(title: article.title),
      ),
    );
  }

  setState(() => _markers = markers);
}
```

### Spatio-Temporal Cluster Analysis

```dart
void _showClusterAnalysis() {
  final Map<String, List<NewsArticle>> clusters = {};
  
  // Group by location
  for (var article in _filteredArticles) {
    final key = article.location ?? 'Unknown';
    clusters[key] = (clusters[key] ?? [])..add(article);
  }

  // Display in bottom sheet
  showModalBottomSheet(
    context: context,
    builder: (context) => ListView.builder(
      itemCount: clusters.length,
      itemBuilder: (context, index) {
        final region = clusters.keys.elementAt(index);
        final articles = clusters[region]!;
        return ListTile(
          title: Text(region),
          subtitle: Text('${articles.length} articles'),
          trailing: Text(_getTimeRange(articles)),
        );
      },
    ),
  );
}
```

---

## UI Components

### Info Panel (Top)
Shows when region is selected:
- Selected region coordinates
- Article count within radius
- Search radius in km

### Legend (Bottom Left)
Shows marker color meanings:
- Positive (green)
- Neutral (yellow/orange)
- Negative (red)

### Article Bottom Sheet
Appears when tapping article marker:
- Article title (bold)
- Source name + time ago
- Sentiment badge (colored)
- Summary (3 lines)
- "Read Full Article" button

---

## Performance Considerations

### Marker Optimization
- Only creates markers for articles with coordinates
- Limits to 100 articles by default
- Updates markers only when needed

### Distance Calculations
- Uses Haversine formula (accurate)
- Batch calculations in filtering
- Results cached until map tap

### Loading States
- Shows loading spinner during:
  - Initial location request
  - Article loading from database
- Graceful error handling for permission denials

---

## Error Handling

### Location Permission Denied
```dart
try {
  final position = await _locationService.determinePosition();
  // Use position
} catch (e) {
  _showError('Failed to get location: $e');
  // Falls back to default location (San Francisco)
}
```

### No Articles Found
- Shows all markers if database is empty
- Info panel shows "0 articles"
- User can still interact with map

---

## Future Enhancements

1. **Heatmap View**
   - Visualize news density
   - Color intensity based on article count

2. **Time-based Filtering**
   - Slider for date range
   - Animate news evolution over time

3. **Custom Regions**
   - Draw polygons on map
   - Save favorite regions

4. **Offline Maps**
   - Cache map tiles
   - Work without internet

5. **AR Integration**
   - Point camera to see news markers
   - Overlayed article previews

---

## Troubleshooting

### Map Doesn't Load
- Verify Google Maps API key in AndroidManifest.xml
- Check internet connection
- Ensure Maps SDK billing is enabled

### No Markers Appearing
- Verify articles have `latitude` and `longitude` fields
- Check database has cached articles
- Run app after adding test data

### Location Permission Issues
- Grant location permission in Android settings
- Restart app after granting permission
- Check AndroidManifest.xml has location permissions

---

**The Map Feature is fully functional and ready for production use!** ✅
