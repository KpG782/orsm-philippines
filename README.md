# 🗺️ OSRM Philippines Routing Server

Self-hosted OSRM (Open Source Routing Machine) for Philippines road network.

## ✨ Features
- 🇵🇭 Philippines map data from OpenStreetMap
- ⚡ Fast routing calculations (50-200ms response time)
- 🚀 No API limits, no API keys needed
- 💰 Free forever
- 🔒 Self-hosted, private, secure
- 📍 Works offline once deployed

## 📡 API Endpoints

### 1. Calculate Route (Primary)
Get routing information between two or more points.

**Endpoint:**
```
GET http://your-domain:5000/route/v1/driving/{lon1},{lat1};{lon2},{lat2}
```

**Parameters:**
- `overview=false` - Don't include full geometry (faster)
- `overview=full` - Include detailed route geometry
- `steps=true` - Include turn-by-turn instructions
- `alternatives=true` - Return alternative routes

**Example:**
```bash
# Manila (Ayala Ave) to Quezon City
curl "http://your-domain:5000/route/v1/driving/121.0244,14.5547;121.0437,14.6760?overview=false"
```

**Response:**
```json
{
  "code": "Ok",
  "routes": [{
    "distance": 17423.4,      // meters
    "duration": 1260.7,       // seconds (21 minutes)
    "legs": [{
      "distance": 17423.4,
      "duration": 1260.7,
      "steps": []
    }]
  }],
  "waypoints": [...]
}
```

### 2. Calculate Distance Matrix
Get distance/duration between multiple points.

**Endpoint:**
```
GET http://your-domain:5000/table/v1/driving/{lon1},{lat1};{lon2},{lat2};{lon3},{lat3}
```

**Example:**
```bash
# Distance matrix for 3 locations
curl "http://your-domain:5000/table/v1/driving/121.0244,14.5547;121.0437,14.6760;121.0511,14.6091"
```

### 3. Nearest Road (Snap to Road)
Find the nearest road to a given coordinate.

**Endpoint:**
```
GET http://your-domain:5000/nearest/v1/driving/{lon},{lat}
```

**Example:**
```bash
curl "http://your-domain:5000/nearest/v1/driving/121.0244,14.5547"
```

## 🔌 Integration Examples

### Flutter / Dart
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class OsrmService {
  final String baseUrl = 'http://your-vps-ip:5000';
  
  Future<Map<String, dynamic>> getRoute({
    required double startLon,
    required double startLat,
    required double endLon,
    required double endLat,
  }) async {
    final url = '$baseUrl/route/v1/driving/$startLon,$startLat;$endLon,$endLat?overview=false';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get route');
    }
  }
  
  Future<Duration> getETA({
    required double startLon,
    required double startLat,
    required double endLon,
    required double endLat,
  }) async {
    final data = await getRoute(
      startLon: startLon,
      startLat: startLat,
      endLon: endLon,
      endLat: endLat,
    );
    
    final durationSeconds = data['routes'][0]['duration'];
    return Duration(seconds: durationSeconds.toInt());
  }
  
  Future<double> getDistance({
    required double startLon,
    required double startLat,
    required double endLon,
    required double endLat,
  }) async {
    final data = await getRoute(
      startLon: startLon,
      startLat: startLat,
      endLon: endLon,
      endLat: endLat,
    );
    
    final distanceMeters = data['routes'][0]['distance'];
    return distanceMeters / 1000; // Convert to kilometers
  }
}

// Usage Example:
void main() async {
  final osrm = OsrmService();
  
  // Get ETA from Manila to Quezon City
  final eta = await osrm.getETA(
    startLon: 121.0244,
    startLat: 14.5547,
    endLon: 121.0437,
    endLat: 14.6760,
  );
  
  print('ETA: ${eta.inMinutes} minutes'); // ETA: 21 minutes
  
  // Get distance
  final distance = await osrm.getDistance(
    startLon: 121.0244,
    startLat: 14.5547,
    endLon: 121.0437,
    endLat: 14.6760,
  );
  
  print('Distance: ${distance.toStringAsFixed(1)} km'); // Distance: 17.4 km
}
```

### JavaScript / Node.js
```javascript
const axios = require('axios');

const OSRM_URL = 'http://your-vps-ip:5000';

async function getRoute(startLon, startLat, endLon, endLat) {
  const url = `${OSRM_URL}/route/v1/driving/${startLon},${startLat};${endLon},${endLat}?overview=false`;
  const response = await axios.get(url);
  return response.data;
}

async function getETA(startLon, startLat, endLon, endLat) {
  const data = await getRoute(startLon, startLat, endLon, endLat);
  const durationSeconds = data.routes[0].duration;
  return Math.round(durationSeconds / 60); // Return minutes
}

// Usage
getETA(121.0244, 14.5547, 121.0437, 14.6760)
  .then(minutes => console.log(`ETA: ${minutes} minutes`));
```

### Python
```python
import requests

OSRM_URL = 'http://your-vps-ip:5000'

def get_route(start_lon, start_lat, end_lon, end_lat):
    url = f'{OSRM_URL}/route/v1/driving/{start_lon},{start_lat};{end_lon},{end_lat}?overview=false'
    response = requests.get(url)
    return response.json()

def get_eta(start_lon, start_lat, end_lon, end_lat):
    data = get_route(start_lon, start_lat, end_lon, end_lat)
    duration_seconds = data['routes'][0]['duration']
    return round(duration_seconds / 60)  # Return minutes

# Usage
eta = get_eta(121.0244, 14.5547, 121.0437, 14.6760)
print(f'ETA: {eta} minutes')
```

## 🚀 Quick Start (Local Development)

### 1. Start the Container
```bash
docker-compose up -d
```

### 2. Copy Your Map File (if you have philippines-*.osm.pbf)
```bash
# Copy your local map file into the container
docker cp philippines-251228.osm.pbf osrm-philippines:/data/philippines-latest.osm.pbf
```

### 3. Process Map Data
```bash
# Stop container first
docker stop osrm-philippines

# Run processing (takes 5-10 minutes)
docker run --rm -v osrm-philippines_osrm-data:/data osrm/osrm-backend:latest osrm-extract -p /opt/car.lua /data/philippines-latest.osm.pbf

docker run --rm -v osrm-philippines_osrm-data:/data osrm/osrm-backend:latest osrm-partition /data/philippines-latest.osrm

docker run --rm -v osrm-philippines_osrm-data:/data osrm/osrm-backend:latest osrm-customize /data/philippines-latest.osrm

# Start container
docker start osrm-philippines
```

**Or use the automated script (Windows):**
```bash
./setup-local.bat
```

### 4. Test Your Server
```bash
# Test routing (should return JSON with distance/duration)
curl "http://localhost:5000/route/v1/driving/121.0244,14.5547;121.0437,14.6760?overview=false"

# Expected: {"code":"Ok","routes":[{"distance":17423.4,"duration":1260.7,...}]}
```

## 📦 Production Deployment (VPS/EasyPanel)

### Option A: Using EasyPanel with Docker Image

1. **In EasyPanel Dashboard:**
   - Click "+ Service"
   - Select "Docker Image" tab
   - Image: `osrm/osrm-backend:latest`
   - Port: `5000:5000`
   - Add volume: `/data`
   - Save & Deploy

2. **SSH into VPS and Process Map Data:**
```bash
# Find container name
docker ps | grep osrm

# Download map data
docker exec -it <container-name> bash
cd /data
wget https://download.geofabrik.de/asia/philippines-latest.osm.pbf

# Process (5-10 minutes)
osrm-extract -p /opt/car.lua philippines-latest.osm.pbf
osrm-partition philippines-latest.osrm
osrm-customize philippines-latest.osrm
exit

# Restart container
docker restart <container-name>
```

3. **Configure Firewall:**
```bash
sudo ufw allow 5000/tcp
sudo ufw reload
```

4. **Test:**
```bash
curl "http://YOUR_VPS_IP:5000/route/v1/driving/121.0244,14.5547;121.0437,14.6760?overview=false"
```

### Option B: Using Docker Compose on VPS

1. **Clone this repository:**
```bash
git clone https://github.com/YOUR_USERNAME/osrm-philippines.git
cd osrm-philippines
```

2. **Start services:**
```bash
docker-compose up -d
```

3. **Follow step 2 from Option A** to process map data

## 🔧 Maintenance

### Update Map Data (Monthly Recommended)
OpenStreetMap data is updated daily, so update your map monthly for best accuracy.

```bash
docker exec -it osrm-philippines bash
cd /data

# Backup old data (optional)
cp philippines-latest.osm.pbf philippines-latest.osm.pbf.backup

# Download fresh map
rm philippines-latest.osm.pbf
wget https://download.geofabrik.de/asia/philippines-latest.osm.pbf

# Process new data
osrm-extract -p /opt/car.lua philippines-latest.osm.pbf
osrm-partition philippines-latest.osrm
osrm-customize philippines-latest.osrm
exit

# Restart
docker-compose restart
```

### Monitor Server
```bash
# View logs
docker-compose logs -f osrm-backend

# Check container status
docker ps

# Check memory usage
docker stats osrm-philippines
```

### Backup Data
```bash
# Backup processed data (faster than re-processing)
docker run --rm -v osrm-philippines_osrm-data:/data -v $(pwd):/backup ubuntu tar czf /backup/osrm-data-backup.tar.gz /data
```

## 📊 Performance & Resources

### Local Testing Results
- **Route Query:** ~50-200ms response time
- **Distance:** Manila to Quezon City = 17.4 km
- **Duration:** ~21 minutes (with traffic patterns)
- **Memory Usage:** ~2-4 GB RAM
- **Disk Space:** ~3 GB (processed data)

### System Requirements
- **Minimum:** 2 GB RAM, 5 GB disk space
- **Recommended:** 4 GB RAM, 10 GB disk space (for updates)
- **CPU:** Any modern CPU (processing uses all cores)

## 🛠️ Technical Details

- **Image:** `osrm/osrm-backend:latest`
- **Port:** 5000
- **Algorithm:** MLD (Multi-Level Dijkstra) - Fastest for real-time routing
- **Map Source:** Geofabrik OpenStreetMap
- **Map Update Frequency:** Daily (Geofabrik)
- **Data Size:** 
  - Raw OSM PBF: ~560 MB
  - Processed OSRM files: ~2.8 GB
- **Processing Time:** 5-10 minutes (depends on CPU)

## 🎯 Use Cases for ARS App

### 1. Real-time ETA Display
Show estimated arrival time for ambulance/responder
```dart
final eta = await osrm.getETA(ambulanceLon, ambulanceLat, patientLon, patientLat);
// Display: "Ambulance arriving in ${eta.inMinutes} minutes"
```

### 2. Distance Calculation
Calculate how far the responder is from the emergency
```dart
final distance = await osrm.getDistance(responderLon, responderLat, emergencyLon, emergencyLat);
// Display: "Responder is ${distance.toStringAsFixed(1)} km away"
```

### 3. Route Visualization
Get route geometry to display on map
```dart
final url = '$baseUrl/route/v1/driving/$startLon,$startLat;$endLon,$endLat?overview=full&geometries=geojson';
// Returns GeoJSON geometry to draw on map
```

### 4. Nearest Responder
Find closest available responder using distance matrix
```dart
// Get distances from all responders to emergency location
final url = '$baseUrl/table/v1/driving/$responder1Coords;$responder2Coords;$responder3Coords;$emergencyCoords';
// Returns matrix of distances - pick shortest
```

## 🐛 Troubleshooting

### Container keeps restarting
- **Cause:** Missing map data files
- **Fix:** Ensure you've processed the map data (extract, partition, customize)

### "No route found" error
- **Cause:** Coordinates outside Philippines or disconnected roads
- **Fix:** Verify coordinates are within Philippines bounds (approx 116-127°E, 5-20°N)

### Slow response times
- **Cause:** Insufficient RAM or CPU
- **Fix:** Allocate more resources or optimize max-table-size parameter

### Port 5000 not accessible
- **Cause:** Firewall blocking or container not running
- **Fix:** 
  ```bash
  sudo ufw allow 5000/tcp
  docker ps  # Verify container is running
  ```

## 📚 Additional Resources

- [OSRM API Documentation](http://project-osrm.org/docs/v5.24.0/api/)
- [OpenStreetMap Philippines](https://openstreetmap.org.ph/)
- [Geofabrik Download Server](https://download.geofabrik.de/asia/philippines.html)
- [OSRM GitHub](https://github.com/Project-OSRM/osrm-backend)

## 📝 License

This project uses:
- **OSRM Backend:** BSD License
- **OpenStreetMap Data:** ODbL License

## 🤝 Contributing

Found an issue? Want to improve the setup?
1. Fork this repository
2. Make your changes
3. Submit a pull request

---

**Made with ❤️ for the ARS Emergency Response System**
