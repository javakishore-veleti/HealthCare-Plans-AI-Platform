-- =============================================================================
-- Customer Onboarding Service - Initial Schema
-- =============================================================================

-- Customers table
CREATE TABLE customers (
    id UUID PRIMARY KEY,
    customer_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE,
    phone VARCHAR(20),
    mobile_phone VARCHAR(20),
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20),
    ssn_last4 VARCHAR(4),
    ssn_encrypted VARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    preferred_language VARCHAR(10) DEFAULT 'en',
    marketing_opt_in BOOLEAN DEFAULT FALSE,
    sms_opt_in BOOLEAN DEFAULT FALSE,
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_ssn_last4 ON customers(ssn_last4);
CREATE INDEX idx_customers_status ON customers(status);
CREATE INDEX idx_customers_customer_number ON customers(customer_number);

-- Customer addresses table
CREATE TABLE customer_addresses (
    id UUID PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    address_type VARCHAR(20) ,
    address_line1 VARCHAR(200) ,
    address_line2 VARCHAR(200),
    city VARCHAR(100) ,
    state_code VARCHAR(2) ,
    zip_code VARCHAR(10) ,
    country VARCHAR(2)  DEFAULT 'US',
    is_primary BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_addresses_customer_id ON customer_addresses(customer_id);
CREATE INDEX idx_addresses_zip_code ON customer_addresses(zip_code);

-- Customer dependents table
CREATE TABLE customer_dependents (
    id UUID PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    first_name VARCHAR(100) ,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) ,
    date_of_birth DATE ,
    gender VARCHAR(20),
    relationship VARCHAR(20) ,
    ssn_last4 VARCHAR(4),
    is_disabled BOOLEAN DEFAULT FALSE,
    is_student BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dependents_customer_id ON customer_dependents(customer_id);

-- Customer documents table
CREATE TABLE customer_documents (
    id UUID PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    document_type VARCHAR(30) ,
    document_name VARCHAR(200) ,
    file_path VARCHAR(500),
    file_size BIGINT,
    mime_type VARCHAR(100),
    status VARCHAR(20) DEFAULT 'PENDING',
    expiration_date DATE,
    verified_by VARCHAR(100),
    rejection_reason VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_documents_customer_id ON customer_documents(customer_id);
CREATE INDEX idx_documents_status ON customer_documents(status);

-- Eligibility checks table
CREATE TABLE eligibility_checks (
    id UUID PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    check_date TIMESTAMP NOT NULL,
    expiration_date TIMESTAMP,
    eligibility_reason VARCHAR(500),
    income_verified BOOLEAN NOT NULL DEFAULT FALSE,
    residence_verified BOOLEAN NOT NULL DEFAULT FALSE,
    age_verified BOOLEAN NOT NULL DEFAULT FALSE,
    checked_by VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_eligibility_customer_id ON eligibility_checks(customer_id);
CREATE INDEX idx_eligibility_plan_id ON eligibility_checks(plan_id);

-- Customer plan enrollments table
CREATE TABLE customer_plan_enrollments (
    id UUID PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL,
    plan_code VARCHAR(50) NOT NULL,
    plan_name VARCHAR(200) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    effective_date DATE NOT NULL,
    termination_date DATE,
    monthly_premium DECIMAL(10,2),
    subsidy_amount DECIMAL(10,2) DEFAULT 0,
    member_id VARCHAR(50),
    group_number VARCHAR(50),
    include_dependents BOOLEAN NOT NULL DEFAULT FALSE,
    auto_renew BOOLEAN NOT NULL DEFAULT TRUE,
    cancellation_reason VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_enrollments_customer_id ON customer_plan_enrollments(customer_id);
CREATE INDEX idx_enrollments_plan_id ON customer_plan_enrollments(plan_id);
CREATE INDEX idx_enrollments_status ON customer_plan_enrollments(status);
CREATE INDEX idx_enrollments_effective_date ON customer_plan_enrollments(effective_date);
