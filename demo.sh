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

p "CloudQuery AI Pipeline Demo - AWS Infrastructure Data Analysis with pgvector"
wait

p "This demo shows how CloudQuery transforms AWS infrastructure data into AI-ready insights using vector embeddings"
wait

clear

p "Step 1: Explore our EC2 instances data"
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
SELECT 
    instance_id,
    instance_type,
    state->>'Name' as status,
    tags->>'Team' as team,
    tags->>'Environment' as environment
FROM aws_ec2_instances;\""
wait

p "Step 2: Analyze resource distribution by team"
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
SELECT 
    tags->>'Team' as team,
    COUNT(*) as total_resources,
    COUNT(CASE WHEN state->>'Name' = 'running' THEN 1 END) as running_count
FROM aws_ec2_instances
GROUP BY tags->>'Team'
ORDER BY total_resources DESC;\""
wait

clear

p "Step 3: Examine S3 bucket infrastructure"
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
SELECT 
    name,
    region,
    tags->>'Environment' as environment,
    tags->>'Team' as team,
    tags->>'Purpose' as purpose
FROM aws_s3_buckets
LIMIT 10;\""
wait

p "Step 4: Security analysis - check for potential risks"
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
SELECT 
    name,
    tags->>'Environment' as environment,
    CASE 
        WHEN public_access_block_configuration IS NULL THEN 'No public access block'
        ELSE 'Public access blocked'
    END as access_status
FROM aws_s3_buckets;\""
wait

clear

p "Step 5: Cross-service infrastructure intelligence"
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
SELECT 
    'Infrastructure Summary' as report_type,
    (SELECT COUNT(*) FROM aws_ec2_instances) as total_instances,
    (SELECT COUNT(*) FROM aws_s3_buckets) as total_buckets,
    (SELECT COUNT(*) FROM aws_ec2_security_groups) as total_security_groups;\""
wait

p "Step 6: Cost optimization insights"
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
SELECT 
    tags->>'Team' as team,
    COUNT(CASE WHEN state->>'Name' = 'stopped' THEN 1 END) as stopped_instances,
    COUNT(CASE WHEN state->>'Name' = 'running' THEN 1 END) as running_instances
FROM aws_ec2_instances
GROUP BY tags->>'Team'
HAVING COUNT(CASE WHEN state->>'Name' = 'stopped' THEN 1 END) > 0;\""
wait

clear

p "Step 7: Environment-based resource analysis"
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
SELECT 
    tags->>'Environment' as environment,
    COUNT(*) as resource_count,
    COUNT(CASE WHEN public_ip_address IS NOT NULL THEN 1 END) as exposed_resources
FROM aws_ec2_instances
GROUP BY tags->>'Environment'
ORDER BY resource_count DESC;\""
wait

p "Step 8: AI-ready data preparation - create analysis views"
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
CREATE MATERIALIZED VIEW IF NOT EXISTS infrastructure_summary AS
SELECT 
    CURRENT_TIMESTAMP as last_updated,
    (SELECT COUNT(*) FROM aws_ec2_instances WHERE state->>'Name' = 'running') as running_instances,
    (SELECT COUNT(*) FROM aws_ec2_instances WHERE state->>'Name' = 'stopped') as stopped_instances,
    (SELECT COUNT(*) FROM aws_s3_buckets) as total_buckets,
    (SELECT COUNT(*) FROM aws_ec2_security_groups) as security_groups;\""
wait

clear

p "Step 9: Query our AI-ready summary view"
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT * FROM infrastructure_summary;\""
wait

p "Step 10: Complex business intelligence query"
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
WITH team_resources AS (
    SELECT 
        tags->>'Team' as team,
        tags->>'Environment' as environment,
        COUNT(*) as instance_count,
        COUNT(CASE WHEN state->>'Name' = 'running' THEN 1 END) as running_count,
        COUNT(CASE WHEN public_ip_address IS NOT NULL THEN 1 END) as exposed_count
    FROM aws_ec2_instances
    GROUP BY tags->>'Team', tags->>'Environment'
)
SELECT 
    team,
    environment,
    instance_count,
    running_count,
    exposed_count,
    CASE 
        WHEN exposed_count > 0 THEN 'Security Review Needed'
        WHEN running_count = 0 THEN 'Cost Optimization Opportunity'
        ELSE 'Optimized'
    END as recommendation
FROM team_resources
ORDER BY team, environment;\""
wait

clear

p "🚀 PGVector AI Analysis Section 🚀"
wait

p "Step 11: Verify pgvector extension and embeddings"
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';\""
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT COUNT(*) as total_embeddings, resource_type FROM resource_embeddings GROUP BY resource_type;\""
wait

p "Step 12: AI-powered resource similarity analysis"
wait

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

clear

p "Step 13: Vector-based infrastructure clustering"
wait

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

p "Step 14: AI-powered configuration recommendations"
wait

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

p "✅ Real infrastructure data from CloudQuery"
p "✅ Cross-service analytics (EC2, S3, Security Groups)"
p "✅ Business intelligence insights"
p "✅ Cost optimization analysis"
p "✅ Security risk assessment"
p "✅ AI-ready data preparation"
p "🚀 PGVector AI analysis with vector embeddings"
p "🚀 AI-powered resource similarity and clustering"
p "🚀 Intelligent configuration recommendations"
wait

p "Your CloudQuery MCP server + pgvector is now ready for advanced AI-powered infrastructure insights!"
wait


