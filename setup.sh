#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Function to install CloudQuery
install_cloudquery() {
    local os=$(detect_os)
    local arch="amd64"
    
    if [[ "$(uname -m)" == "arm64" ]] || [[ "$(uname -m)" == "aarch64" ]]; then
        arch="arm64"
    fi
    
    print_status "Installing CloudQuery CLI for $os-$arch..."
    
    # Download CloudQuery
    local download_url="https://github.com/cloudquery/cloudquery/releases/latest/download/cloudquery_${os}_${arch}"
    local temp_file="/tmp/cloudquery"
    
    if curl -L "$download_url" -o "$temp_file"; then
        chmod +x "$temp_file"
        
        # Move to appropriate location
        if [[ "$os" == "macos" ]]; then
            sudo mv "$temp_file" /usr/local/bin/cloudquery
        else
            sudo mv "$temp_file" /usr/local/bin/cloudquery
        fi
        
        print_success "CloudQuery CLI installed successfully"
        cloudquery --version
    else
        print_error "Failed to download CloudQuery CLI"
        exit 1
    fi
}

# Function to check Docker
check_docker() {
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first:"
        print_status "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    
    print_success "Docker is running"
}

# Function to check Docker Compose
check_docker_compose() {
    if ! command_exists docker-compose && ! docker compose version >/dev/null 2>&1; then
        print_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    fi
    
    print_success "Docker Compose is available"
}

# Function to setup environment file
setup_env() {
    if [[ ! -f .env ]]; then
        print_status "Creating .env file with default configuration..."
        cat > .env << EOF
# CloudQuery AI Pipeline Demo Environment Configuration

# Database Configuration
POSTGRES_DB=asset_inventory
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_PORT=5433

# AWS Configuration (optional - set these if you have AWS credentials)
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1

# CloudQuery Configuration
CLOUDQUERY_LOG_LEVEL=info
CLOUDQUERY_SYNC_INTERVAL=1h

# AI/ML Configuration
EMBEDDING_MODEL=text-embedding-3-small
EMBEDDING_DIMENSIONS=384
EOF
        print_success ".env file created"
    else
        print_status ".env file already exists"
    fi
}

# Function to check AWS credentials
check_aws_credentials() {
    print_status "Checking AWS credentials..."
    
    # Check if environment variables are set
    if [[ -n "$AWS_ACCESS_KEY_ID" ]] && [[ -n "$AWS_SECRET_ACCESS_KEY" ]]; then
        print_success "AWS credentials found in environment variables"
        
        # Test if the credentials actually work
        if aws sts get-caller-identity >/dev/null 2>&1; then
            local identity=$(aws sts get-caller-identity --query 'Arn' --output text 2>/dev/null || echo "Unknown")
            print_success "AWS credentials are valid - Identity: $identity"
            return 0
        else
            print_warning "AWS environment variables set but credentials are invalid"
            print_status "Please check your AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY values"
            return 1
        fi
    fi
    
    # Check if AWS CLI is configured
    if command_exists aws; then
        if aws sts get-caller-identity >/dev/null 2>&1; then
            local identity=$(aws sts get-caller-identity --query 'Arn' --output text 2>/dev/null || echo "Unknown")
            print_success "AWS credentials configured via AWS CLI - Identity: $identity"
            return 0
        else
            print_warning "AWS CLI installed but credentials not configured or invalid"
        fi
    fi
    
    # No valid credentials found
    print_warning "No valid AWS credentials found"
    echo
    echo -e "${YELLOW}The demo will work with sample data, but you won't be able to sync real AWS data.${NC}"
    echo
    echo "To use real AWS data, you have several options:"
    echo
    echo "1. Set environment variables in your shell:"
    echo "   export AWS_ACCESS_KEY_ID=your_access_key"
    echo "   export AWS_SECRET_ACCESS_KEY=your_secret_key"
    echo "   export AWS_DEFAULT_REGION=us-east-1"
    echo
    echo "2. Configure AWS CLI:"
    echo "   aws configure"
    echo
    echo "3. Visit the AWS Hub page for detailed setup instructions:"
    echo -e "${BLUE}   https://hub.cloudquery.io/plugins/source/aws${NC}"
    echo
    echo "4. Or edit the .env file created by this script and restart setup"
    echo
    return 1
}

# Function to start infrastructure
start_infrastructure() {
    print_status "Starting PostgreSQL with pgvector..."
    
    if docker compose up -d; then
        print_success "Infrastructure started successfully"
        
        # Wait for database to be ready
        print_status "Waiting for database to be ready..."
        local max_attempts=30
        local attempt=1
        
        while [[ $attempt -le $max_attempts ]]; do
            if docker exec cloudquery-postgres pg_isready -U postgres -d asset_inventory >/dev/null 2>&1; then
                print_success "Database is ready"
                break
            fi
            
            if [[ $attempt -eq $max_attempts ]]; then
                print_error "Database failed to start within expected time"
                exit 1
            fi
            
            print_status "Waiting for database... (attempt $attempt/$max_attempts)"
            sleep 2
            ((attempt++))
        done
    else
        print_error "Failed to start infrastructure"
        exit 1
    fi
}

# Function to load sample data
load_sample_data() {
    if [[ -f sample_data.sql ]]; then
        print_status "Loading sample data..."
        if docker exec -i cloudquery-postgres psql -U postgres -d asset_inventory < sample_data.sql; then
            print_success "Sample data loaded successfully"
        else
            print_warning "Failed to load sample data (this is not critical)"
        fi
    else
        print_warning "sample_data.sql not found - skipping sample data load"
    fi
}

# Function to verify setup
verify_setup() {
    print_status "Verifying setup..."
    
    # Check CloudQuery
    if command_exists cloudquery; then
        print_success "✓ CloudQuery CLI installed"
    else
        print_error "✗ CloudQuery CLI not found"
    fi
    
    # Check Docker
    if docker info >/dev/null 2>&1; then
        print_success "✓ Docker is running"
    else
        print_error "✗ Docker is not running"
    fi
    
    # Check database connection
    if docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c "SELECT 1;" >/dev/null 2>&1; then
        print_success "✓ Database connection successful"
    else
        print_error "✗ Database connection failed"
    fi
    
    # Check pgvector extension
    if docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c "SELECT extname FROM pg_extension WHERE extname = 'vector';" | grep -q vector; then
        print_success "✓ pgvector extension loaded"
    else
        print_error "✗ pgvector extension not found"
    fi
}

# Function to show next steps
show_next_steps() {
    echo
    echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
    echo
    
    # Check if we have AWS credentials for different guidance
    local has_aws_creds=false
    if [[ -n "$AWS_ACCESS_KEY_ID" ]] && [[ -n "$AWS_SECRET_ACCESS_KEY" ]]; then
        if aws sts get-caller-identity >/dev/null 2>&1; then
            has_aws_creds=true
        fi
    elif command_exists aws && aws sts get-caller-identity >/dev/null 2>&1; then
        has_aws_creds=true
    fi
    
    if [[ "$has_aws_creds" == "true" ]]; then
        echo -e "${GREEN}✅ AWS credentials configured - ready for real data sync!${NC}"
        echo
        echo "Next steps:"
        echo "1. Run the interactive demo:"
        echo "   ./demo.sh"
        echo
        echo "2. Sync real AWS data:"
        echo "   cloudquery sync aws_to_postgresql.yaml"
        echo
        echo "3. Connect to the database:"
        echo "   psql postgresql://postgres:postgres@localhost:5433/asset_inventory"
        echo
        echo "4. Explore the sample queries in queries.sql"
    else
        echo -e "${YELLOW}⚠️  Using sample data - AWS credentials not configured${NC}"
        echo
        echo "Next steps:"
        echo "1. Run the interactive demo with sample data:"
        echo "   ./demo.sh"
        echo
        echo "2. To sync real AWS data, configure credentials first:"
        echo "   - Set environment variables: export AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=..."
        echo "   - Or run: aws configure"
        echo "   - Or visit: https://hub.cloudquery.io/plugins/source/aws"
        echo
        echo "3. Connect to the database:"
        echo "   psql postgresql://postgres:postgres@localhost:5433/asset_inventory"
        echo
        echo "4. Explore the sample queries in queries.sql"
    fi
    
    echo
    echo "For more information, see README.md"
}

# Main setup function
main() {
    echo -e "${BLUE}🚀 CloudQuery AI Pipeline Demo Setup${NC}"
    echo "=========================================="
    echo
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    check_docker
    check_docker_compose
    
    # Install CloudQuery if not present
    if ! command_exists cloudquery; then
        install_cloudquery
    else
        print_success "CloudQuery CLI already installed"
        cloudquery --version
    fi
    
    # Setup environment
    setup_env
    
    # Check AWS credentials
    check_aws_credentials
    
    # Start infrastructure
    start_infrastructure
    
    # Load sample data
    load_sample_data
    
    # Verify setup
    verify_setup
    
    # Show next steps
    show_next_steps
}

# Run main function
main "$@"
