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

p "CloudQuery AI Pipeline Demo - AWS Infrastructure Data Analysis"
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

p "Demo Complete! 🎉"
wait


