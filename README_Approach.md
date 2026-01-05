# Development Approach

This document outlines the development approach, build order, data models, and synthetic data generation strategy for the Healthcare Plans AI Platform.

## Build Order

We build microservices first to establish database schemas and APIs, then use them to populate synthetic data for AI/RAG development.

```
┌─────────────────────────────────────────────────────────────────┐
│                        BUILD SEQUENCE                           │
└─────────────────────────────────────────────────────────────────┘

Step 1: plans-service
        │ • Plans, Categories, Specialists, Providers
        │ • Core reference data
        ▼
Step 2: customer-onboarding-service
        │ • Customers, Health Profiles, Preferences
        │ • Authentication (JWT)
        ▼
Step 3: order-service
        │ • Carts, Orders
        │ • Transactional data
        ▼
Step 4: Synthetic Data Generator
        │ • Python job + GitHub workflow
        │ • Populate all entities
        ▼
Step 5: data-engineering
        │ • ETL pipelines
        │ • Vector DB indexing (ReGAIN fsum, fembed)
        ▼
Step 6: ai-gateway-service
        │ • RAG retrieval pipeline
        │ • LLM reasoning with citations
        ▼
Step 7: UI Applications
        • customer-portal
        • admin-portal
```

---

## Synthetic Data Volume

| Entity | Count | Description |
|--------|-------|-------------|
| States | 51 | 50 US states + DC |
| Plan Categories | ~50 | diabetes, maternity, preventive, dental, vision, etc. |
| Age Groups | ~6 | 0-17, 18-25, 26-45, 46-65, 65+ |
| Specialties | ~50 | cardiology, endocrinology, pediatrics, etc. |
| Plans | 10,000 | Across years, states, age groups, categories |
| Healthcare Specialists | 10,000 | Doctors, specialists by type |
| Healthcare Providers | 10,000 | Hospitals, clinics, pharmacies, labs |
| Customers | 100,000 | Various demographics, health profiles |
| Orders | ~50,000 | Generated after customer flows |

---

## Database Schema Design

### Plans Service Schema

```
┌─────────────────────────────────────────────────────────────────┐
│                      PLANS SERVICE SCHEMA                       │
│                        Database: plans_db                       │
└─────────────────────────────────────────────────────────────────┘
```

#### Reference Tables

```sql
-- US States
┌─────────────────────────────────────────────────────────────────┐
│                          states                                 │
├─────────────────────────────────────────────────────────────────┤
│ code (PK)              VARCHAR(2)    -- TX, CA, NY             │
│ name                   VARCHAR(100)  -- Texas, California      │
│ region                 VARCHAR(50)   -- South, West, Northeast │
└─────────────────────────────────────────────────────────────────┘

-- Plan Categories (Focus Areas)
┌─────────────────────────────────────────────────────────────────┐
│                      plan_categories                            │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                SERIAL                                   │
│ code                   VARCHAR(50)   -- diabetes_management    │
│ name                   VARCHAR(100)  -- Diabetes Management    │
│ description            TEXT                                     │
│ created_at             TIMESTAMP                                │
└─────────────────────────────────────────────────────────────────┘

-- Age Groups
┌─────────────────────────────────────────────────────────────────┐
│                        age_groups                               │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                SERIAL                                   │
│ code                   VARCHAR(20)   -- "18-25", "26-45"       │
│ min_age                INTEGER                                  │
│ max_age                INTEGER                                  │
│ display_name           VARCHAR(50)   -- "Young Adults (18-25)" │
└─────────────────────────────────────────────────────────────────┘

-- Medical Specialties
┌─────────────────────────────────────────────────────────────────┐
│                       specialties                               │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                SERIAL                                   │
│ code                   VARCHAR(50)   -- cardiology             │
│ name                   VARCHAR(100)  -- Cardiology             │
│ description            TEXT                                     │
│ created_at             TIMESTAMP                                │
└─────────────────────────────────────────────────────────────────┘
```

#### Core Plans Tables

```sql
-- Main Plans Table
┌─────────────────────────────────────────────────────────────────┐
│                           plans                                 │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                UUID                                     │
│ plan_code              VARCHAR(50)   -- "GOLD-2025-TX-001"     │
│ plan_name              VARCHAR(200)                             │
│ year                   INTEGER                                  │
│ state_code (FK)        VARCHAR(2)    -- NULL if national       │
│ is_national            BOOLEAN       -- TRUE if nationwide     │
│ plan_type              VARCHAR(20)   -- HMO, PPO, EPO, POS     │
│ metal_tier             VARCHAR(20)   -- bronze,silver,gold,plat│
│ monthly_premium        DECIMAL(10,2)                            │
│ annual_deductible      DECIMAL(10,2)                            │
│ out_of_pocket_max      DECIMAL(10,2)                            │
│ copay_primary          DECIMAL(10,2) -- Primary care copay     │
│ copay_specialist       DECIMAL(10,2) -- Specialist copay       │
│ copay_emergency        DECIMAL(10,2) -- ER copay               │
│ out_of_network_pct     INTEGER       -- Coverage % for OON     │
│ status                 VARCHAR(20)   -- active, deprecated     │
│ effective_date         DATE                                     │
│ expiration_date        DATE                                     │
│ created_at             TIMESTAMP                                │
│ updated_at             TIMESTAMP                                │
├─────────────────────────────────────────────────────────────────┤
│ UNIQUE(plan_code)                                               │
│ INDEX(year, state_code, status)                                 │
│ INDEX(metal_tier, plan_type)                                    │
└─────────────────────────────────────────────────────────────────┘

-- Plan to Age Groups (Many-to-Many)
┌─────────────────────────────────────────────────────────────────┐
│                      plan_age_groups                            │
├─────────────────────────────────────────────────────────────────┤
│ plan_id (FK)           UUID                                     │
│ age_group_id (FK)      INTEGER                                  │
├─────────────────────────────────────────────────────────────────┤
│ PRIMARY KEY (plan_id, age_group_id)                             │
└─────────────────────────────────────────────────────────────────┘

-- Plan to Categories (Many-to-Many)
┌─────────────────────────────────────────────────────────────────┐
│                   plan_category_mappings                        │
├─────────────────────────────────────────────────────────────────┤
│ plan_id (FK)           UUID                                     │
│ category_id (FK)       INTEGER                                  │
├─────────────────────────────────────────────────────────────────┤
│ PRIMARY KEY (plan_id, category_id)                              │
└─────────────────────────────────────────────────────────────────┘
```

#### Coverage Details

```sql
-- Plan Inclusions (What's Covered)
┌─────────────────────────────────────────────────────────────────┐
│                      plan_inclusions                            │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                UUID                                     │
│ plan_id (FK)           UUID                                     │
│ coverage_item          VARCHAR(100)  -- "annual_physicals"     │
│ coverage_name          VARCHAR(200)  -- "Annual Physical Exams"│
│ description            TEXT                                     │
│ copay_amount           DECIMAL(10,2) -- NULL if no copay       │
│ coverage_percentage    INTEGER       -- 80, 100, etc.          │
│ prior_auth_required    BOOLEAN                                  │
│ created_at             TIMESTAMP                                │
├─────────────────────────────────────────────────────────────────┤
│ INDEX(plan_id)                                                  │
└─────────────────────────────────────────────────────────────────┘

-- Plan Exclusions (What's NOT Covered)
┌─────────────────────────────────────────────────────────────────┐
│                      plan_exclusions                            │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                UUID                                     │
│ plan_id (FK)           UUID                                     │
│ exclusion_item         VARCHAR(100)  -- "cosmetic_surgery"     │
│ exclusion_name         VARCHAR(200)  -- "Cosmetic Surgery"     │
│ description            TEXT                                     │
│ created_at             TIMESTAMP                                │
├─────────────────────────────────────────────────────────────────┤
│ INDEX(plan_id)                                                  │
└─────────────────────────────────────────────────────────────────┘
```

#### Healthcare Providers & Specialists

```sql
-- Healthcare Providers (Hospitals, Clinics, etc.)
┌─────────────────────────────────────────────────────────────────┐
│                   healthcare_providers                          │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                UUID                                     │
│ provider_code          VARCHAR(50)   -- Unique identifier      │
│ name                   VARCHAR(200)  -- "Memorial Hospital"    │
│ provider_type          VARCHAR(50)   -- hospital,clinic,pharmacy│
│ address_line1          VARCHAR(200)                             │
│ address_line2          VARCHAR(200)                             │
│ city                   VARCHAR(100)                             │
│ state_code (FK)        VARCHAR(2)                               │
│ zip_code               VARCHAR(10)                              │
│ phone                  VARCHAR(20)                              │
│ email                  VARCHAR(200)                             │
│ website                VARCHAR(200)                             │
│ latitude               DECIMAL(10,8)                            │
│ longitude              DECIMAL(11,8)                            │
│ network_tier           VARCHAR(20)   -- tier1, tier2, tier3    │
│ accepting_patients     BOOLEAN                                  │
│ status                 VARCHAR(20)   -- active, inactive       │
│ created_at             TIMESTAMP                                │
│ updated_at             TIMESTAMP                                │
├─────────────────────────────────────────────────────────────────┤
│ UNIQUE(provider_code)                                           │
│ INDEX(state_code, city)                                         │
│ INDEX(provider_type, status)                                    │
│ INDEX(latitude, longitude)                                      │
└─────────────────────────────────────────────────────────────────┘

-- Healthcare Specialists (Doctors)
┌─────────────────────────────────────────────────────────────────┐
│                  healthcare_specialists                         │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                UUID                                     │
│ npi_number             VARCHAR(20)   -- National Provider ID   │
│ first_name             VARCHAR(100)                             │
│ last_name              VARCHAR(100)                             │
│ title                  VARCHAR(20)   -- MD, DO, NP, PA         │
│ specialty_id (FK)      INTEGER                                  │
│ email                  VARCHAR(200)                             │
│ phone                  VARCHAR(20)                              │
│ years_experience       INTEGER                                  │
│ languages              VARCHAR(200)  -- "English,Spanish"      │
│ accepting_patients     BOOLEAN                                  │
│ status                 VARCHAR(20)   -- active, inactive       │
│ created_at             TIMESTAMP                                │
│ updated_at             TIMESTAMP                                │
├─────────────────────────────────────────────────────────────────┤
│ UNIQUE(npi_number)                                              │
│ INDEX(specialty_id, status)                                     │
│ INDEX(last_name, first_name)                                    │
└─────────────────────────────────────────────────────────────────┘

-- Provider-Specialist Relationship (Where doctors practice)
┌─────────────────────────────────────────────────────────────────┐
│                  provider_specialists                           │
├─────────────────────────────────────────────────────────────────┤
│ provider_id (FK)       UUID                                     │
│ specialist_id (FK)     UUID                                     │
│ is_primary_location    BOOLEAN                                  │
│ start_date             DATE                                     │
├─────────────────────────────────────────────────────────────────┤
│ PRIMARY KEY (provider_id, specialist_id)                        │
└─────────────────────────────────────────────────────────────────┘

-- Plan Network (Which providers are in which plans)
┌─────────────────────────────────────────────────────────────────┐
│                      plan_providers                             │
├─────────────────────────────────────────────────────────────────┤
│ plan_id (FK)           UUID                                     │
│ provider_id (FK)       UUID                                     │
│ network_status         VARCHAR(20)   -- in_network, out_network│
│ effective_date         DATE                                     │
├─────────────────────────────────────────────────────────────────┤
│ PRIMARY KEY (plan_id, provider_id)                              │
│ INDEX(provider_id)                                              │
└─────────────────────────────────────────────────────────────────┘
```

---

### Customer Onboarding Service Schema

```
┌─────────────────────────────────────────────────────────────────┐
│               CUSTOMER ONBOARDING SERVICE SCHEMA                │
│                      Database: customer_db                      │
└─────────────────────────────────────────────────────────────────┘
```

```sql
-- Customers
┌─────────────────────────────────────────────────────────────────┐
│                        customers                                │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                UUID                                     │
│ email                  VARCHAR(200)                             │
│ password_hash          VARCHAR(200)                             │
│ first_name             VARCHAR(100)                             │
│ last_name              VARCHAR(100)                             │
│ date_of_birth          DATE                                     │
│ gender                 VARCHAR(20)                              │
│ phone                  VARCHAR(20)                              │
│ address_line1          VARCHAR(200)                             │
│ address_line2          VARCHAR(200)                             │
│ city                   VARCHAR(100)                             │
│ state_code             VARCHAR(2)                               │
│ zip_code               VARCHAR(10)                              │
│ status                 VARCHAR(20)   -- active,inactive,pending│
│ email_verified         BOOLEAN                                  │
│ created_at             TIMESTAMP                                │
│ updated_at             TIMESTAMP                                │
├─────────────────────────────────────────────────────────────────┤
│ UNIQUE(email)                                                   │
│ INDEX(state_code, status)                                       │
└─────────────────────────────────────────────────────────────────┘

-- Customer Health Profiles
┌─────────────────────────────────────────────────────────────────┐
│                    health_profiles                              │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                UUID                                     │
│ customer_id (FK)       UUID          -- One-to-One             │
│ height_inches          INTEGER                                  │
│ weight_lbs             INTEGER                                  │
│ smoker                 BOOLEAN                                  │
│ pre_existing_summary   TEXT          -- Free text summary      │
│ created_at             TIMESTAMP                                │
│ updated_at             TIMESTAMP                                │
├─────────────────────────────────────────────────────────────────┤
│ UNIQUE(customer_id)                                             │
└─────────────────────────────────────────────────────────────────┘

-- Health Conditions (Many-to-Many)
┌─────────────────────────────────────────────────────────────────┐
│                    health_conditions                            │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                SERIAL                                   │
│ code                   VARCHAR(50)   -- diabetes, hypertension │
│ name                   VARCHAR(100)  -- Diabetes               │
│ category               VARCHAR(50)   -- chronic, acute         │
│ description            TEXT                                     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                customer_health_conditions                       │
├─────────────────────────────────────────────────────────────────┤
│ customer_id (FK)       UUID                                     │
│ condition_id (FK)      INTEGER                                  │
│ diagnosed_date         DATE                                     │
│ severity               VARCHAR(20)   -- mild, moderate, severe │
├─────────────────────────────────────────────────────────────────┤
│ PRIMARY KEY (customer_id, condition_id)                         │
└─────────────────────────────────────────────────────────────────┘

-- Customer Preferences
┌─────────────────────────────────────────────────────────────────┐
│                  customer_preferences                           │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                UUID                                     │
│ customer_id (FK)       UUID          -- One-to-One             │
│ priority               VARCHAR(50)   -- cost, coverage, network│
│ max_monthly_budget     DECIMAL(10,2)                            │
│ preferred_plan_type    VARCHAR(20)   -- HMO, PPO, etc.         │
│ preferred_metal_tier   VARCHAR(20)   -- gold, silver, etc.     │
│ wants_dental           BOOLEAN                                  │
│ wants_vision           BOOLEAN                                  │
│ wants_mental_health    BOOLEAN                                  │
│ created_at             TIMESTAMP                                │
│ updated_at             TIMESTAMP                                │
├─────────────────────────────────────────────────────────────────┤
│ UNIQUE(customer_id)                                             │
└─────────────────────────────────────────────────────────────────┘
```

---

### Order Service Schema

```
┌─────────────────────────────────────────────────────────────────┐
│                     ORDER SERVICE SCHEMA                        │
│                       Database: order_db                        │
└─────────────────────────────────────────────────────────────────┘
```

```sql
-- Shopping Carts
┌─────────────────────────────────────────────────────────────────┐
│                          carts                                  │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                UUID                                     │
│ customer_id            UUID                                     │
│ status                 VARCHAR(20)   -- active,checkedout,abandoned│
│ created_at             TIMESTAMP                                │
│ updated_at             TIMESTAMP                                │
├─────────────────────────────────────────────────────────────────┤
│ INDEX(customer_id, status)                                      │
└─────────────────────────────────────────────────────────────────┘

-- Cart Items
┌─────────────────────────────────────────────────────────────────┐
│                       cart_items                                │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                UUID                                     │
│ cart_id (FK)           UUID                                     │
│ plan_id                UUID          -- Reference to plans_db  │
│ plan_code              VARCHAR(50)   -- Denormalized for display│
│ plan_name              VARCHAR(200)  -- Denormalized           │
│ monthly_premium        DECIMAL(10,2) -- Price at time of add   │
│ added_at               TIMESTAMP                                │
├─────────────────────────────────────────────────────────────────┤
│ INDEX(cart_id)                                                  │
└─────────────────────────────────────────────────────────────────┘

-- Orders
┌─────────────────────────────────────────────────────────────────┐
│                         orders                                  │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                UUID                                     │
│ order_number           VARCHAR(50)   -- ORD-2025-000001        │
│ customer_id            UUID                                     │
│ total_monthly_cost     DECIMAL(10,2)                            │
│ status                 VARCHAR(20)   -- pending,confirmed,active,cancelled│
│ effective_date         DATE                                     │
│ submitted_at           TIMESTAMP                                │
│ confirmed_at           TIMESTAMP                                │
│ cancelled_at           TIMESTAMP                                │
│ cancellation_reason    TEXT                                     │
│ created_at             TIMESTAMP                                │
│ updated_at             TIMESTAMP                                │
├─────────────────────────────────────────────────────────────────┤
│ UNIQUE(order_number)                                            │
│ INDEX(customer_id, status)                                      │
│ INDEX(status, created_at)                                       │
└─────────────────────────────────────────────────────────────────┘

-- Order Items (Snapshot of plan at order time)
┌─────────────────────────────────────────────────────────────────┐
│                      order_items                                │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                UUID                                     │
│ order_id (FK)          UUID                                     │
│ plan_id                UUID                                     │
│ plan_code              VARCHAR(50)                              │
│ plan_name              VARCHAR(200)                             │
│ plan_year              INTEGER                                  │
│ monthly_premium        DECIMAL(10,2)                            │
│ annual_deductible      DECIMAL(10,2)                            │
│ plan_snapshot          JSONB         -- Full plan details      │
│ created_at             TIMESTAMP                                │
├─────────────────────────────────────────────────────────────────┤
│ INDEX(order_id)                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ENTITY RELATIONSHIPS                                 │
└─────────────────────────────────────────────────────────────────────────────┘

PLANS SERVICE (plans_db)
═══════════════════════

                    ┌──────────────┐
                    │    states    │
                    └──────┬───────┘
                           │ 1
                           │
                           │ *
┌──────────────┐    ┌──────┴───────┐    ┌──────────────┐
│plan_categories│◄──┤    plans     ├───►│  age_groups  │
└──────────────┘ *  └──────┬───────┘  * └──────────────┘
       ▲                   │
       │                   │ 1
       │                   │
       │         ┌─────────┼─────────┐
       │         │         │         │
       │         ▼ *       ▼ *       ▼ *
       │   ┌──────────┐ ┌──────────┐ ┌──────────────┐
       │   │inclusions│ │exclusions│ │plan_providers│
       │   └──────────┘ └──────────┘ └──────┬───────┘
       │                                     │ *
       │                                     │
       │                                     ▼ 1
       │                              ┌──────────────────┐
       │                              │healthcare_       │
       │                              │providers         │
       │                              └────────┬─────────┘
       │                                       │ *
       │                                       │
       │                                       ▼ *
       │                              ┌──────────────────┐
       │                              │provider_         │
       │                              │specialists       │
       │                              └────────┬─────────┘
       │                                       │ *
       │                                       │
       │                                       ▼ 1
       │                              ┌──────────────────┐    ┌─────────────┐
       └──────────────────────────────┤healthcare_       ├───►│ specialties │
                                      │specialists       │  * └─────────────┘
                                      └──────────────────┘


CUSTOMER SERVICE (customer_db)
══════════════════════════════

┌──────────────────┐
│    customers     │
└────────┬─────────┘
         │ 1
         │
         ├─────────────────┬─────────────────┐
         │                 │                 │
         ▼ 1               ▼ 1               ▼ *
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ health_profiles │ │   preferences   │ │customer_health_ │
└─────────────────┘ └─────────────────┘ │conditions       │
                                        └────────┬────────┘
                                                 │ *
                                                 ▼ 1
                                        ┌─────────────────┐
                                        │health_conditions│
                                        └─────────────────┘


ORDER SERVICE (order_db)
════════════════════════

┌──────────────────┐         ┌──────────────────┐
│      carts       │         │     orders       │
└────────┬─────────┘         └────────┬─────────┘
         │ 1                          │ 1
         │                            │
         ▼ *                          ▼ *
┌──────────────────┐         ┌──────────────────┐
│   cart_items     │         │   order_items    │
└──────────────────┘         └──────────────────┘
```

---

## Synthetic Data Generator

### GitHub Workflow

A manual GitHub workflow will trigger synthetic data generation:

```yaml
# .github/workflows/data-seed-synthetic.yml
name: Generate Synthetic Data

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - local
          - dev
      plans_count:
        description: 'Number of plans to generate'
        default: '10000'
      customers_count:
        description: 'Number of customers to generate'
        default: '100000'
      providers_count:
        description: 'Number of providers to generate'
        default: '10000'
      specialists_count:
        description: 'Number of specialists to generate'
        default: '10000'
```

### Data Generation Strategy

```
┌─────────────────────────────────────────────────────────────────┐
│                  SYNTHETIC DATA GENERATION                      │
└─────────────────────────────────────────────────────────────────┘

Phase 1: Reference Data (Run Once)
──────────────────────────────────
• 51 States (50 + DC)
• 50 Plan Categories
• 6 Age Groups
• 50 Medical Specialties
• 30 Health Conditions

Phase 2: Core Entities (Configurable Count)
───────────────────────────────────────────
• 10,000 Healthcare Providers
  - Distribution: 20% hospitals, 50% clinics, 20% pharmacies, 10% labs
  - Spread across all states weighted by population

• 10,000 Healthcare Specialists
  - Realistic NPI numbers
  - Distributed across specialties
  - 70% accepting patients

• 10,000 Plans
  - Years: 2024, 2025, 2026
  - Metal tiers: bronze (30%), silver (40%), gold (20%), platinum (10%)
  - Types: HMO (40%), PPO (35%), EPO (15%), POS (10%)
  - Mix of state-specific (80%) and national (20%)
  - 3-5 categories per plan
  - 10-20 inclusions, 5-10 exclusions per plan

Phase 3: Customer Data
──────────────────────
• 100,000 Customers
  - Realistic age distribution
  - Geographic distribution matching US population
  - 60% with health conditions
  - 80% with preferences set

Phase 4: Transactional Data
───────────────────────────
• Network assignments (plan_providers)
  - Each plan: 100-500 in-network providers

• Provider-Specialist assignments
  - Each provider: 5-50 specialists

• Orders (optional, ~50,000)
  - Historical orders for testing
```

### Python Generator Structure

```
data-engineering/
└── synthetic/
    ├── __init__.py
    ├── generator.py              # Main orchestrator
    ├── config.py                 # Generation parameters
    ├── generators/
    │   ├── __init__.py
    │   ├── reference_data.py     # States, categories, specialties
    │   ├── plans_generator.py    # Plans with inclusions/exclusions
    │   ├── providers_generator.py
    │   ├── specialists_generator.py
    │   ├── customers_generator.py
    │   └── orders_generator.py
    ├── data/
    │   ├── states.json           # US states data
    │   ├── categories.json       # Plan category definitions
    │   ├── specialties.json      # Medical specialties
    │   ├── conditions.json       # Health conditions
    │   ├── coverage_items.json   # Inclusion/exclusion items
    │   └── first_names.txt       # Name generation
    └── loaders/
        ├── __init__.py
        └── api_loader.py         # Load via REST APIs
```

---

## Technology Decisions (To Confirm)

| Decision | Options | Recommended |
|----------|---------|-------------|
| Java Version | 17, 21 | **Java 17** (LTS, widely supported) |
| Spring Boot | 3.2.x, 3.3.x | **3.2.x** (stable) |
| Build Tool | Maven, Gradle | **Maven** (familiar) |
| Database | PostgreSQL | **PostgreSQL 15+** |
| API Docs | SpringDoc OpenAPI | **Yes** |
| Migration | Flyway, Liquibase | **Flyway** |
| Testing | JUnit 5, Testcontainers | **Both** |

---

## Next Steps

1. **Confirm schema design** - Any changes needed?
2. **Confirm technology choices** - Java version, Spring Boot version?
3. **Start plans-service** - Create Spring Boot project structure
4. **Implement APIs** - CRUD + filtering endpoints
5. **Build synthetic data generator** - Python scripts
6. **Create GitHub workflow** - Manual trigger for data generation