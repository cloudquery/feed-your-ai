#!/usr/bin/env bash

set -e

echo "🧹 CloudQuery AI Pipeline Demo - Cleanup"
echo "========================================"
echo

# Function to confirm action
confirm() {
    read -p "$1 (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

echo "This script will:"
echo "1. Stop all running containers"
echo "2. Remove containers and volumes"
echo "3. Clean up temporary files"
echo

if ! confirm "Are you sure you want to continue?"; then
    echo "Cleanup cancelled."
    exit 0
fi

echo
echo "Stopping containers..."
docker compose down -v

echo "Removing containers and volumes..."
docker compose down -v --remove-orphans

echo "Cleaning up temporary files..."
rm -f .env
rm -rf postgres_data/

echo "Checking for orphaned containers..."
if docker ps -a --filter "name=cloudquery" | grep -q cloudquery; then
    echo "Removing orphaned containers..."
    docker ps -a --filter "name=cloudquery" --format "{{.ID}}" | xargs -r docker rm -f
fi

echo "Checking for orphaned volumes..."
if docker volume ls --filter "name=cloudquery" | grep -q cloudquery; then
    echo "Removing orphaned volumes..."
    docker volume ls --filter "name=cloudquery" --format "{{.Name}}" | xargs -r docker volume rm
fi

echo
echo "✅ Cleanup completed successfully!"
echo
echo "To start fresh, run:"
echo "  ./setup.sh    # Full setup with CloudQuery installation"
echo "  ./quickstart.sh # Quick start with existing setup"
echo
echo "Or manually:"
echo "  docker compose up -d"
