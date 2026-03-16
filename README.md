# Cryogenic Preservation Database

SQL Server relational database design for managing cryogenic preservation operations, monitoring, auditing and incident management.

## Overview

This project models the operational processes involved in cryogenic preservation. The database supports:

- personnel and role management
- legal consent records
- cryogenic tank management
- monitoring of tanks and refrigerant levels
- operational protocols
- internal and external audits
- critical incident tracking
- preservation records
- supporting external reference data

The repository is organized to make the project easy to understand and easy to execute.

## Technologies

- SQL Server
- T-SQL
- Relational database design
- Views
- Triggers
- Foreign keys and referential integrity

## Repository Structure

- `sql/` → executable SQL scripts
- `docs/` → documentation
- `images/` → ER diagrams and supporting schema images

## Quick Start

To create the full database with sample data:

1. Open `sql/full_database_setup.sql`
2. Run the script in SQL Server

You can also execute the files in this order:

1. `sql/01_external_data_tables.sql`
2. `sql/02_database_schema.sql`
3. `sql/03_sample_data.sql`
4. `sql/04_views.sql`
5. `sql/05_triggers.sql`

## Notes

External reference data for the normalized TSE-related tables was originally based on publicly available Costa Rican electoral registry sources. This public repository includes only the database structure and sample records for demonstration purposes.


## Dataset Notice

To run the complete database workflow, the following files must be downloaded manually:

- The **complete electoral registry dataset** from the official TSE website
- The **telephone datasets** used for data integration

The files included in this repository are **small samples intended only to demonstrate the functionality of the SQL scripts and database design**.

If the full datasets are not loaded into the database before running the SQL scripts, some procedures and queries may not function as expected.

## Database Architecture

### Final ER Diagram

### Auxiliary Tables

![Auxiliary Tables](diagrams/auxiliary-tables-diagram.png)

### TSE Normalized Schema

![TSE Schema](diagrams/tse-normalized-diagram.png)

### Cryogenics System Schema

![Database Diagram](diagrams/database-diagram.png)
