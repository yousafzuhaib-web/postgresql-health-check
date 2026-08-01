/*
===============================================================================
Script: unused_indexes.sql
Project: PostgreSQL Health Check Toolkit
Author: Zuhaib Yousaf Begum
Repository: https://github.com/yousafzuhaib-web/postgresql-health-check

Description:
Identifies indexes with little or no usage based on PostgreSQL statistics.

Useful for:
- Storage optimization
- Performance reviews
- Capacity planning
- Identifying candidates for manual review

Important:
- DO NOT drop indexes based solely on this report.
- Statistics are reset after:
    • pg_stat_reset()
    • Server restart
- Some indexes may only be used:
    • Monthly or yearly
    • During maintenance
    • By reporting jobs
    • To enforce constraints
- Always review execution plans before removing an index.

Compatible with:
- PostgreSQL 12+

Permissions:
- Public (statistics views)

===============================================================================
*/

SELECT
    ui.schemaname,
    ui.relname                                      AS table_name,
    ui.indexrelname                                 AS index_name,

    pg_size_pretty(
        pg_relation_size(ui.indexrelid)
    )                                               AS index_size,

    pg_relation_size(ui.indexrelid)                 AS index_size_bytes,

    ui.idx_scan,
    ui.idx_tup_read,
    ui.idx_tup_fetch,

    ut.seq_scan,
    ut.seq_tup_read,
    ut.n_live_tup,

    i.indisunique                                  AS is_unique,
    i.indisprimary                                 AS is_primary,
    i.indisexclusion                               AS is_exclusion,
    i.indisvalid                                   AS is_valid,
    i.indisready                                   AS is_ready,

    pg_get_indexdef(ui.indexrelid)                 AS index_definition

FROM pg_stat_user_indexes ui

JOIN pg_stat_user_tables ut
    ON ui.relid = ut.relid

JOIN pg_index i
    ON ui.indexrelid = i.indexrelid

WHERE ui.idx_scan = 0

    -- Never suggest primary keys
    AND i.indisprimary = FALSE

    -- Never suggest unique indexes
    AND i.indisunique = FALSE

    -- Never suggest exclusion indexes
    AND i.indisexclusion = FALSE

ORDER BY
    pg_relation_size(ui.indexrelid) DESC,
    ui.schemaname,
    ui.relname;

/*
===============================================================================
Low Usage Indexes
===============================================================================
*/

SELECT
    schemaname,
    relname AS table_name,
    indexrelname AS index_name,

    idx_scan,

    pg_size_pretty(
        pg_relation_size(indexrelid)
    ) AS index_size,

    pg_get_indexdef(indexrelid) AS index_definition

FROM pg_stat_user_indexes

WHERE idx_scan BETWEEN 1 AND 20

ORDER BY
    idx_scan,
    pg_relation_size(indexrelid) DESC;


/*
===============================================================================
Storage Consumed by Potentially Unused Indexes
===============================================================================
*/

SELECT
    COUNT(*) AS unused_indexes,

    pg_size_pretty(
        SUM(pg_relation_size(indexrelid))
    ) AS total_size,

    SUM(pg_relation_size(indexrelid)) AS total_size_bytes

FROM pg_stat_user_indexes ui

JOIN pg_index i
    ON ui.indexrelid = i.indexrelid

WHERE ui.idx_scan = 0
  AND i.indisprimary = FALSE
  AND i.indisunique = FALSE
  AND i.indisexclusion = FALSE;

