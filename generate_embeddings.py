#!/usr/bin/env python3
"""
Local Embedding Generator for CloudQuery AI Pipeline Demo
Uses sentence-transformers to generate embeddings locally without external API calls
"""

import psycopg2
import json
import sys
import os
from sentence_transformers import SentenceTransformer
from typing import List, Dict, Any
import logging

# Configure logging
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class LocalEmbeddingGenerator:
    def __init__(self, db_config: Dict[str, str]):
        """Initialize the embedding generator with database connection details"""
        self.db_config = db_config
        self.model = None

    def load_model(self):
        """Load the sentence transformer model (downloads once, then runs locally)"""
        try:
            logger.info("Loading sentence transformer model...")
            # Use all-MiniLM-L6-v2: 384 dimensions, fast and good quality
            self.model = SentenceTransformer('all-MiniLM-L6-v2')
            logger.info("Model loaded successfully!")
        except Exception as e:
            logger.error(f"Failed to load model: {e}")
            raise

    def get_embedding(self, text: str) -> List[float]:
        """Generate embedding locally using sentence-transformers"""
        if not self.model:
            raise RuntimeError("Model not loaded. Call load_model() first.")

        try:
            embedding = self.model.encode(text)
            return embedding.tolist()
        except Exception as e:
            logger.error(f"Failed to generate embedding: {e}")
            raise

    def format_resource_text(self, resource_data: Dict[str, Any]) -> str:
        """Format resource data as descriptive text for better embeddings"""
        try:
            return f"""EC2 Instance Configuration:
Instance Type: {resource_data.get('instance_type', 'Unknown')}
State: {resource_data.get('state', 'Unknown')}
Environment: {resource_data.get('environment', 'Unknown')}
Team: {resource_data.get('team', 'Unknown')}
Region: {resource_data.get('region', 'Unknown')}
Public IP: {'Yes' if resource_data.get('has_public_ip') else 'No'}""".strip()
        except Exception as e:
            logger.error(f"Failed to format resource text: {e}")
            return str(resource_data)

    def update_embeddings(self):
        """Update all resource embeddings with local vectors"""
        conn = None
        try:
            # Connect to database
            logger.info("Connecting to database...")
            conn = psycopg2.connect(**self.db_config)
            cursor = conn.cursor()

            # Get all resources that need embeddings
            logger.info("Fetching resources from database...")
            cursor.execute("""
                SELECT id, resource_type, resource_id, resource_data 
                FROM resource_embeddings
                ORDER BY id
            """)

            resources = cursor.fetchall()
            logger.info(f"Found {len(resources)} resources to process")

            if not resources:
                logger.info(
                    "No resources found. Creating sample embeddings...")
                self.create_sample_embeddings(cursor)
                resources = cursor.fetchall()

            # Process each resource
            for i, (resource_id, resource_type, resource_id_str, resource_data) in enumerate(resources):
                logger.info(
                    f"Processing resource {i+1}/{len(resources)}: {resource_type} - {resource_id_str}")

                # Convert resource data to descriptive text
                text_content = self.format_resource_text(resource_data)

                # Generate local embedding
                embedding_vector = self.get_embedding(text_content)

                # Update database
                cursor.execute("""
                    UPDATE resource_embeddings 
                    SET embedding = %s::vector 
                    WHERE id = %s
                """, (embedding_vector, resource_id))

                logger.info(f"Updated embedding for resource {resource_id}")

            # Commit changes
            conn.commit()
            logger.info("All embeddings updated successfully!")

            # Verify the embeddings
            self.verify_embeddings(cursor)

        except Exception as e:
            logger.error(f"Failed to update embeddings: {e}")
            if conn:
                conn.rollback()
            raise
        finally:
            if conn:
                conn.close()

    def create_sample_embeddings(self, cursor):
        """Create sample resource embeddings if none exist"""
        logger.info("Creating sample resource embeddings...")

        sample_resources = [
            ('ec2_instance', 'i-sample-1', {
                'instance_type': 't3.micro',
                'state': 'running',
                'environment': 'production',
                'team': 'backend',
                'region': 'us-east-1',
                'has_public_ip': True
            }),
            ('ec2_instance', 'i-sample-2', {
                'instance_type': 't3.small',
                'state': 'running',
                'environment': 'production',
                'team': 'data',
                'region': 'us-east-1',
                'has_public_ip': False
            }),
            ('ec2_instance', 'i-sample-3', {
                'instance_type': 't3.medium',
                'state': 'stopped',
                'environment': 'development',
                'team': 'frontend',
                'region': 'us-west-2',
                'has_public_ip': True
            })
        ]

        for resource_type, resource_id, resource_data in sample_resources:
            cursor.execute("""
                INSERT INTO resource_embeddings (resource_type, resource_id, resource_data, embedding)
                VALUES (%s, %s, %s, NULL)
                ON CONFLICT (resource_type, resource_id) DO NOTHING
            """, (resource_type, resource_id, json.dumps(resource_data)))

        conn.commit()
        logger.info("Sample resources created")

    def verify_embeddings(self, cursor):
        """Verify that embeddings were created successfully"""
        logger.info("Verifying embeddings...")

        cursor.execute("""
            SELECT 
                COUNT(*) as total_resources,
                COUNT(embedding) as resources_with_embeddings,
                COUNT(*) FILTER (WHERE embedding IS NOT NULL) as non_null_embeddings
            FROM resource_embeddings
        """)

        result = cursor.fetchone()
        total, with_embeddings, non_null = result

        logger.info(f"Total resources: {total}")
        logger.info(f"Resources with embeddings: {with_embeddings}")
        logger.info(f"Non-null embeddings: {non_null}")

        if total > 0 and with_embeddings == total:
            logger.info("✅ All embeddings verified successfully!")
        else:
            logger.warning("⚠️ Some embeddings may be missing")

        # Show a sample embedding
        cursor.execute("""
            SELECT resource_type, resource_id, 
                   array_to_string(embedding::float4[], ',') as sample_vector
            FROM resource_embeddings 
            WHERE embedding IS NOT NULL 
            LIMIT 1
        """)

        sample = cursor.fetchone()
        if sample:
            logger.info(f"Sample embedding: {sample[0]} - {sample[1]}")
            # Show first few dimensions
            vector_str = sample[2]
            first_few = ','.join(vector_str.split(',')[:5])
            logger.info(f"Vector preview (first 5 dimensions): [{first_few}]")


def main():
    """Main function to run the embedding generation"""
    # Database configuration - use environment variables if available (for Docker)
    db_config = {
        'host': os.environ.get('POSTGRES_HOST', 'localhost'),
        'database': os.environ.get('POSTGRES_DB', 'asset_inventory'),
        'user': os.environ.get('POSTGRES_USER', 'postgres'),
        'password': os.environ.get('POSTGRES_PASSWORD', 'postgres'),
        'port': os.environ.get('POSTGRES_PORT', '5432')
    }

    try:
        # Create generator instance
        generator = LocalEmbeddingGenerator(db_config)

        # Load the model
        generator.load_model()

        # Update embeddings
        generator.update_embeddings()

        logger.info("🎉 Embedding generation completed successfully!")

    except Exception as e:
        logger.error(f"❌ Failed to generate embeddings: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
