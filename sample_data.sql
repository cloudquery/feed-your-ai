-- Sample data to demonstrate CloudQuery AWS sync structure
-- This shows the schema CloudQuery creates and sample AI-ready data
-- Insert sample EC2 instances data matching real CloudQuery schema
INSERT INTO aws_ec2_instances (
        _cq_id,
        account_id,
        region,
        instance_id,
        instance_type,
        state,
        vpc_id,
        tags,
        public_ip_address,
        private_ip_address,
        launch_time
    )
VALUES (
        gen_random_uuid(),
        '123456789012',
        'us-east-1',
        'i-0abcd1234efgh5678',
        't3.micro',
        '{"Name": "running"}',
        'vpc-12345678',
        '{"Name": "WebServer-1", "Environment": "production", "Team": "backend"}',
        '54.123.45.67',
        '10.0.1.100',
        '2023-01-15 10:30:00'
    ),
    (
        gen_random_uuid(),
        '123456789012',
        'us-east-1',
        'i-0xyz9876fedcb5432',
        't3.small',
        '{"Name": "running"}',
        'vpc-12345678',
        '{"Name": "Database-1", "Environment": "production", "Team": "data"}',
        NULL,
        '10.0.2.50',
        '2023-01-15 11:00:00'
    ),
    (
        gen_random_uuid(),
        '123456789012',
        'us-west-2',
        'i-0def4567890abc123',
        't3.medium',
        '{"Name": "stopped"}',
        'vpc-87654321',
        '{"Name": "Development-1", "Environment": "development", "Team": "frontend"}',
        '34.56.89.12',
        '10.1.1.75',
        '2023-01-15 12:00:00'
    ),
    (
        gen_random_uuid(),
        '123456789012',
        'us-west-2',
        'i-0ghi7890123def456',
        't2.micro',
        '{"Name": "running"}',
        'vpc-87654321',
        '{"Name": "Monitoring-1", "Environment": "production", "Team": "devops"}',
        '52.234.56.78',
        '10.1.2.25',
        '2023-01-15 13:00:00'
    );
-- Insert sample S3 buckets data (these already exist, so we'll skip duplicates)
-- INSERT INTO aws_s3_buckets (account_id, region, name, creation_date, versioning_status, encryption_configuration, tags) VALUES
-- ('123456789012', 'us-east-1', 'company-data-backup', '2023-01-15 10:30:00', 'Enabled', '{"ServerSideEncryptionConfiguration": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}', '{"Environment": "production", "Purpose": "backup", "Team": "data"}'),
-- ('123456789012', 'us-east-1', 'app-logs-storage', '2023-03-20 14:45:00', 'Suspended', '{"ServerSideEncryptionConfiguration": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "aws:kms"}}]}', '{"Environment": "production", "Purpose": "logs", "Team": "backend"}'),
-- ('123456789012', 'us-west-2', 'dev-artifacts', '2023-06-10 09:15:00', 'Enabled', '{}', '{"Environment": "development", "Purpose": "artifacts", "Team": "frontend"}');
-- Insert sample security groups data (these already exist, so we'll skip duplicates)
-- INSERT INTO aws_ec2_security_groups (account_id, region, group_id, group_name, description, vpc_id, ip_permissions, tags) VALUES
-- ('123456789012', 'us-east-1', 'sg-0123456789abcdef0', 'web-servers-sg', 'Security group for web servers', 'vpc-12345678', '[{"IpProtocol": "tcp", "FromPort": 80, "ToPort": 80, "IpRanges": [{"CidrIp": "0.0.0.0/0"}]}, {"IpProtocol": "tcp", "FromPort": 443, "ToPort": 443, "IpRanges": [{"CidrIp": "0.0.0.0/0"}]}]', '{"Environment": "production", "Team": "backend"}'),
-- ('123456789012', 'us-east-1', 'sg-0fedcba9876543210', 'database-sg', 'Security group for database servers', 'vpc-12345678', '[{"IpProtocol": "tcp", "FromPort": 5432, "ToPort": 5432, "UserIdGroupPairs": [{"GroupId": "pg-0123456789abcdef0"}]}]', '{"Environment": "production", "Team": "data"}');