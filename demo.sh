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

p "CloudQuery AI Pipeline Demo - pgvector AI Analysis"
wait

p "This demo showcases the AI-powered analysis capabilities using pgvector on CloudQuery infrastructure data"
wait

clear

p "Let's check if we have AWS credentials for real data sync"
wait

# Check AWS credentials and show appropriate message
if check_aws_credentials; then
    p "Great! We have AWS credentials. Let's try to sync real data from your AWS account."
else
    p "No AWS credentials found. We'll use sample data to demonstrate the AI analysis capabilities."
fi

wait

p "First, let's ensure our database is ready with pgvector and sample data"
wait

# Start database and load sample data
pei "docker compose up -d"
wait

pei "sleep 5 && docker exec cloudquery-postgres pg_isready -U postgres"
wait

pei "docker exec -i cloudquery-postgres psql -U postgres -d asset_inventory < sample_data.sql"
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

clear

p "AI Analysis Example 1: Infrastructure Similarity Discovery"
wait

p "This query uses vector similarity to find resources with similar configurations, enabling standardization opportunities across teams"
wait

# AI similarity analysis with proper formatting
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
WITH target_resource AS (
    SELECT 
        embedding, 
        resource_data 
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

clear

p "AI Analysis Example 2: Intelligent Configuration Clustering"
wait

p "This query groups resources by similarity patterns, revealing hidden infrastructure clusters that could benefit from unified management"
wait

# AI clustering analysis with proper formatting
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
SELECT 
    'Vector Clustering Analysis' as analysis_type,
    resource_data->>'team' as team,
    resource_data->>'environment' as environment,
    COUNT(*) as cluster_size,
    AVG(
        embedding <-> (
            SELECT embedding 
            FROM resource_embeddings 
            WHERE resource_data->>'team' = 'backend' 
            LIMIT 1
        )
    ) as avg_similarity_to_backend
FROM resource_embeddings
WHERE resource_type = 'ec2_instance'
GROUP BY resource_data->>'team', resource_data->>'environment'
ORDER BY avg_similarity_to_backend;\""
wait

clear

p "AI Analysis Example 3: Cross-Team Standardization Recommendations"
wait

p "This advanced query compares every resource configuration against every other one, providing intelligent recommendations for infrastructure standardization"
wait

# AI configuration recommendations with proper formatting
pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
SELECT 
    'AI Configuration Recommendations' as recommendation_type,
    r1.resource_data->>'team' as source_team,
    r2.resource_data->>'team' as target_team,
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

p "AI Pipeline Complete! 🚀"
wait

p "We've demonstrated three key AI capabilities:"
wait

p "• Infrastructure similarity discovery using vector embeddings"
p "• Intelligent clustering for pattern recognition"
p "• Cross-team standardization recommendations"
wait

p "This is the power of CloudQuery + pgvector: transforming infrastructure data into AI-ready insights that drive better decision-making."
wait

