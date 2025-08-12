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

# 📊 This query shows us all our EC2 instances with key details like what type they are, their current status, which team owns them, and what environment they're in. This gives us a complete inventory of our compute resources.
# This traditional SQL query doesn't need pgvector - it's basic data retrieval that any database can handle.

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

# 👥 This query groups our resources by team and shows us how many resources each team has, plus how many are currently running. This helps us understand resource allocation and identify teams that might need more or fewer resources.
# This aggregation query doesn't need pgvector - it's standard SQL grouping and counting operations.

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

# 🗄️ This query shows us all our S3 storage buckets with details about their purpose, which team owns them, and what environment they're in. This helps us understand our data storage landscape and identify potential security or cost optimization opportunities.
# This query doesn't need pgvector - it's basic data exploration and filtering that standard PostgreSQL handles well.

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

# 🔒 This query examines our S3 buckets to see which ones might have security risks. It checks if buckets have proper public access blocking configured. Buckets without proper access controls could accidentally expose sensitive data to the internet.
# This security analysis doesn't need pgvector - it's rule-based checking that standard SQL can handle efficiently.

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

# 🧠 This query gives us a high-level summary of our entire infrastructure by counting resources across different services (EC2, S3, Security Groups). This is like getting a bird's-eye view of our cloud footprint.
# This summary query doesn't need pgvector - it's basic counting and subqueries that PostgreSQL handles natively.

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"
SELECT 
    'Infrastructure Summary' as report_type,
    (SELECT COUNT(*) FROM aws_ec2_instances) as total_instances,
    (SELECT COUNT(*) FROM aws_s3_buckets) as total_buckets,
    (SELECT COUNT(*) FROM aws_ec2_security_groups) as total_security_groups;\""
wait

p "Step 6: Cost optimization insights"
wait

# 💰 This query identifies potential cost savings by finding teams that have stopped (but not terminated) EC2 instances. These instances are still costing money but not providing any value - perfect candidates for cleanup to reduce costs.
# This cost analysis doesn't need pgvector - it's conditional logic and aggregation that standard SQL excels at.

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

# 🌍 This query analyzes our resources by environment (production vs development) and identifies which environments have resources exposed to the internet. Production environments with exposed resources might need security reviews.
# This environment analysis doesn't need pgvector - it's standard grouping and conditional counting that PostgreSQL handles efficiently.

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

# 📈 This query creates a materialized view that pre-calculates common metrics we need for dashboards and reports. Instead of running complex queries every time, we can just query this view for fast results. This is like creating a summary table that updates automatically.
# This view creation doesn't need pgvector - it's standard PostgreSQL materialized view functionality for performance optimization.

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

# 📊 Now we can query our pre-built summary view to get instant infrastructure metrics. This is much faster than running the complex queries from scratch and gives us real-time insights into our infrastructure health.
# This view query doesn't need pgvector - it's simple SELECT from a materialized view for fast data retrieval.

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT * FROM infrastructure_summary;\""
wait

p "Step 10: Complex business intelligence query"
wait

# 🎯 This advanced query combines multiple pieces of information to give us actionable business insights. It looks at each team's resource usage, identifies security risks, and provides specific recommendations like 'Security Review Needed' or 'Cost Optimization Opportunity'. This is the kind of intelligence that helps managers make informed decisions.
# This business intelligence query doesn't need pgvector - it's complex SQL with CTEs, CASE statements, and business logic that PostgreSQL handles well.

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

# 🔍 First, let's confirm that pgvector (our AI extension) is working and see how many AI embeddings we have. Think of embeddings as 'fingerprints' for our infrastructure - each resource gets converted into a mathematical representation that AI can understand and compare.
# This verification doesn't need pgvector - it's just checking if the extension is installed and counting records.

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';\""
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT COUNT(*) as total_embeddings, resource_type FROM resource_embeddings GROUP BY resource_type;\""
wait

p "Step 12: AI-powered resource similarity analysis"
wait

# 🧠 This is where the AI magic happens! We're using vector similarity to find resources that are most similar to our backend team's configuration. The AI looks at the 'fingerprint' of each resource and finds ones that are mathematically closest. This helps us identify opportunities for standardization across teams.
# WHY THIS NEEDS PGVECTOR: Standard SQL can't calculate mathematical similarity between 384-dimensional vectors. pgvector provides the <-> operator for vector similarity calculations that enable AI-powered pattern recognition across infrastructure configurations.

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

# 🔗 This query uses AI to group our resources into clusters based on how similar they are. It's like having an AI assistant that looks at all our infrastructure and says 'These resources are similar, they should probably be managed the same way.' This helps us identify patterns and opportunities for automation.
# WHY THIS NEEDS PGVECTOR: Standard SQL can't perform vector-based clustering or calculate average similarity distances. pgvector enables mathematical operations on high-dimensional vectors that reveal hidden patterns in infrastructure configurations that human analysts might miss.

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

# 💡 This is the most advanced AI analysis! We're comparing every resource configuration against every other one to find patterns. The AI can spot when two teams are doing similar things but in different ways, and suggest where we could standardize. This is like having a senior architect who's seen thousands of configurations and can spot optimization opportunities.
# WHY THIS NEEDS PGVECTOR: This query performs cross-comparison of all resource configurations using vector similarity. Standard SQL can't efficiently compare 384-dimensional vectors or provide intelligent similarity-based recommendations. pgvector enables AI-powered insights that would require machine learning models in traditional databases.

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


