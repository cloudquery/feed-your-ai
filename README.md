# CloudQuery AI Pipeline Demo

Transform your AWS infrastructure into AI-ready insights with CloudQuery, PostgreSQL, and pgvector. This demo shows data engineers how to build production AI/ML pipelines on clean cloud infrastructure data.

## 🚀 Quick Start

### Run the Interactive Demo

```bash
./demo.sh
```

The demo will:

- Set up PostgreSQL + pgvector automatically
- Show real CloudQuery sync commands
- Demonstrate AI pipeline capabilities
- Guide you through each step with explanations

## 🏗️ What This Demo Shows

### Data Pipeline Steps

1. **CloudQuery Data Extraction** - AWS infrastructure → PostgreSQL
2. **Feature Engineering** - SQL transformations for ML
3. **Cost Optimization Analytics** - Business insights and recommendations
4. **AI Vector Embeddings** - Infrastructure similarity analysis
5. **Multi-Resource Intelligence** - Cross-service analytics (EC2 + S3)

### AI/ML Capabilities

- **Vector Similarity Search** - Find similar infrastructure configurations
- **Anomaly Detection** - Identify unusual resource patterns  
- **Cost Optimization** - AI-driven savings recommendations
- **Security Analysis** - Automated compliance monitoring
- **Resource Standardization** - Cross-team configuration insights

## 🛠️ Production Setup

### 1. Configure AWS Credentials

```bash
aws configure
# or set environment variables:
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key  
export AWS_REGION=us-east-1
```

### 2. Run CloudQuery Sync

```bash
cloudquery sync aws_to_postgresql.yaml
```

### 3. Connect to Your Data

```bash
psql postgresql://postgres:postgres@localhost:5433/asset_inventory
```

## 📊 Key Benefits for Data Engineers

- **No ETL Complexity** - Direct cloud API to normalized PostgreSQL tables
- **Rich Metadata** - Complete infrastructure context for feature engineering
- **AI-Ready** - pgvector integration for embeddings and similarity search
- **SQL-Based** - Use familiar tools for transformations and analysis
- **Production-Ready** - Scales to enterprise environments

## 📁 Project Files

- **`demo.sh`** - Interactive demo (start here!)
- **`aws_to_postgresql.yaml`** - CloudQuery configuration
- **`docker-compose.yml`** - PostgreSQL + pgvector setup
- **`sample_data.sql`** - Representative AWS infrastructure data
- **`queries.sql`** - Additional analysis examples

## 🎯 Production Workflow

1. **Extract** - `cloudquery sync` pulls live AWS data
2. **Transform** - SQL feature engineering for ML models
3. **Embed** - Generate vectors with OpenAI/local models
4. **Train** - Build AI systems on infrastructure data
5. **Deploy** - Production AI insights and recommendations

## 💡 Use Cases

- **Cost Optimization Models** - Predict and prevent cloud waste
- **Security Compliance** - Automated policy violation detection
- **Resource Recommendations** - AI-powered right-sizing and optimization
- **Anomaly Detection** - Identify unusual infrastructure patterns
- **Team Standardization** - Cross-team configuration consistency

---

**CloudQuery**: The data foundation for infrastructure AI/ML pipelines
