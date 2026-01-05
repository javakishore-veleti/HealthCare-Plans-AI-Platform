# AI Gateway Service

Spring Boot microservice implementing the RAG (Retrieval-Augmented Generation) pipeline inspired by the [ReGAIN research framework](https://arxiv.org/abs/2512.22223). This service orchestrates semantic search, intelligent recommendations, and conversational AI for healthcare plans.

## ReGAIN Architecture Mapping

| ReGAIN Component | Implementation |
|------------------|----------------|
| Query Processing | `QueryProcessorService` - Entity extraction, metadata filter construction |
| Metadata Filtering (φ) | `MetadataFilterBuilder` - year, state, age_group, focus_areas |
| Semantic Search | `RetrievalService` - OpenSearch k-NN with cosine similarity |
| MMR Sampling | `MMRDiversitySampler` - Maximal Marginal Relevance |
| Cross-Encoder Reranking | `RerankingService` - Fine-grained relevance scoring |
| Abstention Mechanism | `AbstentionService` - Quality gate before LLM |
| LLM Reasoning | `LLMReasoningService` - AWS Bedrock Claude |
| Citation Extraction | `CitationExtractor` - Evidence-backed responses |

## Features

- Semantic plan search (natural language queries)
- Personalized plan recommendations with citations
- AI chat assistant with conversation memory
- Abstention for low-confidence queries
- Human-in-the-loop feedback integration

## Tech Stack

- Java 17
- Spring Boot 3
- Spring WebFlux (reactive for streaming)
- AWS Bedrock SDK (Claude, Titan Embeddings)
- OpenSearch Java Client
- WebSocket (chat streaming)

## API Endpoints

### Semantic Search

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/ai/search` | Semantic plan search |

**Request:**
```json
{
  "query": "affordable plan for diabetic senior in Texas",
  "filters": {
    "year": 2025,
    "maxCost": 500
  },
  "limit": 5
}
```

**Response:**
```json
{
  "results": [
    {
      "planId": "GOLD-2025-TX-042",
      "planName": "Texas Diabetes Care Gold",
      "score": 0.92,
      "matchReasons": ["diabetes_management", "senior_age_group", "texas_coverage"]
    }
  ],
  "searchMetadata": {
    "totalCandidates": 150,
    "filteredCandidates": 45,
    "retrievalTimeMs": 120
  }
}
```

### Recommendations

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/ai/recommend` | Get personalized recommendations |

**Request:**
```json
{
  "customerId": "uuid",
  "context": "Looking for better diabetes coverage"
}
```

**Response:**
```json
{
  "verdict": "RECOMMENDED",
  "recommendations": [
    {
      "planId": "GOLD-2025-TX-042",
      "planName": "Texas Diabetes Care Gold",
      "matchScore": 0.94,
      "reasoning": "This plan specifically covers diabetes management [Citation: focus_areas] including insulin pumps and CGMs [Citation: inclusions.medical_devices].",
      "citations": [
        {"ref": "GOLD-2025-TX-042.focus_areas", "value": "diabetes_management"},
        {"ref": "GOLD-2025-TX-042.inclusions", "value": "insulin pumps, CGM"}
      ]
    }
  ],
  "alternatives": ["..."],
  "nextSteps": [
    "Compare in-network endocrinologists in your ZIP code",
    "Review the diabetes management benefits document"
  ]
}
```

### Chat Assistant

| Method | Endpoint | Description |
|--------|----------|-------------|
| WebSocket | `/ws/ai/chat` | Streaming chat connection |
| POST | `/api/v1/ai/chat` | Single chat message (non-streaming) |

**Request:**
```json
{
  "sessionId": "uuid",
  "message": "Does this plan cover insulin pumps?",
  "context": {
    "currentPlanId": "GOLD-2025-TX-042"
  }
}
```

**Response:**
```json
{
  "sessionId": "uuid",
  "response": "Yes, the Texas Diabetes Care Gold plan covers insulin pumps [Citation: inclusions.medical_devices]. The coverage includes...",
  "citations": ["..."],
  "suggestedFollowUps": [
    "What is the copay for insulin pumps?",
    "Are there preferred pump brands?"
  ]
}
```

### Abstention Response

When evidence is insufficient:

```json
{
  "verdict": "UNDECIDABLE",
  "reason": "Insufficient matching plans for specified criteria",
  "missingContext": [
    "No plans with dental implant coverage in Alaska for 2025"
  ],
  "suggestion": "Consider national plans or consult healthcare.gov"
}
```

## Getting Started

```bash
# Build
./mvnw clean package

# Run locally
./mvnw spring-boot:run -Dspring.profiles.active=local

# Run tests
./mvnw test
```

## Environment Variables

See `.env.example` for required variables.

## Project Structure

```
src/main/java/com/healthcare/ai/
├── config/
│   ├── BedrockConfig.java
│   ├── OpenSearchConfig.java
│   └── WebSocketConfig.java
├── controller/
│   ├── SemanticSearchController.java
│   ├── RecommendationController.java
│   └── ChatController.java
├── service/
│   ├── QueryProcessorService.java
│   ├── RetrievalService.java
│   ├── RerankingService.java
│   ├── AbstentionService.java
│   ├── LLMReasoningService.java
│   └── ChatSessionService.java
├── rag/
│   ├── HierarchicalRetrievalPipeline.java
│   ├── MetadataFilterBuilder.java
│   ├── MMRDiversitySampler.java
│   └── CitationExtractor.java
├── client/
│   ├── BedrockEmbeddingClient.java
│   ├── BedrockLLMClient.java
│   └── OpenSearchVectorClient.java
├── dto/
│   ├── SearchRequest.java
│   ├── SearchResponse.java
│   ├── RecommendationRequest.java
│   ├── RecommendationResponse.java
│   └── AIResponseWithCitations.java
└── prompts/
    └── (loaded from resources)

src/main/resources/
├── application.yml
├── application-local.yml
├── application-aws.yml
└── prompts/
    ├── recommendation_system.txt
    ├── recommendation_user.txt
    ├── chat_system.txt
    └── comparison_system.txt
```

## RAG Pipeline Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     USER QUERY                                  │
│  "affordable plan for diabetic senior in Texas"                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 1: QueryProcessorService                                  │
│  • Extract entities: age=senior, condition=diabetic, state=TX   │
│  • Build metadata filter (φ)                                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 2: RetrievalService                                       │
│  • Apply metadata filter → reduce candidates                    │
│  • Embed query via Bedrock Titan                                │
│  • k-NN search in OpenSearch (τ = 0.3 threshold)                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 3: MMRDiversitySampler                                    │
│  • Balance relevance vs diversity                               │
│  • Ensure variety (insurers, cost tiers)                        │
│  • k=6, fetch_k=18, λ=0.7                                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 4: RerankingService                                       │
│  • Cross-encoder scoring on (query, plan) pairs                 │
│  • Rerank to top-5                                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 5: AbstentionService                                      │
│  • Check: |results| >= 2?                                       │
│  • Check: max_score >= 0.5?                                     │
│  • Check: no conflicting evidence?                              │
│  • If fail → return UNDECIDABLE                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 6: LLMReasoningService                                    │
│  • Build prompt with retrieved evidence                         │
│  • Call Bedrock Claude (temperature=0)                          │
│  • Parse structured response                                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 7: CitationExtractor                                      │
│  • Extract citations from LLM response                          │
│  • Map to source plan fields                                    │
│  • Return final response with evidence                          │
└─────────────────────────────────────────────────────────────────┘
```

## Configuration (ReGAIN Parameters)

```yaml
# application.yml
rag:
  similarity-threshold: 0.3      # τ - minimum similarity score
  mmr:
    k: 6                         # final results count
    fetch-k: 18                  # candidates to consider
    lambda: 0.7                  # relevance vs diversity balance
  abstention:
    min-evidence-count: 2        # minimum results required
    high-confidence-threshold: 0.5

bedrock:
  embedding-model: amazon.titan-embed-text-v2:0
  llm-model: anthropic.claude-3-sonnet-20240229-v1:0
  temperature: 0                 # deterministic output
  max-tokens: 1024
```

## Prompt Templates

### Recommendation System Prompt

```
You are a healthcare plan advisor AI. Your task is to recommend plans based ONLY on the evidence provided.

RULES:
1. Cite plan IDs in your reasoning using [Citation: field_name] format
2. If evidence is insufficient, output verdict: UNDECIDABLE
3. Never hallucinate benefits not present in the evidence
4. Provide assertive, confident assessments
5. Include 1-2 actionable next steps

OUTPUT FORMAT:
{
  "verdict": "RECOMMENDED" | "UNDECIDABLE",
  "recommendations": [...],
  "reasoning": "...",
  "citations": [...],
  "nextSteps": [...]
}
```

### Chat System Prompt

```
You are a helpful healthcare plan assistant. Answer questions about plans using ONLY the provided context.

RULES:
1. Always cite your sources using [Citation: plan_id.field]
2. If you don't know or can't find the answer, say so clearly
3. Be concise but thorough
4. Suggest relevant follow-up questions

CONTEXT:
{retrieved_plan_summaries}

CONVERSATION HISTORY:
{chat_history}
```

## DevOps

| Folder | Purpose |
|--------|---------|
| `devops/local/` | Docker Compose, LocalStack for Bedrock mock |
| `devops/aws/` | ECS task definition, Bedrock IAM policies, Terraform |
| `devops/azure/` | Container Apps config, Azure OpenAI setup |
| `devops/gcp/` | Cloud Run config, Vertex AI setup |

## Testing

```bash
# Unit tests
./mvnw test

# Integration tests (requires local OpenSearch)
./mvnw verify -P integration-tests

# RAG pipeline tests
./mvnw test -Dtest=HierarchicalRetrievalPipelineTest
```

## Monitoring & Observability

Key metrics to track:

| Metric | Description |
|--------|-------------|
| `rag.retrieval.latency` | Time for vector search |
| `rag.similarity.score.avg` | Average similarity scores |
| `rag.abstention.rate` | % of queries returning UNDECIDABLE |
| `rag.reranking.position.change` | How much reranking changes order |
| `llm.request.latency` | Bedrock API response time |
| `llm.token.usage` | Input/output token counts |