#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏥 CloudQuery AI Pipeline Demo - Health Check${NC}"
echo "================================================"
echo

# Function to print status
print_status() {
    local status=$1
    local message=$2
    
    if [[ "$status" == "OK" ]]; then
        echo -e "${GREEN}✅ $message${NC}"
    elif [[ "$status" == "WARNING" ]]; then
        echo -e "${YELLOW}⚠️  $message${NC}"
    else
        echo -e "${RED}❌ $message${NC}"
    fi
}

# Function to check command exists
check_command() {
    local cmd=$1
    local name=$2
    
    if command -v "$cmd" >/dev/null 2>&1; then
        print_status "OK" "$name is installed"
        return 0
    else
        print_status "ERROR" "$name is not installed"
        return 1
    fi
}

# Function to check Docker
check_docker() {
    echo -e "${BLUE}Checking Docker...${NC}"
    
    if ! command -v docker >/dev/null 2>&1; then
        print_status "ERROR" "Docker is not installed"
        echo "   Install Docker from: https://docs.docker.com/get-docker/"
        return 1
    fi
    
    if docker info >/dev/null 2>&1; then
        print_status "OK" "Docker is running"
        
        local version=$(docker --version)
        echo "   Version: $version"
        
        local compose_version=$(docker compose version 2>/dev/null || echo "Not available")
        echo "   Compose: $compose_version"
    else
        print_status "ERROR" "Docker is not running"
        echo "   Start Docker Desktop or Docker daemon"
        return 1
    fi
}

# Function to check CloudQuery
check_cloudquery() {
    echo -e "${BLUE}Checking CloudQuery...${NC}"
    
    if command -v cloudquery >/dev/null 2>&1; then
        print_status "OK" "CloudQuery CLI is installed"
        local version=$(cloudquery --version 2>/dev/null || echo "Unknown version")
        echo "   Version: $version"
    else
        print_status "WARNING" "CloudQuery CLI is not installed"
        echo "   Run: ./setup.sh to install automatically"
        echo "   Or install manually: https://docs.cloudquery.io/docs/getting-started/installation"
    fi
}

# Function to check AWS credentials
check_aws() {
    echo -e "${BLUE}Checking AWS Configuration...${NC}"
    
    if [[ -n "$AWS_ACCESS_KEY_ID" ]] && [[ -n "$AWS_SECRET_ACCESS_KEY" ]]; then
        print_status "OK" "AWS credentials found in environment"
    elif command -v aws >/dev/null 2>&1; then
        if aws sts get-caller-identity >/dev/null 2>&1; then
            print_status "OK" "AWS credentials configured via AWS CLI"
            local identity=$(aws sts get-caller-identity --query 'Arn' --output text 2>/dev/null || echo "Unknown")
            echo "   Identity: $identity"
        else
            print_status "WARNING" "AWS CLI configured but credentials not working"
            echo "   Run: aws configure"
        fi
    else
        print_status "WARNING" "No AWS credentials found"
        echo "   The demo will work with sample data"
        echo "   To use real AWS data:"
        echo "     - Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables"
        echo "     - Or run: aws configure"
    fi
}

# Function to check infrastructure
check_infrastructure() {
    echo -e "${BLUE}Checking Infrastructure...${NC}"
    
    # Check if containers are running
    if docker ps --filter "name=cloudquery-postgres" | grep -q cloudquery-postgres; then
        print_status "OK" "PostgreSQL container is running"
        
        # Check database connection
        if docker exec cloudquery-postgres pg_isready -U postgres -d asset_inventory >/dev/null 2>&1; then
            print_status "OK" "Database is accessible"
            
            # Check pgvector extension
            if docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c "SELECT extname FROM pg_extension WHERE extname = 'vector';" | grep -q vector; then
                print_status "OK" "pgvector extension is loaded"
            else
                print_status "ERROR" "pgvector extension not found"
                echo "   Check init.sql and restart containers"
            fi
            
            # Check sample data
            local table_count=$(docker exec cloudquery-postgres psql -U postgres -d asset_inventory -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" | tr -d ' ')
            if [[ "$table_count" -gt 0 ]]; then
                print_status "OK" "Database has $table_count tables"
            else
                print_status "WARNING" "Database appears empty"
                echo "   Run: ./quickstart.sh to load sample data"
            fi
        else
            print_status "ERROR" "Database is not accessible"
            echo "   Check container logs: docker logs cloudquery-postgres"
        fi
    else
        print_status "WARNING" "PostgreSQL container is not running"
        echo "   Run: ./quickstart.sh to start infrastructure"
    fi
}

# Function to check ports
check_ports() {
    echo -e "${BLUE}Checking Ports...${NC}"
    
    local port_5433=$(lsof -i :5433 2>/dev/null | grep LISTEN || echo "")
    if [[ -n "$port_5433" ]]; then
        print_status "OK" "Port 5433 is listening (PostgreSQL)"
    else
        print_status "WARNING" "Port 5433 is not listening"
        echo "   PostgreSQL may not be running or accessible"
    fi
}

# Function to check files
check_files() {
    echo -e "${BLUE}Checking Project Files...${NC}"
    
    local required_files=("docker-compose.yml" "init.sql" "demo.sh")
    local optional_files=("sample_data.sql" "queries.sql" ".env")
    
    for file in "${required_files[@]}"; do
        if [[ -f "$file" ]]; then
            print_status "OK" "$file exists"
        else
            print_status "ERROR" "$file is missing"
        fi
    done
    
    for file in "${optional_files[@]}"; do
        if [[ -f "$file" ]]; then
            print_status "OK" "$file exists"
        else
            print_status "WARNING" "$file is missing (optional)"
        fi
    done
}

# Function to provide recommendations
provide_recommendations() {
    echo
    echo -e "${BLUE}📋 Recommendations:${NC}"
    
    if ! command -v cloudquery >/dev/null 2>&1; then
        echo "• Install CloudQuery: ./setup.sh"
    fi
    
    if ! docker ps --filter "name=cloudquery-postgres" | grep -q cloudquery-postgres; then
        echo "• Start infrastructure: ./quickstart.sh"
    fi
    
    if [[ -z "$AWS_ACCESS_KEY_ID" ]] && ! aws sts get-caller-identity >/dev/null 2>&1; then
        echo "• Configure AWS credentials for real data sync"
    fi
    
    echo "• Run the demo: ./demo.sh"
    echo "• Explore queries: cat queries.sql"
    echo "• Check logs: docker logs cloudquery-postgres"
}

# Main health check
main() {
    check_docker
    echo
    
    check_cloudquery
    echo
    
    check_aws
    echo
    
    check_infrastructure
    echo
    
    check_ports
    echo
    
    check_files
    echo
    
    provide_recommendations
    echo
    
    echo -e "${GREEN}Health check completed!${NC}"
}

# Run main function
main "$@"
