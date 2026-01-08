-- =============================================================================
-- Initialize PGVector Extension and Schemas
-- =============================================================================

-- Enable vector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create schemas for different services
CREATE SCHEMA IF NOT EXISTS plans_vectors;
CREATE SCHEMA IF NOT EXISTS customer_vectors;
CREATE SCHEMA IF NOT EXISTS ai_gateway_vectors;

-- Sample table structure for embeddings
CREATE TABLE IF NOT EXISTS ai_gateway_vectors.document_embeddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id VARCHAR(255) NOT NULL,
    chunk_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    embedding vector(1536),  -- OpenAI ada-002 dimension
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(document_id, chunk_id)
);

-- Create index for similarity search
CREATE INDEX IF NOT EXISTS idx_document_embeddings_vector 
ON ai_gateway_vectors.document_embeddings 
USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Plans embeddings table
CREATE TABLE IF NOT EXISTS plans_vectors.plan_embeddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id UUID NOT NULL,
    content TEXT NOT NULL,
    embedding vector(1536),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_plan_embeddings_vector 
ON plans_vectors.plan_embeddings 
USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);