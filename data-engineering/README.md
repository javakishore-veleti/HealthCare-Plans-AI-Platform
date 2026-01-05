# Data Engineering

Python-based ETL pipelines for ingesting, transforming, summarizing, and embedding healthcare plan data into vector databases. Implements the data ingestion and knowledge base building components from the [ReGAIN research framework](https://arxiv.org/abs/2512.22223).

## ReGAIN Architecture Mapping

| ReGAIN Component | Implementation |
|------------------|----------------|
| Data Ingestion (§III-A) | `extractors/` - Extract from RDS, S3, Events |
| Summarization fsum (§III-A) | `summarization/` - Deterministic NL templates |
| Embedding fembed (§III-B) | `embeddings/` - Bedrock Titan Embeddings |
| Knowledge Base (§III-B) | `loaders/` - OpenSearch vector collections |
| Multi-Collection Architecture | `collections/` - Plans, Coverage, Network, Customer |

## Features

- Extract data from PostgreSQL (RDS), S3 documents, EventBridge events
- Transform and clean healthcare plan data
- Generate natural language summaries (ReGAIN fsum)
- Create embeddings via AWS Bedrock Titan
- Load into OpenSearch Serverless vector collections
- Batch and real-time ingestion pipelines
- PySpark jobs for large-scale processing

## Tech Stack

- Python 3.11+
- AWS SDK (boto3) - Bedrock, S3, RDS, EventBridge
- OpenSearch Python Client
- SQLAlchemy (database access)
- Pandas (data transformation)
- PySpark (large-scale processing)
- Jinja2 (summarization templates)

## Project Structure

```
data-engineering/
├── src/
│   ├── common/
│   │   ├── config_loader.py       # Load YAML configurations
│   │   ├── logging_config.py      # Structured logging
│   │   ├── aws_clients.py         # Boto3 client factories
│   │   └── exceptions.py          # Custom exceptions
│   │
│   ├── extractors/                # ETL - Extract
│   │   ├── base_extractor.py
│   │   ├── rds_plan_extractor.py
│   │   ├── rds_customer_extractor.py
│   │   ├── s3_document_extractor.py
│   │   └── event_extractor.py
│   │
│   ├── transformers/              # ETL - Transform
│   │   ├── base_transformer.py
│   │   ├── plan_transformer.py
│   │   ├── customer_transformer.py
│   │   └── document_chunker.py
│   │
│   ├── summarization/             # ReGAIN fsum
│   │   ├── base_summarizer.py
│   │   ├── plan_summarizer.py
│   │   ├── customer_summarizer.py
│   │   ├── coverage_summarizer.py
│   │   └── templates/
│   │       ├── plan_summary.jinja2
│   │       ├── customer_summary.jinja2
│   │       └── coverage_summary.jinja2
│   │
│   ├── embeddings/                # ReGAIN fembed
│   │   ├── base_embedder.py
│   │   ├── bedrock_titan_embedder.py
│   │   ├── cohere_embedder.py
│   │   └── batch_embedder.py
│   │
│   ├── loaders/                   # ETL - Load
│   │   ├── base_loader.py
│   │   ├── opensearch_loader.py
│   │   ├── pinecone_loader.py
│   │   └── pgvector_loader.py
│   │
│   ├── collections/               # Multi-collection management
│   │   ├── collection_manager.py
│   │   ├── plans_collection.py
│   │   ├── coverage_collection.py
│   │   ├── network_collection.py
│   │   └── customer_collection.py
│   │
│   └── pipelines/                 # Orchestrated pipelines
│       ├── base_pipeline.py
│       ├── plan_ingestion_pipeline.py
│       ├── customer_ingestion_pipeline.py
│       ├── incremental_update_pipeline.py
│       └── full_reindex_pipeline.py
│
├── jobs/                          # Standalone job scripts
│   ├── batch_ingest_plans.py
│   ├── batch_ingest_customers.py
│   ├── event_handler_lambda.py
│   ├── reindex_collection.py
│   └── embedding_model_migration.py
│
├── spark/                         # PySpark jobs
│   ├── spark_plan_processor.py
│   ├── spark_embedding_generator.py
│   └── spark_vector_loader.py
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── fixtures/
│
├── notebooks/                     # Jupyter notebooks
│   ├── 01_explore_plan_data.ipynb
│   ├── 02_embedding_analysis.ipynb
│   ├── 03_similarity_search_testing.ipynb
│   ├── 04_mmr_tuning.ipynb
│   └── 05_retrieval_evaluation.ipynb
│
├── scripts/
│   ├── setup_opensearch_indices.py
│   ├── seed_sample_data.py
│   └── validate_embeddings.py
│
├── config/
│   ├── config.yaml
│   ├── config.local.yaml
│   └── config.aws.yaml
│
├── Dockerfile
├── requirements.txt
├── pyproject.toml
├── .env.example
└── README.md
```

## ReGAIN Implementation Details

### Summarization (fsum) - Equation (2)

Converts structured plan records into natural language summaries:

**Input (Structured Record):**
```json
{
  "plan_id": "GOLD-2025-TX-042",
  "year": 2025,
  "state": "TX",
  "age_groups": ["46-65"],
  "focus_areas": ["diabetes_management", "preventive_care"],
  "monthly_premium": 380,
  "deductible": 1500,
  "inclusions": ["insulin_pumps", "cgm_devices", "annual_physicals"],
  "exclusions": ["cosmetic_surgery", "experimental_treatments"]
}
```

**Output (Natural Language Summary):**
```
The Gold 2025 plan (GOLD-2025-TX-042) is available in Texas for individuals 
aged 46-65. It focuses on diabetes management and preventive care. Monthly 
premium is $380 with a $1,500 annual deductible. Coverage includes insulin 
pumps, CGM devices, and annual physicals. Exclusions: cosmetic surgery and 
experimental treatments.
```

**Template (`templates/plan_summary.jinja2`):**
```jinja2
The {{ plan_name }} plan ({{ plan_id }}) is available 
{% if is_national %}nationally{% else %}in {{ state }}{% endif %} 
for individuals aged {{ age_groups | join(', ') }}. 
It focuses on {{ focus_areas | join(' and ') }}. 
Monthly premium is ${{ monthly_premium }} with a ${{ deductible }} annual deductible. 
Coverage includes {{ inclusions | join(', ') }}. 
Exclusions: {{ exclusions | join(' and ') }}.
```

### Embedding (fembed) - Equation (3)

Generates vector embeddings using AWS Bedrock:

```python
# src/embeddings/bedrock_titan_embedder.py

class BedrockTitanEmbedder(BaseEmbedder):
    """
    Implements ReGAIN Equation (3): vi = fembed(si) ∈ ℝᵈ
    Uses Amazon Titan Embeddings (1536 dimensions)
    """
    
    def __init__(self, model_id: str = "amazon.titan-embed-text-v2:0"):
        self.bedrock = boto3.client('bedrock-runtime')
        self.model_id = model_id
    
    def embed(self, text: str) -> list[float]:
        response = self.bedrock.invoke_model(
            modelId=self.model_id,
            body=json.dumps({"inputText": text})
        )
        return json.loads(response['body'].read())['embedding']
    
    def embed_batch(self, texts: list[str]) -> list[list[float]]:
        # Batch processing with rate limiting
        ...
```

### Knowledge Base Entry - Equation (4)

Each entry stored as: `ei = (si, vi, mi)`

```python
# src/loaders/opensearch_loader.py

class OpenSearchLoader(BaseLoader):
    """
    Implements ReGAIN Equation (4): ei = (si, vi, mi)
    Stores summary, embedding, and metadata
    """
    
    def load(self, entry: KnowledgeBaseEntry):
        document = {
            "summary": entry.summary,           # si - natural language
            "embedding": entry.embedding,        # vi - vector
            "metadata": {                        # mi - structured metadata
                "plan_id": entry.plan_id,
                "year": entry.year,
                "state": entry.state,
                "age_groups": entry.age_groups,
                "focus_areas": entry.focus_areas,
                "cost_tier": entry.cost_tier,
                "status": entry.status
            }
        }
        self.client.index(
            index=self.collection_name,
            body=document
        )
```

### Multi-Collection Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    OPENSEARCH SERVERLESS                        │
├─────────────────┬─────────────────┬─────────────────┬───────────┤
│ plans_collection│coverage_collectn│network_collectn │customer_  │
│                 │                 │                 │collection │
├─────────────────┼─────────────────┼─────────────────┼───────────┤
│ • Plan summaries│ • Inclusions    │ • Hospital info │ • Customer│
│ • Cost info     │ • Exclusions    │ • Provider nets │   profiles│
│ • Focus areas   │ • Claim examples│ • Geo coverage  │ • Prefs   │
├─────────────────┼─────────────────┼─────────────────┼───────────┤
│ Metadata:       │ Metadata:       │ Metadata:       │ Metadata: │
│ • plan_id       │ • plan_id       │ • hospital_id   │ • cust_id │
│ • year          │ • coverage_type │ • state         │ • state   │
│ • state         │ • category      │ • network_tier  │ • age_grp │
│ • age_groups[]  │                 │ • specialties[] │ • conds[] │
│ • focus_areas[] │                 │                 │           │
│ • cost_tier     │                 │                 │           │
└─────────────────┴─────────────────┴─────────────────┴───────────┘
```

## Getting Started

### Prerequisites

- Python 3.11+
- AWS CLI configured
- Access to AWS Bedrock, OpenSearch Serverless

### Installation

```bash
# Clone and navigate
cd data-engineering

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
.\venv\Scripts\activate   # Windows

# Install dependencies
pip install -r requirements.txt

# Copy environment file
cp .env.example .env
# Edit .env with your values
```

### Run Locally

```bash
# Run plan ingestion pipeline
python -m jobs.batch_ingest_plans --config config/config.local.yaml

# Run with specific collection
python -m jobs.reindex_collection --collection plans --config config/config.local.yaml

# Run tests
pytest tests/
```

## Environment Variables

See `.env.example`:

```bash
# AWS
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=<your-key>
AWS_SECRET_ACCESS_KEY=<your-secret>

# Bedrock
BEDROCK_EMBEDDING_MODEL_ID=amazon.titan-embed-text-v2:0

# OpenSearch
OPENSEARCH_ENDPOINT=<your-opensearch-endpoint>
OPENSEARCH_COLLECTION_PLANS=plans_collection
OPENSEARCH_COLLECTION_COVERAGE=coverage_collection
OPENSEARCH_COLLECTION_NETWORK=network_collection
OPENSEARCH_COLLECTION_CUSTOMER=customer_collection

# Source Databases
PLANS_DB_HOST=localhost
PLANS_DB_PORT=5432
PLANS_DB_NAME=plans_db
PLANS_DB_USER=plans_user
PLANS_DB_PASSWORD=<password>

CUSTOMER_DB_HOST=localhost
CUSTOMER_DB_PORT=5432
CUSTOMER_DB_NAME=customer_db
CUSTOMER_DB_USER=customer_user
CUSTOMER_DB_PASSWORD=<password>

# Pipeline Config
BATCH_SIZE=100
EMBEDDING_RATE_LIMIT=50  # requests per second
```

## Pipeline Execution

### Batch Ingestion (Full Load)

```bash
# Ingest all plans
python -m jobs.batch_ingest_plans

# Ingest all customers
python -m jobs.batch_ingest_customers

# Full reindex (all collections)
python -m jobs.reindex_collection --collection all
```

### Event-Driven Ingestion (Real-time)

Deploy `jobs/event_handler_lambda.py` as AWS Lambda:

```python
# jobs/event_handler_lambda.py

def handler(event, context):
    """
    Triggered by EventBridge for:
    - PlanCreated, PlanUpdated, PlanDeprecated
    - CustomerCreated, CustomerUpdated
    """
    event_type = event['detail-type']
    
    if event_type == 'PlanCreated':
        pipeline = PlanIngestionPipeline()
        pipeline.process_single(event['detail']['plan_id'])
    
    elif event_type == 'PlanUpdated':
        pipeline = IncrementalUpdatePipeline()
        pipeline.update_plan(event['detail']['plan_id'])
    
    # ... handle other events
```

### PySpark Jobs (Large Scale)

```bash
# Submit to EMR or local Spark
spark-submit \
  --master yarn \
  --deploy-mode cluster \
  spark/spark_plan_processor.py \
  --input s3://bucket/plans/ \
  --output s3://bucket/embeddings/
```

## Testing

```bash
# Unit tests
pytest tests/unit/

# Integration tests (requires local services)
pytest tests/integration/

# Specific test
pytest tests/unit/test_plan_summarizer.py -v
```

## Notebooks

Interactive notebooks for exploration and tuning:

| Notebook | Purpose |
|----------|---------|
| `01_explore_plan_data.ipynb` | Analyze plan data distribution |
| `02_embedding_analysis.ipynb` | Visualize embeddings (t-SNE/UMAP) |
| `03_similarity_search_testing.ipynb` | Test retrieval quality |
| `04_mmr_tuning.ipynb` | Tune MMR parameters |
| `05_retrieval_evaluation.ipynb` | ReGAIN §V evaluation metrics |

## DevOps

| Folder | Purpose |
|--------|---------|
| `devops/local/` | Docker Compose for local OpenSearch, LocalStack |
| `devops/aws/` | Lambda deployment, Step Functions, Terraform |
| `devops/azure/` | Azure Functions, Cognitive Search config |
| `devops/gcp/` | Cloud Functions, Vertex AI Vector Search |

## Monitoring

Key metrics to track:

| Metric | Description |
|--------|-------------|
| `ingestion.records.processed` | Records processed per run |
| `ingestion.errors.count` | Failed records |
| `embedding.latency.avg` | Bedrock API response time |
| `embedding.batch.size` | Records per batch |
| `opensearch.index.size` | Collection document count |
| `opensearch.index.latency` | Indexing time |