-- =============================================================================
-- Initialize PostgreSQL Databases for All Components
-- =============================================================================

-- =====================
-- Microservices
-- =====================

-- Plans Service
CREATE DATABASE plans_db;
CREATE USER plans_user WITH ENCRYPTED PASSWORD 'plans_password';
GRANT ALL PRIVILEGES ON DATABASE plans_db TO plans_user;

-- Customer Onboarding Service
CREATE DATABASE customer_db;
CREATE USER customer_user WITH ENCRYPTED PASSWORD 'customer_password';
GRANT ALL PRIVILEGES ON DATABASE customer_db TO customer_user;

-- Order Service
CREATE DATABASE order_db;
CREATE USER order_user WITH ENCRYPTED PASSWORD 'order_password';
GRANT ALL PRIVILEGES ON DATABASE order_db TO order_user;

-- AI Gateway Service
CREATE DATABASE ai_gateway_db;
CREATE USER ai_gateway_user WITH ENCRYPTED PASSWORD 'ai_gateway_password';
GRANT ALL PRIVILEGES ON DATABASE ai_gateway_db TO ai_gateway_user;

-- =====================
-- ETL / Airflow
-- =====================
CREATE DATABASE airflow_db;
CREATE USER airflow_user WITH ENCRYPTED PASSWORD 'airflow_password';
GRANT ALL PRIVILEGES ON DATABASE airflow_db TO airflow_user;

-- =====================
-- ML / MLflow
-- =====================
CREATE DATABASE mlflow_db;
CREATE USER mlflow_user WITH ENCRYPTED PASSWORD 'mlflow_password';
GRANT ALL PRIVILEGES ON DATABASE mlflow_db TO mlflow_user;

-- =====================
-- Grant schema permissions
-- =====================
\c plans_db
GRANT ALL ON SCHEMA public TO plans_user;

\c customer_db
GRANT ALL ON SCHEMA public TO customer_user;

\c order_db
GRANT ALL ON SCHEMA public TO order_user;

\c ai_gateway_db
GRANT ALL ON SCHEMA public TO ai_gateway_user;

\c airflow_db
GRANT ALL ON SCHEMA public TO airflow_user;

\c mlflow_db
GRANT ALL ON SCHEMA public TO mlflow_user;