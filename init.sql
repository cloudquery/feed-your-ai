-- Initialize database with pgvector extension for AI/ML workflows
CREATE EXTENSION IF NOT EXISTS vector;

-- Table for storing resource embeddings for AI analysis
CREATE TABLE IF NOT EXISTS resource_embeddings (
    id SERIAL PRIMARY KEY,
    resource_type VARCHAR(100) NOT NULL,
    resource_id VARCHAR(255) NOT NULL,
    resource_data JSONB,
    embedding vector(384), -- OpenAI text-embedding-3-small dimension
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(resource_type, resource_id)
);

CREATE INDEX ON resource_embeddings USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);