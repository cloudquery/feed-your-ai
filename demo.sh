#!/usr/bin/env bash

#################################
# include the -=magic=-
# you can pass command line args
#
# example:
# to disable simulated typing
# . ../demo-magic.sh -d
#
# pass -h to see all options
#################################
. ./demo-magic.sh

########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
TYPE_SPEED=100

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

clear

p "CloudQuery AI Pipeline Demo - Complete Setup & Data Sync Process"
wait

p "This demo walks through the complete process: setting up CloudQuery, syncing AWS data to PostgreSQL, and then enabling AI analysis with pgvector"
wait

clear

p "Phase 1: Project Setup & CloudQuery Initialization"
wait

p "Step 1: Check our current project structure"
wait

# 📁 This shows our current project setup and what we're working with
pei "ls -la"
wait

p "Step 2: Verify CloudQuery CLI is installed"
wait

# 🔧 This checks if CloudQuery is available and shows the version
pei "cloudquery --version"
wait

p "Step 3: Initialize CloudQuery project with AWS source"
wait

# 🚀 This creates the CloudQuery configuration files for AWS data extraction
pei "cloudquery init --source=aws --destination=postgresql"
wait

clear

p "Step 4: Examine the generated CloudQuery configuration"
wait

# 📋 This shows the auto-generated configuration that CloudQuery created
pei "cat aws_to_postgresql.yaml"
wait

p "Step 5: Customize the configuration for our specific needs"
wait

# ⚙️ This modifies the config to focus on specific AWS resources we want to analyze
pei "sed -i '' 's/tables: \[\"aws_ec2_instances\"\]/tables: [\"aws_ec2_instances\", \"aws_s3_buckets\", \"aws_ec2_security_groups\"]/' aws_to_postgresql.yaml"
wait

pei "cat aws_to_postgresql.yaml"
wait

clear

p "Phase 2: Database Setup & pgvector Preparation"
wait

p "Step 6: Start PostgreSQL with pgvector extension"
wait

# 🗄️ This starts our PostgreSQL database with pgvector extension ready for AI analysis
pei "docker compose up -d"
wait

p "Step 7: Wait for database to be ready and verify pgvector"
wait

# ⏳ This ensures the database is fully started and pgvector extension is available
pei "sleep 5 && docker exec cloudquery-postgres pg_isready -U postgres"
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';\""
wait

clear

p "Step 8: Create AI-ready tables and functions"
wait

# 🧠 This sets up the database schema for storing AI embeddings and vector analysis
pei "docker exec -i cloudquery-postgres psql -U postgres -d asset_inventory < init.sql"
wait

p "Step 9: Verify our AI-ready database structure"
wait

# 🔍 This shows what tables we have available for AI analysis
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"\\dt\""
wait

clear

p "Phase 3: CloudQuery Data Sync to PostgreSQL"
wait

p "Step 10: Attempt CloudQuery sync (will show auth requirements)"
wait

# 🔐 This demonstrates the CloudQuery sync process - in production you'd have AWS credentials configured
pei "cloudquery sync aws_to_postgresql.yaml"
wait

p "Step 11: Check what data was synced (likely empty without AWS creds)"
wait

# 📊 This shows the current state of our synced data
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT COUNT(*) as instances FROM aws_ec2_instances;\""
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT COUNT(*) as buckets FROM aws_s3_buckets;\""
wait

clear

p "Step 12: Load sample data to demonstrate the full pipeline"
wait

# 🎯 This loads realistic sample data so we can demonstrate the complete AI analysis pipeline
pei "docker exec -i cloudquery-postgres psql -U postgres -d asset_inventory < sample_data.sql"
wait

p "Step 13: Verify sample data is loaded"
wait

# ✅ This confirms our sample data is ready for AI analysis
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT COUNT(*) as instances FROM aws_ec2_instances;\""
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT COUNT(*) as buckets FROM aws_s3_buckets;\""
wait

clear

p "Phase 4: AI Analysis with pgvector on Synced Data"
wait

p "Step 14: Generate AI embeddings from our CloudQuery data"
wait

# 🧠 This converts our infrastructure data into AI-ready vector embeddings for similarity analysis
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
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
ON CONFLICT (resource_type, resource_id) DO NOTHING;\""
wait

p "Step 15: Verify AI embeddings are ready"
wait

# 🔍 This confirms our vector embeddings are created and ready for AI analysis
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT COUNT(*) as total_embeddings, resource_type FROM resource_embeddings GROUP BY resource_type;\""
wait

clear

p "Step 16: AI-powered resource similarity analysis"
wait

# 🚀 This demonstrates the core AI capability - finding similar infrastructure configurations using vector similarity
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
WITH target_resource AS (
    SELECT embedding, resource_data 
    FROM resource_embeddings 
    WHERE resource_data->>'team' = 'backend'
    LIMIT 1
)
SELECT 
    'Similar to backend team config:' as analysis,
    r.resource_data->>'instance_type' as instance_type,
    r.resource_data->>'team' as team,
    r.resource_data->>'environment' as environment,
    r.embedding <-> t.embedding as similarity_distance
FROM resource_embeddings r, target_resource t
WHERE r.resource_type = 'ec2_instance'
ORDER BY r.embedding <-> t.embedding
LIMIT 3;\""
wait

p "Step 17: Vector-based infrastructure clustering"
wait

# 🔗 This shows how AI can group similar resources together for pattern recognition
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
SELECT 
    'Vector Clustering Analysis' as analysis_type,
    resource_data->>'team' as team,
    resource_data->>'environment' as environment,
    COUNT(*) as cluster_size,
    AVG(embedding <-> (SELECT embedding FROM resource_embeddings WHERE resource_data->>'team' = 'backend' LIMIT 1)) as avg_similarity_to_backend
FROM resource_embeddings
WHERE resource_type = 'ec2_instance'
GROUP BY resource_data->>'team', resource_data->>'environment'
ORDER BY avg_similarity_to_backend;\""
wait

clear

p "Phase 5: Real-World Infrastructure Intelligence"
wait

p "Step 18: Cross-service analysis using CloudQuery data"
wait

# 🧠 This demonstrates how CloudQuery data enables comprehensive infrastructure insights
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
SELECT 
    'Infrastructure Summary' as report_type,
    (SELECT COUNT(*) FROM aws_ec2_instances) as total_instances,
    (SELECT COUNT(*) FROM aws_s3_buckets) as total_buckets,
    (SELECT COUNT(*) FROM aws_ec2_security_groups) as total_security_groups;\""
wait

p "Step 19: AI-powered configuration recommendations"
wait

# 💡 This shows the most advanced AI analysis - intelligent recommendations based on vector similarity
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
SELECT 
    'AI Configuration Recommendations' as recommendation_type,
    r1.resource_data->>'team' as source_team,
    r1.resource_data->>'environment' as source_env,
    r2.resource_data->>'team' as target_team,
    r2.resource_data->>'environment' as target_env,
    CASE 
        WHEN r1.embedding <-> r2.embedding < 0.1 THEN 'High similarity - consider standardization'
        WHEN r1.embedding <-> r2.embedding < 0.3 THEN 'Moderate similarity - review for consistency'
        ELSE 'Low similarity - different use cases'
    END as ai_insight
FROM resource_embeddings r1
CROSS JOIN resource_embeddings r2
WHERE r1.id < r2.id 
    AND r1.resource_type = 'ec2_instance' 
    AND r2.resource_type = 'ec2_instance'
ORDER BY r1.embedding <-> r2.embedding
LIMIT 5;\""
wait

clear

p "Demo Complete! 🎉"
wait

p "What we've demonstrated:"
wait

p "✅ Complete CloudQuery project setup and configuration"
p "✅ PostgreSQL database initialization with pgvector extension"
p "✅ CloudQuery data sync to PostgreSQL (with sample data)"
p "✅ AI-ready data preparation and vector embedding generation"
p "✅ AI-powered infrastructure similarity analysis"
p "✅ Vector-based clustering and pattern recognition"
p "✅ Intelligent configuration recommendations"
wait

p "This is the complete real-world workflow for setting up CloudQuery + pgvector AI analysis!"
wait

p "Next steps in production:"
wait

p "1. Configure AWS credentials for real data sync"
p "2. Set up scheduled CloudQuery syncs"
p "3. Integrate with real AI embedding services"
p "4. Build dashboards on the AI-ready data"
p "5. Set up MCP server for AI-powered queries"
wait

