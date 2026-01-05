# Customer Portal

React-based web application for customers to browse, compare, and enroll in healthcare plans.

## Features

- User signup and login
- AI-powered plan search (semantic search)
- Plan recommendations with citations
- Plan comparison
- Shopping cart and checkout
- Order history
- AI chat assistant

## Tech Stack

- React 18
- TypeScript
- Vite
- Tailwind CSS
- React Query

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
├── components/       # Reusable UI components
├── pages/            # Page components
├── hooks/            # Custom React hooks
├── services/         # API service functions
├── store/            # State management
├── types/            # TypeScript types
└── utils/            # Utility functions
```

## DevOps

| Folder | Purpose |
|--------|---------|
| `devops/local/` | Local Docker Compose setup |
| `devops/aws/` | AWS deployment (S3, CloudFront) |
| `devops/azure/` | Azure deployment (Static Web Apps) |
| `devops/gcp/` | GCP deployment (Cloud Storage, CDN) |