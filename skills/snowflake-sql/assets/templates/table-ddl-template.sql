-- Snowflake Table DDL Template
-- Purpose: Standard template for creating tables with full metadata

CREATE OR REPLACE TABLE {database}.{schema}.{table_name} (
    -- Primary Key / Identifiers
    {id_column} NUMBER COMMENT '{description of primary key, source system}',

    -- Business Columns
    {business_column_1} {data_type} COMMENT '{column purpose, transformations, valid values}',
    {business_column_2} {data_type} COMMENT '{column purpose, transformations, valid values}',

    -- Audit Columns (standard for all tables)
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Record creation timestamp (UTC)',
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Last update timestamp (UTC)',
    created_by VARCHAR(100) DEFAULT CURRENT_USER() COMMENT 'User who created the record',

    -- Constraints (optional)
    CONSTRAINT pk_{table_name} PRIMARY KEY ({id_column})

) COMMENT = '{High-level table purpose. Data source. Refresh cadence. Owning team.}';

-- Clustering (for tables >1TB with predictable query patterns)
-- ALTER TABLE {database}.{schema}.{table_name} CLUSTER BY ({clustering_columns});

-- Security Grants (least-privilege)
-- GRANT SELECT ON TABLE {database}.{schema}.{table_name} TO ROLE {role_name};

-- Example Usage:
-- CREATE OR REPLACE TABLE analytics.fan_data.fact_user_engagement (
--     user_id NUMBER COMMENT 'Unique user identifier (source: dim_users.user_id)',
--     event_date DATE COMMENT 'Date of engagement event in UTC',
--     engagement_score FLOAT COMMENT 'Calculated engagement score 0-100 (algorithm v2.1)',
--     created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Record creation timestamp',
--     updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP() COMMENT 'Last update timestamp',
--     created_by VARCHAR(100) DEFAULT CURRENT_USER() COMMENT 'User who created record',
--     CONSTRAINT pk_fact_user_engagement PRIMARY KEY (user_id, event_date)
-- ) COMMENT = 'Daily user engagement metrics for Fan Data Value Stream. Refreshed nightly via dbt. Owned by [Data Product Lead].';
