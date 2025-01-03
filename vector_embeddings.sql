-- Drop the match_documents function if it exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'match_documents') THEN
    DROP FUNCTION match_documents(vector, int, jsonb);
  END IF;
END $$;

-- Drop the documents table if it exists
DROP TABLE IF EXISTS documents;

-- Drop the vector extension if it exists
DROP EXTENSION IF EXISTS vector;

-- Enable the pgvector extension to work with embedding vectors
CREATE EXTENSION vector;

-- Create a table to store your documents
CREATE TABLE documents (
  id bigserial PRIMARY KEY,
  content text, -- corresponds to Document.pageContent
  metadata jsonb, -- corresponds to Document.metadata
  embedding vector(4096) -- 4096 works for Cohere embeddings
);

-- Create a function to search for documents
CREATE FUNCTION match_documents (
  query_embedding vector(4096),
  match_count int DEFAULT NULL,
  filter jsonb DEFAULT '{}'
) RETURNS TABLE (
  id bigint,
  content text,
  metadata jsonb,
  similarity float
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
BEGIN
  RETURN QUERY
  SELECT
    id,
    content,
    metadata,
    1 - (documents.embedding <=> query_embedding) AS similarity
  FROM documents
  WHERE metadata @> filter
  ORDER BY documents.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;
