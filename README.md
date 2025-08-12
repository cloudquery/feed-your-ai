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
3. **Generates vector embeddings** from infrastructure configurations
4. **Performs AI-powered analysis** including similarity search and clustering
5. **Provides actionable insights** for cost optimization and standardization

## 🛠️ Utility Scripts

- **`setup.sh`** - Full automated setup (start here!)
- **`quickstart.sh`** - Quick infrastructure start for existing installations
- **`cleanup.sh`** - Reset environment for fresh start
- **`healthcheck.sh`** - Diagnose any issues
- **`demo.sh`** - Interactive demo with explanations

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
