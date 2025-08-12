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

# Check if AWS credentials are available
check_aws_credentials() {
    if [[ -z "$AWS_ACCESS_KEY_ID" ]] || [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
        echo -e "\n${RED}❌ AWS credentials not found!${NC}"
        echo -e "${YELLOW}Please set the following environment variables:${NC}"
        echo -e "  export AWS_ACCESS_KEY_ID=your_access_key"
        echo -e "  export AWS_SECRET_ACCESS_KEY=your_secret_key"
        echo -e "  export AWS_DEFAULT_REGION=your_region"
        echo -e "\n${CYAN}Continuing with sample data for demonstration...${NC}\n"
        return 1
    else
        echo -e "\n${GREEN}✅ AWS credentials found!${NC}"
        echo -e "${CYAN}Ready to sync real AWS data...${NC}\n"
        return 0
    fi
}

clear

p "CloudQuery AI Pipeline Demo - Data Sync & Analysis Experience"
wait

p "This demo shows what it's like to use CloudQuery: syncing infrastructure data and then analyzing it with AI-powered insights"
wait

clear

p "Let's check if we have AWS credentials for real data sync"
wait

# Check AWS credentials and show appropriate message
if check_aws_credentials; then
    p "Great! We have AWS credentials. Let's try to sync real data from your AWS account."
else
    p "No AWS credentials found. We'll use sample data to demonstrate the analysis capabilities."
fi

wait

p "First, let's see what infrastructure data we currently have"
wait

# Show current data state
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT 'Current Data State' as status, (SELECT COUNT(*) FROM aws_ec2_instances) as ec2_count, (SELECT COUNT(*) FROM aws_s3_buckets) as s3_count, (SELECT COUNT(*) FROM aws_ec2_security_groups) as sg_count;\""
wait

clear

p "Now let's attempt to sync fresh data from AWS using CloudQuery"
wait

# Attempt CloudQuery sync - this will either work with real credentials or show auth error
pei "cloudquery sync aws_to_postgresql.yaml"
wait

p "Let's check what data we got from the sync"
wait

# Check what data was actually synced
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT 'Post-Sync Data State' as status, (SELECT COUNT(*) FROM aws_ec2_instances) as ec2_count, (SELECT COUNT(*) FROM aws_s3_buckets) as s3_count, (SELECT COUNT(*) FROM aws_ec2_security_groups) as sg_count;\""
wait

clear

p "If we don't have real data, let's load some sample data to demonstrate the analysis capabilities"
wait

# Load sample data if needed
pei "docker exec -i cloudquery-postgres psql -U postgres -d asset_inventory < sample_data.sql"
wait

p "Now let's explore our infrastructure data"
wait

# Show sample data
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT instance_id, instance_type, state->>'Name' as status, tags->>'Team' as team, tags->>'Environment' as environment FROM aws_ec2_instances;\""
wait

p "Let's look at our S3 storage landscape"
wait

# Show S3 data
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT name, region, tags->>'Environment' as environment, tags->>'Team' as team, tags->>'Purpose' as purpose FROM aws_s3_buckets;\""
wait

clear

p "Now let's do some business intelligence analysis on our infrastructure"
wait

# Team resource distribution analysis
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT tags->>'Team' as team, COUNT(*) as total_resources, COUNT(CASE WHEN state->>'Name' = 'running' THEN 1 END) as running_count, COUNT(CASE WHEN state->>'Name' = 'stopped' THEN 1 END) as stopped_count FROM aws_ec2_instances GROUP BY tags->>'Team' ORDER BY total_resources DESC;\""
wait

p "Let's identify potential cost optimization opportunities"
wait

# Cost optimization analysis
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT tags->>'Team' as team, tags->>'Environment' as environment, COUNT(CASE WHEN state->>'Name' = 'stopped' THEN 1 END) as stopped_instances, CASE WHEN COUNT(CASE WHEN state->>'Name' = 'stopped' THEN 1 END) > 0 THEN 'Cost savings opportunity' ELSE 'No stopped instances' END as recommendation FROM aws_ec2_instances GROUP BY tags->>'Team', tags->>'Environment' HAVING COUNT(CASE WHEN state->>'Name' = 'stopped' THEN 1 END) > 0;\""
wait

clear

p "Let's check for security considerations"
wait

# Security analysis
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT tags->>'Environment' as environment, COUNT(*) as total_resources, COUNT(CASE WHEN public_ip_address IS NOT NULL THEN 1 END) as exposed_resources, CASE WHEN COUNT(CASE WHEN public_ip_address IS NOT NULL THEN 1 END) > 0 THEN 'Security review recommended' ELSE 'No exposed resources' END as security_status FROM aws_ec2_instances GROUP BY tags->>'Environment' ORDER BY exposed_resources DESC;\""
wait

p "Now let's examine our S3 security posture"
wait

# S3 security analysis
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT name, tags->>'Environment' as environment, tags->>'Team' as team, CASE WHEN public_access_block_configuration IS NULL THEN 'No public access block' ELSE 'Public access blocked' END as access_status FROM aws_s3_buckets;\""
wait

clear

p "Now let's enable AI-powered analysis with pgvector"
wait

# Check if pgvector is ready
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';\""
wait

p "Let's create AI embeddings from our infrastructure data"
wait

# Generate embeddings for AI analysis
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"INSERT INTO resource_embeddings (resource_type, resource_id, resource_data, embedding) SELECT 'ec2_instance', instance_id, jsonb_build_object('instance_type', instance_type, 'state', state, 'environment', tags->>'Environment', 'team', tags->>'Team', 'region', region, 'has_public_ip', (public_ip_address IS NOT NULL)), generate_mock_embedding(tags) FROM aws_ec2_instances ON CONFLICT (resource_type, resource_id) DO NOTHING;\""
wait

p "Now let's do AI-powered similarity analysis"
wait

# AI similarity analysis
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"WITH target_resource AS (SELECT embedding, resource_data FROM resource_embeddings WHERE resource_data->>'team' = 'backend' LIMIT 1) SELECT 'Similar to backend config:' as analysis, r.resource_data->>'instance_type' as instance_type, r.resource_data->>'team' as team, r.resource_data->>'environment' as environment, r.embedding <-> t.embedding as similarity_distance FROM resource_embeddings r, target_resource t WHERE r.resource_type = 'ec2_instance' ORDER BY r.embedding <-> t.embedding LIMIT 3;\""
wait

clear

p "Let's get AI-powered configuration recommendations"
wait

# AI configuration recommendations
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT 'AI Configuration Recommendations' as recommendation_type, r1.resource_data->>'team' as source_team, r2.resource_data->>'team' as target_team, CASE WHEN r1.embedding <-> r2.embedding < 0.1 THEN 'High similarity - consider standardization' WHEN r1.embedding <-> r2.embedding < 0.3 THEN 'Moderate similarity - review for consistency' ELSE 'Low similarity - different use cases' END as ai_insight FROM resource_embeddings r1 CROSS JOIN resource_embeddings r2 WHERE r1.id < r2.id AND r1.resource_type = 'ec2_instance' AND r2.resource_type = 'ec2_instance' ORDER BY r1.embedding <-> r2.embedding LIMIT 5;\""
wait

p "Finally, let's create a summary dashboard view"
wait

# Create summary view
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"CREATE MATERIALIZED VIEW IF NOT EXISTS infrastructure_summary AS SELECT CURRENT_TIMESTAMP as last_updated, (SELECT COUNT(*) FROM aws_ec2_instances WHERE state->>'Name' = 'running') as running_instances, (SELECT COUNT(*) FROM aws_ec2_instances WHERE state->>'Name' = 'stopped') as stopped_instances, (SELECT COUNT(*) FROM aws_s3_buckets) as total_buckets, (SELECT COUNT(*) FROM aws_ec2_security_groups) as security_groups, (SELECT COUNT(*) FROM resource_embeddings) as ai_embeddings;\""
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT * FROM infrastructure_summary;\""
wait

clear

p "Demo Complete! 🎉"
wait

p "What we've experienced:"
wait

p "✅ CloudQuery data sync process (real or sample data)"
p "✅ Infrastructure data exploration and analysis"
p "✅ Business intelligence insights (cost, security, team allocation)"
p "✅ AI-powered analysis with pgvector"
p "✅ Configuration similarity and standardization recommendations"
p "✅ Dashboard-ready summary views"
wait

p "This is what it's like to use CloudQuery in practice:"
wait

p "1. Sync infrastructure data from AWS"
p "2. Explore and analyze the data with SQL"
p "3. Enable AI analysis with pgvector"
p "4. Get intelligent insights and recommendations"
p "5. Build dashboards and reports"
wait

p "The beauty is that once you have this pipeline set up, you can:"
wait

p "• Schedule regular syncs to keep data fresh"
p "• Build automated alerts and reports"
p "• Use AI to discover patterns and optimization opportunities"
p "• Share insights across your team"
p "• Make data-driven infrastructure decisions"
wait

