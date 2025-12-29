#!/bin/bash
# Helper script to setup OSRM map data

echo "🗺️  Setting up OSRM Philippines map data..."
echo ""

# Check if container is running
if ! docker ps | grep -q osrm-philippines; then
    echo "❌ Error: osrm-philippines container is not running"
    echo "   Run: docker-compose up -d"
    exit 1
fi

echo "📥 Downloading Philippines map data (~500MB)..."
docker exec osrm-philippines bash -c "
    cd /data && \
    wget -q --show-progress https://download.geofabrik.de/asia/philippines-latest.osm.pbf
"

echo ""
echo "⚙️  Processing map data (this takes 5-10 minutes)..."
echo ""

docker exec osrm-philippines bash -c "
    cd /data && \
    echo '  → Extracting...' && \
    osrm-extract -p /opt/car.lua philippines-latest.osm.pbf && \
    echo '  → Partitioning...' && \
    osrm-partition philippines-latest.osrm && \
    echo '  → Customizing...' && \
    osrm-customize philippines-latest.osrm
"

echo ""
echo "🔄 Restarting OSRM server..."
docker-compose restart

echo ""
echo "✅ Setup complete! Waiting for OSRM to start..."
sleep 5

echo ""
echo "🧪 Testing server..."
if curl -s http://localhost:5000/health | grep -q "Ok"; then
    echo "✅ OSRM server is running!"
    echo ""
    echo "📍 API URL: http://localhost:5000"
    echo "📍 Health check: http://localhost:5000/health"
    echo ""
    echo "🎉 You're ready to use OSRM!"
else
    echo "⚠️  Server is starting... please wait 30 seconds and test manually:"
    echo "   curl http://localhost:5000/health"
fi
