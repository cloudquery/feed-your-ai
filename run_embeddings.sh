#!/bin/bash

echo "🚀 Starting Local Embedding Generation for CloudQuery AI Pipeline"
echo "================================================================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if the database is running
if ! docker ps | grep -q "cloudquery-postgres"; then
    echo "❌ PostgreSQL database is not running. Starting it now..."
    docker compose up -d postgres
    
    echo "⏳ Waiting for database to be ready..."
    sleep 10
    
    # Wait for database to be healthy
    while ! docker exec cloudquery-postgres pg_isready -U postgres -d asset_inventory > /dev/null 2>&1; do
        echo "⏳ Waiting for database to be ready..."
        sleep 5
    done
fi

echo "✅ Database is ready"

# Check if we have the required Python files
if [ ! -f "generate_embeddings.py" ]; then
    echo "❌ generate_embeddings.py not found!"
    exit 1
fi

if [ ! -f "requirements.txt" ]; then
    echo "❌ requirements.txt not found!"
    exit 1
fi

echo "🔧 Building embedding service..."
docker compose build embeddings

echo "🚀 Running embedding generation..."
docker compose run --rm embeddings

echo ""
echo "🧪 Testing embeddings..."
python3 test_embeddings.py

echo ""
echo "🎉 Embedding generation complete!"
echo "You can now run the demo with real embeddings!"
