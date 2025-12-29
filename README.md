# OSRM Philippines Routing Server

Self-hosted OSRM (Open Source Routing Machine) for Philippines road network.

## Features
- Philippines map data from OpenStreetMap
- Fast routing calculations (50-200ms response time)
- No API limits
- Free forever

## API Endpoints

### Health Check
```
GET http://your-domain:5000/health
```

### Calculate Route
```
GET http://your-domain:5000/route/v1/driving/{lon1},{lat1};{lon2},{lat2}?overview=false
```

### Example
```bash
# Manila to Quezon City
curl "http://your-domain:5000/route/v1/driving/121.0244,14.5547;121.0437,14.6760?overview=false"
```

## Setup Instructions

### 1. Deploy with Docker Compose
```bash
docker-compose up -d
```

### 2. Download & Process Map Data (One-time)
```bash
# Enter container
docker exec -it osrm-philippines bash

# Download Philippines map (~500MB)
cd /data
wget https://download.geofabrik.de/asia/philippines-latest.osm.pbf

# Process map data (takes 5-10 minutes)
osrm-extract -p /opt/car.lua philippines-latest.osm.pbf
osrm-partition philippines-latest.osrm
osrm-customize philippines-latest.osrm

# Exit and restart
exit
docker-compose restart
```

### 3. Test
```bash
curl http://localhost:5000/health
# Should return: Ok
```

## Maintenance

### Update map data (monthly recommended)
```bash
docker exec -it osrm-philippines bash
cd /data
rm philippines-latest.osm.pbf
wget https://download.geofabrik.de/asia/philippines-latest.osm.pbf
osrm-extract -p /opt/car.lua philippines-latest.osm.pbf
osrm-partition philippines-latest.osrm
osrm-customize philippines-latest.osrm
exit
docker-compose restart
```

### View logs
```bash
docker-compose logs -f osrm-backend
```

## Technical Details

- **Image:** `osrm/osrm-backend:latest`
- **Port:** 5000
- **Algorithm:** MLD (Multi-Level Dijkstra)
- **Map Source:** Geofabrik OpenStreetMap
- **Update Frequency:** Daily (Geofabrik)
