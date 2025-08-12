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

p "Verify pgvector extension and embeddings"
wait

# 🔍 First, let's confirm that pgvector (our AI extension) is working and see how many AI embeddings we have. Think of embeddings as 'fingerprints' for our infrastructure - each resource gets converted into a mathematical representation that AI can understand and compare.

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';\""
wait

pei "docker exec cloudquery-postgres psql -U postgres -d asset_inventory -c \"SELECT COUNT(*) as total_embeddings, resource_type FROM resource_embeddings GROUP BY resource_type;\""
wait

p "AI-powered resource similarity analysis"
wait

# 🧠 This is where the AI magic happens! We're using vector similarity to find resources that are most similar to our backend team's configuration. The AI looks at the 'fingerprint' of each resource and finds ones that are mathematically closest. This helps us identify opportunities for standardization across teams.

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

p "Vector-based infrastructure clustering"
wait

# 🔗 This query uses AI to group our resources into clusters based on how similar they are. It's like having an AI assistant that looks at all our infrastructure and says 'These resources are similar, they should probably be managed the same way.' This helps us identify patterns and opportunities for automation.

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

p "AI-powered configuration recommendations"
wait

# 💡 This is the most advanced AI analysis! We're comparing every resource configuration against every other one to find patterns. The AI can spot when two teams are doing similar things but in different ways, and suggest where we could standardize. This is like having a senior architect who's seen thousands of configurations and can spot optimization opportunities.

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

