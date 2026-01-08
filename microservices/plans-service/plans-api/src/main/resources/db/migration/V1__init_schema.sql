-- =============================================================================
-- Plans Service - Initial Schema
-- =============================================================================

-- States (reference table)
CREATE TABLE states (
                        code VARCHAR(2) PRIMARY KEY,
                        name VARCHAR(100) NOT NULL,
                        region VARCHAR(50)
);

-- Age Groups
CREATE TABLE age_groups (
                            id BIGSERIAL PRIMARY KEY,
                            code VARCHAR(20) NOT NULL UNIQUE,
                            min_age INTEGER NOT NULL,
                            max_age INTEGER NOT NULL,
                            display_name VARCHAR(50) NOT NULL,
                            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Plan Categories
CREATE TABLE plan_categories (
                                 id BIGSERIAL PRIMARY KEY,
                                 code VARCHAR(50) NOT NULL UNIQUE,
                                 name VARCHAR(100) NOT NULL,
                                 description TEXT,
                                 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Specialties
CREATE TABLE specialties (
                             id BIGSERIAL PRIMARY KEY,
                             code VARCHAR(50) NOT NULL UNIQUE,
                             name VARCHAR(100) NOT NULL,
                             description TEXT,
                             created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                             updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Plans
CREATE TABLE plans (
                       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                       plan_code VARCHAR(50) NOT NULL UNIQUE,
                       plan_name VARCHAR(200) NOT NULL,
                       year INTEGER NOT NULL,
                       state_code VARCHAR(2) REFERENCES states(code),
                       is_national BOOLEAN NOT NULL DEFAULT FALSE,
                       plan_type VARCHAR(20) NOT NULL,
                       metal_tier VARCHAR(20) NOT NULL,
                       monthly_premium DECIMAL(10,2) NOT NULL,
                       annual_deductible DECIMAL(10,2) NOT NULL,
                       out_of_pocket_max DECIMAL(10,2) NOT NULL,
                       copay_primary DECIMAL(10,2),
                       copay_specialist DECIMAL(10,2),
                       copay_emergency DECIMAL(10,2),
                       out_of_network_pct INTEGER,
                       status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
                       effective_date DATE NOT NULL,
                       expiration_date DATE,
                       created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                       updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_plans_year_state_status ON plans(year, state_code, status);
CREATE INDEX idx_plans_metal_tier_type ON plans(metal_tier, plan_type);

-- Plan Age Groups (many-to-many)
CREATE TABLE plan_age_groups (
                                 plan_id UUID REFERENCES plans(id) ON DELETE CASCADE,
                                 age_group_id BIGINT REFERENCES age_groups(id) ON DELETE CASCADE,
                                 PRIMARY KEY (plan_id, age_group_id)
);

-- Plan Category Mappings (many-to-many)
CREATE TABLE plan_category_mappings (
                                        plan_id UUID REFERENCES plans(id) ON DELETE CASCADE,
                                        category_id BIGINT REFERENCES plan_categories(id) ON DELETE CASCADE,
                                        PRIMARY KEY (plan_id, category_id)
);

-- Plan Inclusions
CREATE TABLE plan_inclusions (
                                 id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                 plan_id UUID NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
                                 coverage_item VARCHAR(100) NOT NULL,
                                 coverage_name VARCHAR(200) NOT NULL,
                                 description TEXT,
                                 copay_amount DECIMAL(10,2),
                                 coverage_percentage INTEGER,
                                 prior_auth_required BOOLEAN NOT NULL DEFAULT FALSE,
                                 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_plan_inclusions_plan_id ON plan_inclusions(plan_id);

-- Plan Exclusions
CREATE TABLE plan_exclusions (
                                 id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                 plan_id UUID NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
                                 exclusion_item VARCHAR(100) NOT NULL,
                                 exclusion_name VARCHAR(200) NOT NULL,
                                 description TEXT,
                                 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_plan_exclusions_plan_id ON plan_exclusions(plan_id);

-- Healthcare Providers
CREATE TABLE healthcare_providers (
                                      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                      provider_code VARCHAR(50) NOT NULL UNIQUE,
                                      name VARCHAR(200) NOT NULL,
                                      provider_type VARCHAR(50) NOT NULL,
                                      address_line1 VARCHAR(200) NOT NULL,
                                      address_line2 VARCHAR(200),
                                      city VARCHAR(100) NOT NULL,
                                      state_code VARCHAR(2) NOT NULL REFERENCES states(code),
                                      zip_code VARCHAR(10) NOT NULL,
                                      phone VARCHAR(20),
                                      email VARCHAR(200),
                                      website VARCHAR(200),
                                      latitude DECIMAL(10,8),
                                      longitude DECIMAL(11,8),
                                      network_tier VARCHAR(20),
                                      accepting_patients BOOLEAN NOT NULL DEFAULT TRUE,
                                      status VARCHAR(20) NOT NULL DEFAULT 'active',
                                      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_providers_state_city ON healthcare_providers(state_code, city);
CREATE INDEX idx_providers_type_status ON healthcare_providers(provider_type, status);
CREATE INDEX idx_providers_location ON healthcare_providers(latitude, longitude);

-- Healthcare Specialists
CREATE TABLE healthcare_specialists (
                                        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                        npi_number VARCHAR(20) NOT NULL UNIQUE,
                                        first_name VARCHAR(100) NOT NULL,
                                        last_name VARCHAR(100) NOT NULL,
                                        title VARCHAR(20),
                                        specialty_id BIGINT NOT NULL REFERENCES specialties(id),
                                        email VARCHAR(200),
                                        phone VARCHAR(20),
                                        years_experience INTEGER,
                                        languages VARCHAR(200),
                                        accepting_patients BOOLEAN NOT NULL DEFAULT TRUE,
                                        status VARCHAR(20) NOT NULL DEFAULT 'active',
                                        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_specialists_specialty_status ON healthcare_specialists(specialty_id, status);
CREATE INDEX idx_specialists_name ON healthcare_specialists(last_name, first_name);

-- Provider Specialists (many-to-many)
CREATE TABLE provider_specialists (
                                      provider_id UUID REFERENCES healthcare_providers(id) ON DELETE CASCADE,
                                      specialist_id UUID REFERENCES healthcare_specialists(id) ON DELETE CASCADE,
                                      PRIMARY KEY (provider_id, specialist_id)
);

-- Plan Providers (network mapping)
CREATE TABLE plan_providers (
                                plan_id UUID REFERENCES plans(id) ON DELETE CASCADE,
                                provider_id UUID REFERENCES healthcare_providers(id) ON DELETE CASCADE,
                                network_status VARCHAR(20) NOT NULL DEFAULT 'IN_NETWORK',
                                effective_date DATE,
                                PRIMARY KEY (plan_id, provider_id)
);