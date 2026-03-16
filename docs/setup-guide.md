# Setup Guide

This guide explains how to run the database project locally.

The database integrates information from multiple datasets including the Costa Rican electoral registry and phone datasets.



# 1. Requirements

Before running the project you need:

- Microsoft SQL Server
- SQL Server Management Studio (SSMS) or another SQL client
- The datasets required by the project



# 2. Download Required Datasets

Some datasets are not fully included in this repository due to their size.

You must download the original datasets before running the SQL scripts.

Required datasets:

| Dataset | Description |
|------|------|
| PADRON_COMPLETO | Electoral registry dataset from the TSE |
| distelec | Electoral district reference table |
| phones1 | Telephone dataset part 1 |
| phones2 | Telephone dataset part 2 |
| phones3 | Telephone dataset part 3 |
| phones4 | Telephone dataset part 4 |

The repository includes **reduced sample files** only for demonstration purposes.



# 3. Import the CSV files into SQL Server

Import each CSV file into SQL Server as a table.

Recommended table names:

| CSV File | Table Name |
|------|------|
| PADRON_COMPLETO_sample.csv | PADRON_COMPLETO |
| distelec.csv | distelec |
| phones1_sample.csv | phones1 |
| phones2_sample.csv | phones2 |
| phones3_sample.csv | phones3 |
| phones4_sample.csv | phones4 |

You can import the files using the **SQL Server Import Wizard**.



# 4. Create the Database

Create a new database in SQL Server:

```sql
CREATE DATABASE DB_G3CrioPF;
