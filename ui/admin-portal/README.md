# Admin Portal

React-based web application for administrators to manage plans, monitor AI performance, and review system analytics.

## Features

- Dashboard with key metrics
- Plan management (CRUD)
- Knowledge base management (vector collections)
- RAG retrieval analytics
- Prompt engineering workbench
- Human-in-the-loop feedback review
- User management

## Tech Stack

- React 18
- TypeScript
- Vite
- Tailwind CSS
- React Query
- Recharts (analytics visualizations)

## Getting Started
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

## Environment Variables

See `.env.example` for required variables.

## Project Structure
```
src/
├── components/
│   ├── dashboard/        # Metrics and analytics
│   ├── knowledge-base/   # Vector DB management
│   ├── prompt-workbench/ # Prompt testing tools
│   └── feedback/         # Human review tools
├── pages/
├── hooks/
├── services/
├── store/
├── types/
└── utils/
```

## DevOps

| Folder | Purpose |
|--------|---------|
| `devops/local/` | Local Docker Compose setup |
| `devops/aws/` | AWS deployment (S3, CloudFront) |
| `devops/azure/` | Azure deployment (Static Web Apps) |
| `devops/gcp/` | GCP deployment (Cloud Storage, CDN) |