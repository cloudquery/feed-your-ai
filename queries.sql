-- CloudQuery AI Pipeline Demo Queries
-- Demonstrates clean, privacy-focused data queries for AI insights

-- ======================
-- Basic Asset Inventory
-- ======================

-- Total resource count by type and environment
SELECT 
    'EC2 Instances' as resource_type,
    tags->>'Environment' as environment,
    COUNT(*) as count
FROM aws_ec2_instances 
WHERE tags->>'Environment' IS NOT NULL
GROUP BY tags->>'Environment'
UNION ALL
SELECT 
    'S3 Buckets' as resource_type,
    tags->>'Environment' as environment,
    COUNT(*) as count
FROM aws_s3_buckets
WHERE tags->>'Environment' IS NOT NULL
GROUP BY tags->>'Environment'
ORDER BY resource_type, environment;

-- ======================
-- Security Insights
-- ======================

-- Find instances with public IPs (potential security risk)
SELECT 
    instance_id,
    tags->>'Name' as instance_name,
    tags->>'Environment' as environment,
    instance_type,
    state,
    public_ip_address,
    region
FROM aws_ec2_instances 
WHERE public_ip_address IS NOT NULL
ORDER BY tags->>'Environment', region;

-- Security groups allowing broad access
SELECT 
    sg.group_name,
    sg.description,
    sg.vpc_id,
    sg.region,
    sg.tags->>'Environment' as environment,
    jsonb_array_length(sg.ip_permissions) as rule_count
FROM aws_ec2_security_groups sg
WHERE sg.ip_permissions @> '[{"IpRanges": [{"CidrIp": "0.0.0.0/0"}]}]'
ORDER BY environment, region;

-- ======================
-- Cost Optimization Insights
-- ======================

-- Stopped instances (potential cost savings)
SELECT 
    region,
    instance_type,
    COUNT(*) as stopped_count,
    tags->>'Environment' as environment,
    tags->>'Team' as team
FROM aws_ec2_instances 
WHERE state = 'stopped'
GROUP BY region, instance_type, tags->>'Environment', tags->>'Team'
ORDER BY stopped_count DESC;

-- ======================
-- AI/Vector Embedding Queries
-- ======================

-- Sample function to create resource embeddings (would use actual embedding API)
CREATE OR REPLACE FUNCTION create_resource_embedding(resource_data JSONB)
RETURNS vector AS $$
BEGIN
    -- In reality, this would call OpenAI API or similar
    -- For demo, return random vector of appropriate dimension
    RETURN (
        SELECT ARRAY(
            SELECT random()::float4 
            FROM generate_series(1, 384)
        )::vector
    );
END;
$$ LANGUAGE plpgsql;

-- Insert sample embeddings for similar resource analysis
INSERT INTO resource_embeddings (resource_type, resource_id, resource_data, embedding)
SELECT 
    'ec2_instance',
    instance_id,
    jsonb_build_object(
        'instance_type', instance_type,
        'state', state,
        'environment', tags->>'Environment',
        'team', tags->>'Team',
        'has_public_ip', (public_ip_address IS NOT NULL)
    ),
    create_resource_embedding(
        jsonb_build_object(
            'instance_type', instance_type,
            'state', state,
            'environment', tags->>'Environment',
            'team', tags->>'Team'
        )
    )
FROM aws_ec2_instances
ON CONFLICT (resource_type, resource_id) DO NOTHING;

-- Find similar resources using vector similarity
-- (This would find resources with similar configurations)
WITH target_resource AS (
    SELECT embedding 
    FROM resource_embeddings 
    WHERE resource_id = 'i-0abcd1234efgh5678'
    LIMIT 1
)
SELECT 
    r.resource_id,
    r.resource_data->>'instance_type' as instance_type,
    r.resource_data->>'environment' as environment,
    r.resource_data->>'team' as team,
    r.embedding <-> t.embedding as similarity_distance
FROM resource_embeddings r, target_resource t
WHERE r.resource_type = 'ec2_instance'
    AND r.resource_id != 'i-0abcd1234efgh5678'
ORDER BY r.embedding <-> t.embedding
LIMIT 5;

-- ======================
-- Privacy-Focused Analytics
-- ======================

-- Aggregate insights without exposing sensitive data
SELECT 
    region,
    tags->>'Environment' as environment,
    COUNT(DISTINCT vpc_id) as unique_vpcs,
    COUNT(*) as instance_count,
    COUNT(CASE WHEN public_ip_address IS NOT NULL THEN 1 END) as public_instances,
    ROUND(
        AVG(CASE 
            WHEN instance_type LIKE 't%.micro' THEN 1
            WHEN instance_type LIKE 't%.small' THEN 2  
            WHEN instance_type LIKE 't%.medium' THEN 4
            ELSE 8 
        END), 2
    ) as avg_instance_size_factor
FROM aws_ec2_instances
GROUP BY region, tags->>'Environment'
ORDER BY region, environment;

-- Team resource distribution (privacy-safe aggregation)
SELECT 
    tags->>'Team' as team,
    COUNT(*) as total_resources,
    COUNT(CASE WHEN state = 'running' THEN 1 END) as running_instances,
    COUNT(CASE WHEN public_ip_address IS NOT NULL THEN 1 END) as exposed_instances,
    ROUND(
        100.0 * COUNT(CASE WHEN state = 'running' THEN 1 END) / COUNT(*),
        1
    ) as utilization_percent
FROM aws_ec2_instances
WHERE tags->>'Team' IS NOT NULL
GROUP BY tags->>'Team'
ORDER BY total_resources DESC;

-- ======================
-- Real-time Analysis View
-- ======================

-- Create materialized view for fast dashboard queries
CREATE MATERIALIZED VIEW IF NOT EXISTS aws_infrastructure_summary AS
SELECT 
    CURRENT_TIMESTAMP as last_updated,
    (SELECT COUNT(*) FROM aws_ec2_instances WHERE state = 'running') as running_instances,
    (SELECT COUNT(*) FROM aws_ec2_instances WHERE state = 'stopped') as stopped_instances,
    (SELECT COUNT(*) FROM aws_s3_buckets) as total_buckets,
    (SELECT COUNT(*) FROM aws_ec2_security_groups) as security_groups,
    (SELECT COUNT(DISTINCT region) FROM aws_ec2_instances) as active_regions,
    (SELECT COUNT(*) FROM aws_ec2_instances WHERE public_ip_address IS NOT NULL) as public_instances;

-- Refresh the materialized view
REFRESH MATERIALIZED VIEW aws_infrastructure_summary;

-- Query the summary
SELECT * FROM aws_infrastructure_summary;