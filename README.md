This is my project for learning [DBT](https://www.getdbt.com/).

It covers the following DBT concepts:
- Models
- Materializations
- Seeds
- Sources
- Snapshots
- Tests
- Macros
- Custom Tests
- Custom Packages
- Documentation
- Analysis
- Hooks
- Exposures
- CI workflow

## Setup Snowflake
```
USE ROLE ACCOUNTADMIN; -- you need accountadmin for user creation, future grants

DROP USER IF EXISTS DBT_CLOUD;
DROP USER IF EXISTS DBT_CLOUD_DEV;
DROP ROLE IF EXISTS TRANSFORMER;
DROP ROLE IF EXISTS TRANSFORMER_DEV;
DROP DATABASE IF EXISTS PROD CASCADE;
DROP DATABASE IF EXISTS DEV CASCADE;
DROP WAREHOUSE IF EXISTS TRANSFORMING;
DROP WAREHOUSE IF EXISTS TRANSFORMING_DEV;

-- creating a warehouse
CREATE WAREHOUSE TRANSFORMING WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 300 AUTO_RESUME = TRUE COMMENT = 'Warehouse to transform data';

-- creating database
CREATE DATABASE PROD COMMENT = 'production data base';

-- creating schemas
CREATE SCHEMA "PROD"."RAW" COMMENT = 'landing zone for raw data';
CREATE SCHEMA "PROD"."ANALYTICS" COMMENT = 'data layer for end user';

-- creating an access role
CREATE ROLE TRANSFORMER COMMENT = 'Role for dbt';

-- granting role permissions
GRANT USAGE,OPERATE ON WAREHOUSE TRANSFORMING TO ROLE TRANSFORMER;
GRANT USAGE,CREATE SCHEMA ON DATABASE PROD TO ROLE TRANSFORMER;
GRANT USAGE ON SCHEMA "PROD"."RAW" TO ROLE TRANSFORMER;
GRANT ALL ON SCHEMA "PROD"."ANALYTICS" TO ROLE TRANSFORMER;
GRANT SELECT ON ALL TABLES IN SCHEMA "PROD"."RAW" TO ROLE TRANSFORMER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA "PROD"."RAW" TO ROLE TRANSFORMER;

-- creating user and associating with role
CREATE USER DBT_CLOUD PASSWORD='abc123' DEFAULT_ROLE = TRANSFORMER;
GRANT ROLE TRANSFORMER TO USER DBT_CLOUD;

-- Loading data

-- Create our three tables and import the data from S3
CREATE OR REPLACE TABLE prod.raw.raw_listings (
    id integer,
    listing_url string, 
    name string,
    room_type string, 
    minimum_nights integer, 
    host_id integer,
    price string,
    created_at datetime,
    updated_at datetime
);
COPY INTO prod.raw.raw_listings (
    id
    , listing_url,
    name,
    room_type,
    minimum_nights,
    host_id,
    price,
    created_at,
    updated_at)
    from 's3://dbtlearn/listings.csv' 
    FILE_FORMAT = (type = 'CSV' skip_header = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');
    
CREATE OR REPLACE TABLE prod.raw.raw_reviews (
    listing_id integer,
    date datetime, 
    reviewer_name string, 
    comments string, 
    sentiment string
);

COPY INTO prod.raw.raw_reviews (
    listing_id
    , date
    , reviewer_name
    , comments
    , sentiment
) from 's3://dbtlearn/reviews.csv'
    FILE_FORMAT = (type = 'CSV' skip_header = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');
CREATE OR REPLACE TABLE raw.raw_hosts (id integer,
                     name string,
                     is_superhost string,
                     created_at datetime,
                     updated_at datetime);
COPY INTO prod.raw.raw_hosts (id, name, is_superhost, created_at, updated_at) from 's3://dbtlearn/hosts.csv'
                    FILE_FORMAT = (type = 'CSV' skip_header = 1
                    FIELD_OPTIONALLY_ENCLOSED_BY = '"');


-----------------------------------------------------------------------------------------------
-- DEV
-- creating a warehouse
CREATE WAREHOUSE TRANSFORMING_DEV WITH WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD' AUTO_SUSPEND = 300 AUTO_RESUME = TRUE COMMENT = 'Dev warehouse to transform data';

-- cloning prod database (this clones schemas and tables as well)
CREATE OR REPLACE DATABASE DEV CLONE PROD;

-- creating an access role
CREATE ROLE TRANSFORMER_DEV COMMENT = 'Dev role for dbt';

-- granting role permissions
GRANT USAGE,OPERATE ON WAREHOUSE TRANSFORMING_DEV TO ROLE TRANSFORMER_DEV;
GRANT USAGE,CREATE SCHEMA ON DATABASE DEV TO ROLE TRANSFORMER_DEV;
GRANT USAGE ON SCHEMA "DEV"."RAW" TO ROLE TRANSFORMER_DEV;
GRANT ALL ON SCHEMA "DEV"."ANALYTICS" TO ROLE TRANSFORMER_DEV;
GRANT SELECT ON ALL TABLES IN SCHEMA "DEV"."RAW" TO ROLE TRANSFORMER_DEV;
GRANT SELECT ON FUTURE TABLES IN SCHEMA "DEV"."RAW" TO ROLE TRANSFORMER_DEV;

-- creating user and associating with role
CREATE USER DBT_CLOUD_DEV PASSWORD='abc123' DEFAULT_ROLE = TRANSFORMER_DEV;
GRANT ROLE TRANSFORMER_DEV TO USER DBT_CLOUD_DEV;
```


## Resources
- [getdbt.com](https://www.getdbt.com/)
- Udemy course: [The Complete dbt (Data Build Tool) Bootcamp: Zero to Hero](https://www.udemy.com/course/complete-dbt-data-build-tool-bootcamp-zero-to-hero-learn-dbt/)
- Article: [How to set up a dbt data-ops workflow, using dbt cloud and Snowflake](https://www.startdataengineering.com/post/cicd-dbt/#snowflake)
