#!/usr/bin/env bash

set -e

echo "🚀 CloudQuery AI Pipeline Demo - Quick Start"
echo "============================================"
echo

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

echo "✅ Docker is running"
echo

# Start the infrastructure
echo "Starting PostgreSQL with pgvector..."
docker compose up -d

# Wait for database
echo "Waiting for database to be ready..."
sleep 10

# Check if database is ready
if docker exec cloudquery-postgres pg_isready -U postgres -d asset_inventory >/dev/null 2>&1; then
    echo "✅ Database is ready"
else
    echo "❌ Database failed to start. Check docker-compose logs."
    exit 1
fi

# Load sample data if available
if [[ -f sample_data.sql ]]; then
    echo "Loading sample data..."
    docker exec -i cloudquery-postgres psql -U postgres -d asset_inventory < sample_data.sql
    echo "✅ Sample data loaded"
fi

echo
echo "🎉 Quick setup complete!"
echo
echo "Next steps:"
echo "1. Run the interactive demo: ./demo.sh"
echo "2. Or connect to the database:"
echo "   psql postgresql://postgres:postgres@localhost:5433/asset_inventory"
echo
echo "To stop the infrastructure: docker compose down"
