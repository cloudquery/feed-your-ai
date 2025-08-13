# CloudQuery AI Pipeline Demo

Transform your AWS infrastructure into AI-ready insights with CloudQuery, PostgreSQL, and pgvector. This demo showcases how to build AI/ML pipelines on clean cloud infrastructure data.

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- AWS CLI configured (optional - demo works with sample data)

### Get Running in 2 Steps

```bash
# 1. Make scripts executable and run setup
chmod +x *.sh
./setup.sh

# 2. Run the interactive demo
./demo.sh
```

That's it! The setup script will automatically:

- Install CloudQuery CLI
- Start PostgreSQL with pgvector extension
- Load sample AWS infrastructure data
- Verify everything is working

## 🎯 What This Demo Shows

This demo creates a complete AI pipeline that:

1. **Extracts AWS infrastructure data** using CloudQuery
2. **Stores data in PostgreSQL** with pgvector for AI capabilities
3. **Generates real vector embeddings** using local AI models (sentence-transformers)
4. **Performs AI-powered analysis** including similarity search and clustering
5. **Provides actionable insights** for cost optimization and standardization

## 🤖 AI Embedding Generation

This demo uses **local AI models** to generate meaningful vector embeddings from your infrastructure configurations:

- **Model**: `all-MiniLM-L6-v2` (384 dimensions, production-ready)
- **Processing**: Converts resource metadata to descriptive text
- **Generation**: Creates semantic embeddings locally without external APIs
- **Storage**: pgvector-optimized vectors for fast similarity search
- **Benefits**: No API costs, works offline, genuine semantic understanding

The embeddings capture the semantic meaning of your infrastructure, enabling intelligent similarity analysis between resources, teams, and environments.

## 🛠️ Utility Scripts

- **`setup.sh`** - Full automated setup (start here!)
- **`quickstart.sh`** - Quick infrastructure start for existing installations
- **`cleanup.sh`** - Reset environment for fresh start
- **`healthcheck.sh`** - Diagnose any issues
- **`demo.sh`** - Interactive demo with explanations

## 🔧 AI Pipeline Components

- **`generate_embeddings.py`** - Local AI embedding generation using sentence-transformers
- **`run_embeddings.sh`** - Automated embedding generation script
- **`Dockerfile.embeddings`** - Containerized embedding service
- **`requirements.txt`** - Python dependencies for AI models

## 🔗 Learn More

- **[CloudQuery Hub](https://hub.cloudquery.io/)** - Explore 100+ data source plugins
- **[CloudQuery Documentation](https://docs.cloudquery.io/)** - Complete setup and usage guides
- **[pgvector Documentation](https://github.com/pgvector/pgvector)** - Vector similarity search
- **[PostgreSQL Documentation](https://www.postgresql.org/docs/)** - Database reference

## 💡 This is Just One Example

This demo shows **one way** to use CloudQuery with AI pipelines. CloudQuery connects to [100+ data sources](https://hub.cloudquery.io/) including:

- **Cloud Providers**: AWS, GCP, Azure, DigitalOcean
- **SaaS Platforms**: GitHub, GitLab, Slack, Jira
- **Infrastructure**: Kubernetes, Terraform, Docker
- **Security**: CrowdStrike, Okta, Auth0
- **And many more...**

Each plugin provides normalized, SQL-ready data that you can integrate with any AI/ML workflow, vector database, or analytics platform.

---

**CloudQuery**: The data foundation for infrastructure AI/ML pipelines
