# CloudQuery AI Pipeline Demo - Complete Setup Guide

This guide walks you through setting up a complete CloudQuery AI pipeline with PostgreSQL, pgvector, and MCP server integration from scratch.

## 🎯 What We're Building

- **CloudQuery** - Infrastructure data extraction and transformation
- **PostgreSQL with pgvector** - AI-ready database with vector similarity search
- **MCP Server** - AI-powered infrastructure analysis and insights
- **Demo Scripts** - Interactive demonstrations of the capabilities

## 📋 Prerequisites

- Docker and Docker Compose installed
- CloudQuery CLI installed (`brew install cloudquery/tap/cloudquery`)
- Basic understanding of AWS infrastructure concepts

## 🚀 Step-by-Step Setup

### 1. Project Initialization

```bash
# Create project directory
mkdir cloudquery-ai-pipeline-demo
cd cloudquery-ai-pipeline-demo

# Initialize git repository
git init
git branch -m main
```

### 2. Docker Compose Setup

Create `docker-compose.yml`:

```yaml
version: '3.8'
services:
  cloudquery-postgres:
    image: pgvector/pgvector:pg16
    container_name: cloudquery-postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: asset_inventory
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  postgres_data:
```

### 3. Database Initialization

Create `init.sql`:

```sql
-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create resource embeddings table for AI analysis
CREATE TABLE IF NOT EXISTS resource_embeddings (
    id SERIAL PRIMARY KEY,
    resource_type VARCHAR(100),
    resource_id VARCHAR(255),
    resource_data JSONB,
    embedding vector(384),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create function for generating mock embeddings
CREATE OR REPLACE FUNCTION generate_mock_embedding(resource_data JSONB)
RETURNS vector AS $$
BEGIN
    RETURN (
        SELECT ARRAY(
            SELECT random()::float4 
            FROM generate_series(1, 384)
        )::vector
    );
END;
$$ LANGUAGE plpgsql;
```

### 4. CloudQuery Configuration

Create `aws_to_postgresql.yaml`:

```yaml
kind: source
spec:
  name: aws
  version: v32.36.0
  tables: ["aws_ec2_instances", "aws_s3_buckets", "aws_ec2_security_groups"]
  destinations: ["postgresql"]
  spec:
    # AWS credentials will be configured separately
    regions: ["us-east-1", "us-west-2"]

---
kind: destination
spec:
  name: postgresql
  version: v8.9.0
  spec:
    connection_string: "postgresql://postgres:postgres@localhost:5432/asset_inventory?sslmode=disable"
    pgx_log_level: debug
```

### 5. Sample Data Setup

Create `sample_data.sql` with realistic AWS infrastructure data:

```sql
-- Insert sample EC2 instances data
INSERT INTO aws_ec2_instances (_cq_id, account_id, region, instance_id, instance_type, state, vpc_id, tags, public_ip_address, private_ip_address, launch_time) VALUES
(gen_random_uuid(), '123456789012', 'us-east-1', 'i-0abcd1234efgh5678', 't3.micro', '{"Name": "running"}', 'vpc-12345678', '{"Name": "WebServer-1", "Environment": "production", "Team": "backend"}', '54.123.45.67', '10.0.1.100', '2023-01-15 10:30:00'),
(gen_random_uuid(), '123456789012', 'us-east-1', 'i-0xyz9876fedcb5432', 't3.small', '{"Name": "running"}', 'vpc-12345678', '{"Name": "Database-1", "Environment": "production", "Team": "data"}', NULL, '10.0.2.50', '2023-01-15 11:00:00'),
(gen_random_uuid(), '123456789012', 'us-west-2', 'i-0def4567890abc123', 't3.medium', '{"Name": "stopped"}', 'vpc-87654321', '{"Name": "Development-1", "Environment": "development", "Team": "frontend"}', '34.56.89.12', '10.1.1.75', '2023-01-15 12:00:00'),
(gen_random_uuid(), '123456789012', 'us-west-2', 'i-0ghi7890123def456', 't2.micro', '{"Name": "running"}', 'vpc-87654321', '{"Name": "Monitoring-1", "Environment": "production", "Team": "devops"}', '52.234.56.78', '10.1.2.25', '2023-01-15 13:00:00');

-- Insert sample S3 buckets data
INSERT INTO aws_s3_buckets (account_id, region, name, creation_date, versioning_status, encryption_configuration, tags) VALUES
('123456789012', 'us-east-1', 'company-data-backup', '2023-01-15 10:30:00', 'Enabled', '{"ServerSideEncryptionConfiguration": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}', '{"Environment": "production", "Purpose": "backup", "Team": "data"}'),
('123456789012', 'us-east-1', 'app-logs-storage', '2023-03-20 14:45:00', 'Suspended', '{"ServerSideEncryptionConfiguration": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "aws:kms"}}]}', '{"Environment": "production", "Purpose": "logs", "Team": "backend"}'),
('123456789012', 'us-west-2', 'dev-artifacts', '2023-06-10 09:15:00', 'Enabled', '{}', '{"Environment": "development", "Purpose": "artifacts", "Team": "frontend"}');

-- Insert sample security groups data
INSERT INTO aws_ec2_security_groups (account_id, region, group_id, group_name, description, vpc_id, ip_permissions, tags) VALUES
('123456789012', 'us-east-1', 'sg-0123456789abcdef0', 'web-servers-sg', 'Security group for web servers', 'vpc-12345678', '[{"IpProtocol": "tcp", "FromPort": 80, "ToPort": 80, "IpRanges": [{"CidrIp": "0.0.0.0/0"}]}, {"IpProtocol": "tcp", "FromPort": 443, "ToPort": 443, "IpRanges": [{"CidrIp": "0.0.0.0/0"}]}]', '{"Environment": "production", "Team": "backend"}'),
('123456789012', 'us-east-1', 'sg-0fedcba9876543210', 'database-sg', 'Security group for database servers', 'vpc-12345678', '[{"IpProtocol": "tcp", "FromPort": 5432, "ToPort": 5432, "UserIdGroupPairs": [{"GroupId": "pg-0123456789abcdef0"}]}]', '{"Environment": "production", "Team": "data"}');
```

### 6. MCP Server Configuration

Create `.cursor/mcp.json` for Cursor integration:

```json
{
  "mcpServers": {
    "cloudquery": {
      "command": "/path/to/your/cq-platform-mcp",
      "args": [],
      "env": {
        "POSTGRES_CONNECTION_STRING": "postgresql://postgres:postgres@localhost:5432/asset_inventory?sslmode=disable"
      }
    }
  }
}
```

### 7. Demo Magic Setup

Create `demo-magic.sh` for interactive demos:

```bash
#!/usr/bin/env bash
# Demo Magic - a tool to make your shell demos look awesome
# Usage: . demo-magic.sh

# Colors and functions for interactive demos
# (Full script content available in the repository)
```

### 8. Demo Script

Create `demo.sh` for showcasing the capabilities:

```bash
#!/usr/bin/env bash
# CloudQuery AI Pipeline Demo
# Demonstrates infrastructure analysis with pgvector AI capabilities

. ./demo-magic.sh

# Demo steps with pgvector AI analysis
# (Full script content available in the repository)
```

## 🔧 Setup Commands

```bash
# Start the database
docker compose up -d

# Wait for database to be ready
sleep 5
docker exec cloudquery-postgres pg_isready -U postgres

# Initialize database
docker exec -i cloudquery-postgres psql -U postgres -d asset_inventory < init.sql

# Load sample data
docker exec -i cloudquery-postgres psql -U postgres -d asset_inventory < sample_data.sql

# Create embeddings for AI analysis
docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c "
INSERT INTO resource_embeddings (resource_type, resource_id, resource_data, embedding)
SELECT 
    'ec2_instance',
    instance_id,
    jsonb_build_object(
        'instance_type', instance_type,
        'state', state,
        'environment', tags->>'Environment',
        'team', tags->>'Team',
        'region', region,
        'has_public_ip', (public_ip_address IS NOT NULL)
    ),
    generate_mock_embedding(tags)
FROM aws_ec2_instances
ON CONFLICT (resource_type, resource_id) DO NOTHING;"
```

## 🧪 Testing the Setup

```bash
# Verify database is running
docker ps | grep cloudquery-postgres

# Check pgvector extension
docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c "SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';"

# Verify sample data
docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c "SELECT COUNT(*) as instances FROM aws_ec2_instances;"

# Test vector similarity
docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c "SELECT COUNT(*) as embeddings FROM resource_embeddings;"
```

## 🚀 Running the Demo

```bash
# Make demo script executable
chmod +x demo.sh

# Run interactive demo
./demo.sh

# Run demo without waiting (for testing)
./demo.sh -d
```

## 🔍 What Each Component Does

### **CloudQuery**
- Extracts AWS infrastructure data into structured format
- Handles authentication and API rate limiting
- Transforms data for analysis

### **PostgreSQL + pgvector**
- Stores infrastructure data in relational format
- Enables vector similarity search for AI analysis
- Provides fast querying and aggregation

### **MCP Server**
- Connects AI tools to your infrastructure data
- Enables natural language queries about your infrastructure
- Provides intelligent insights and recommendations

### **Demo Scripts**
- Showcase real-world use cases
- Demonstrate AI-powered analysis capabilities
- Provide educational examples for teams

## 🎯 Next Steps

1. **Customize sample data** for your specific use cases
2. **Integrate with real AWS accounts** for production data
3. **Extend MCP server** with additional AI capabilities
4. **Build custom dashboards** using the prepared data
5. **Train custom AI models** on your infrastructure patterns

## 📚 Additional Resources

- [CloudQuery Documentation](https://www.cloudquery.io/docs)
- [pgvector Documentation](https://github.com/pgvector/pgvector)
- [MCP Protocol](https://modelcontextprotocol.io/)
- [PostgreSQL JSON Functions](https://www.postgresql.org/docs/current/functions-json.html)

## 🆘 Troubleshooting

### Common Issues

1. **Database connection failed**
   - Check if Docker container is running
   - Verify connection string in MCP config

2. **pgvector extension not found**
   - Ensure you're using the pgvector Docker image
   - Check extension installation in init.sql

3. **Sample data not loading**
   - Verify table schemas match CloudQuery output
   - Check for JSON syntax errors in sample data

4. **MCP server not connecting**
   - Verify binary path in MCP config
   - Check environment variables are set correctly

### Getting Help

- Check the CloudQuery logs: `cloudquery sync --log-level debug`
- Verify database connectivity: `docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c "SELECT 1;"`
- Test MCP server manually: `POSTGRES_CONNECTION_STRING="..." /path/to/cq-platform-mcp`

---

**Happy Infrastructure Analysis! 🚀**
