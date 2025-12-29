# Use official OSRM backend image
FROM osrm/osrm-backend:latest

# Expose port
EXPOSE 5000

# Set working directory
WORKDIR /data

# Default command (will be overridden by docker-compose)
CMD ["osrm-routed", "--algorithm", "mld", "/data/philippines-latest.osrm", "--max-table-size", "10000"]
