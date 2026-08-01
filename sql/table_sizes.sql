/*
===============================================================================
Script: table_sizes.sql
Project: PostgreSQL Health Check Toolkit
Author: Zuhaib Yousaf Begum
Repository: https://github.com/yousafzuhaib-web/postgresql-health-check

Description:
Reports storage usage for user tables, including table data, indexes,
TOAST storage, and total relation size.

Useful for:
- Capacity planning
- Identifying the largest tables
- Reviewing index storage overhead
- Detecting tables with large TOAST usage
- Supporting migration and maintenance planning

Important:
- This script is read-only.
- Size functions may take longer on databases with many relations.
- Partitioned parent tables may show little or no physical storage because
  the data is stored in their partitions.
- PostgreSQL size values are calculated for the current database only.

Compatible with:
- PostgreSQL 12+

Permissions:
- Public access is normally sufficient
- Additional privileges may be required to view some relation metadata

===============================================================================
*/

SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,

    pg_size_pretty(pg_relation_size(c.oid)) AS table_data_size,
    pg_relation_size(c.oid) AS table_data_size_bytes,

    pg_size_pretty(pg_indexes_size(c.oid)) AS indexes_size,
    pg_indexes_size(c.oid) AS indexes_size_bytes,

    pg_size_pretty(
        CASE
            WHEN c.reltoastrelid <> 0
                THEN pg_total_relation_size(c.reltoastrelid)
            ELSE 0
        END
    ) AS toast_size,

    CASE
        WHEN c.reltoastrelid <> 0
            THEN pg_total_relation_size(c.reltoastrelid)
        ELSE 0
    END AS toast_size_bytes,

    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size,
    pg_total_relation_size(c.oid) AS total_size_bytes,

    COALESCE(s.n_live_tup, 0) AS estimated_live_rows,
    COALESCE(s.n_dead_tup, 0) AS estimated_dead_rows,

    CASE
        WHEN COALESCE(s.n_live_tup, 0) > 0
            THEN pg_size_pretty(
                pg_relation_size(c.oid)
                / NULLIF(s.n_live_tup, 0)
            )
        ELSE NULL
    END AS estimated_average_row_size,

    ROUND(
        CASE
            WHEN pg_total_relation_size(c.oid) = 0 THEN 0
            ELSE (
                100.0 * pg_indexes_size(c.oid)
                / pg_total_relation_size(c.oid)
            )
        END,
        2
    ) AS index_percentage_of_total,

    c.relpersistence AS persistence_type,
    c.relkind AS relation_type

FROM pg_class AS c

JOIN pg_namespace AS n
    ON n.oid = c.relnamespace

LEFT JOIN pg_stat_user_tables AS s
    ON s.relid = c.oid

WHERE c.relkind IN ('r', 'm')
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
  AND n.nspname NOT LIKE 'pg_toast%'

ORDER BY
    pg_total_relation_size(c.oid) DESC,
    n.nspname,
    c.relname;


/*
===============================================================================
Top 20 Largest Tables
===============================================================================
*/

SELECT
    schemaname,
    relname AS table_name,
    pg_size_pretty(pg_relation_size(relid)) AS table_data_size,
    pg_size_pretty(pg_indexes_size(relid)) AS indexes_size,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    n_live_tup AS estimated_live_rows,
    n_dead_tup AS estimated_dead_rows

FROM pg_stat_user_tables

ORDER BY pg_total_relation_size(relid) DESC

LIMIT 20;

/*
===============================================================================
Storage Usage by Schema
===============================================================================
*/

SELECT
    n.nspname AS schema_name,
    COUNT(*) AS relation_count,
    pg_size_pretty(
        SUM(pg_relation_size(c.oid))
    ) AS table_data_size,
    pg_size_pretty(
        SUM(pg_indexes_size(c.oid))
    ) AS indexes_size,
    pg_size_pretty(
        SUM(pg_total_relation_size(c.oid))
    ) AS total_size,
    SUM(pg_total_relation_size(c.oid)) AS total_size_bytes

FROM pg_class AS c

JOIN pg_namespace AS n
    ON n.oid = c.relnamespace

WHERE c.relkind IN ('r', 'm')
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
  AND n.nspname NOT LIKE 'pg_toast%'

GROUP BY n.nspname

ORDER BY total_size_bytes DESC;

