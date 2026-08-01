/*
===============================================================================
Script: index_usage.sql
Project: PostgreSQL Health Check Toolkit
Author: Zuhaib Yousaf Begum
Repository: https://github.com/yousafzuhaib-web/postgresql-health-check

Description:
Reviews index usage statistics for user tables and indexes.

Useful for:
- Identifying heavily used indexes
- Detecting indexes with little or no usage
- Reviewing index-to-table scan patterns
- Supporting performance and capacity assessments
- Finding potential candidates for further investigation

Important:
- Statistics are cumulative since the last statistics reset or server restart.
- A low scan count does not automatically mean an index should be dropped.
- Constraint-backed indexes, recently created indexes, seasonal workloads,
  and write-heavy tables require additional analysis.

Compatible with:
- PostgreSQL 12+

Permissions:
- Public access to PostgreSQL statistics views
- pg_monitor is recommended for broader monitoring access

===============================================================================
*/

SELECT
    s.schemaname,
    s.relname                                                AS table_name,
    s.indexrelname                                           AS index_name,

    pg_size_pretty(pg_relation_size(s.indexrelid))           AS index_size,
    pg_relation_size(s.indexrelid)                           AS index_size_bytes,

    s.idx_scan,
    s.idx_tup_read,
    s.idx_tup_fetch,

    t.seq_scan,
    t.seq_tup_read,

    CASE
        WHEN (COALESCE(t.seq_scan, 0) + COALESCE(s.idx_scan, 0)) = 0
            THEN 0
        ELSE ROUND(
            100.0 * s.idx_scan
            / NULLIF(t.seq_scan + s.idx_scan, 0),
            2
        )
    END                                                      AS index_scan_percentage,

    i.indisunique                                            AS is_unique,
    i.indisprimary                                           AS is_primary_key,
    i.indisvalid                                             AS is_valid,
    i.indisready                                             AS is_ready,

    pg_get_indexdef(s.indexrelid)                            AS index_definition

FROM pg_stat_user_indexes AS s

JOIN pg_stat_user_tables AS t
    ON t.relid = s.relid

JOIN pg_index AS i
    ON i.indexrelid = s.indexrelid

ORDER BY
    s.idx_scan DESC,
    pg_relation_size(s.indexrelid) DESC;


/*
===============================================================================
Potentially Unused Indexes

Review carefully before dropping any index.
===============================================================================
*/

SELECT
    s.schemaname,
    s.relname                                      AS table_name,
    s.indexrelname                                 AS index_name,
    pg_size_pretty(pg_relation_size(s.indexrelid)) AS index_size,
    s.idx_scan,
    i.indisunique                                  AS is_unique,
    i.indisprimary                                 AS is_primary_key,
    pg_get_indexdef(s.indexrelid)                  AS index_definition

FROM pg_stat_user_indexes AS s

JOIN pg_index AS i
    ON i.indexrelid = s.indexrelid

WHERE s.idx_scan = 0
  AND i.indisprimary = FALSE
  AND i.indisunique = FALSE

ORDER BY
    pg_relation_size(s.indexrelid) DESC;

/*
===============================================================================
Tables with High Sequential Scan Activity
===============================================================================
*/

SELECT
    schemaname,
    relname                                           AS table_name,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    pg_size_pretty(pg_total_relation_size(relid))     AS total_table_size,

    CASE
        WHEN (COALESCE(seq_scan, 0) + COALESCE(idx_scan, 0)) = 0
            THEN 0
        ELSE ROUND(
            100.0 * seq_scan
            / NULLIF(seq_scan + idx_scan, 0),
            2
        )
    END                                               AS sequential_scan_percentage

FROM pg_stat_user_tables

ORDER BY
    seq_scan DESC,
    pg_total_relation_size(relid) DESC;

