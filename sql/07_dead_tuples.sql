/*
===============================================================================
Script: dead_tuples.sql
Project: PostgreSQL Health Check Toolkit
Author: Zuhaib Yousaf Begum
Repository: https://github.com/yousafzuhaib-web/postgresql-health-check

Description:
Identifies tables with dead tuples and estimates table bloat risk.

Useful for:
- PostgreSQL Health Checks
- VACUUM Analysis
- Autovacuum Tuning
- Performance Reviews
- Capacity Planning

Compatible with:
- PostgreSQL 12+

Permissions:
- Public (pg_stat_user_tables)

References:
- https://www.postgresql.org/docs/current/monitoring-stats.html

===============================================================================
*/

SELECT
    schemaname,
    relname AS table_name,

    n_live_tup AS live_rows,
    n_dead_tup AS dead_rows,

    ROUND(
        CASE
            WHEN n_live_tup = 0 THEN 0
            ELSE (100.0 * n_dead_tup) / (n_live_tup + n_dead_tup)
        END,
        2
    ) AS dead_tuple_percentage,

    last_vacuum,
    last_autovacuum,

    last_analyze,
    last_autoanalyze,

    vacuum_count,
    autovacuum_count,

    analyze_count,
    autoanalyze_count

FROM pg_stat_user_tables

ORDER BY
    n_dead_tup DESC,
    dead_tuple_percentage DESC;


/*
===============================================================================
Tables Requiring Attention
===============================================================================
*/

SELECT
    schemaname,
    relname,

    n_live_tup,
    n_dead_tup,

    ROUND(
        (100.0 * n_dead_tup) /
        NULLIF((n_live_tup + n_dead_tup),0),
        2
    ) AS dead_percentage

FROM pg_stat_user_tables

WHERE n_dead_tup > 10000

ORDER BY dead_percentage DESC;


/*
===============================================================================
Tables Never Vacuumed
===============================================================================
*/

SELECT
    schemaname,
    relname,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum

FROM pg_stat_user_tables

WHERE last_vacuum IS NULL
  AND last_autovacuum IS NULL

ORDER BY n_dead_tup DESC;

/*
Interpretation Guide

| Dead Tuple % | Status      | Recommendation                                                         |
| ------------ | ----------- | ---------------------------------------------------------------------- |
| **< 5%**     | ✅ Healthy   | No action required                                                     |
| **5–10%**    | 🟡 Monitor  | Review autovacuum activity                                             |
| **10–20%**   | 🟠 Warning  | Investigate workload and VACUUM frequency                              |
| **> 20%**    | 🔴 Critical | Review autovacuum configuration; consider manual VACUUM if appropriate |

Note: A high number of dead tuples does not automatically mean manual intervention is required. PostgreSQL's autovacuum process is designed to clean dead tuples automatically. 
Always evaluate dead tuples together with factors such as table size, workload, autovacuum activity, and query performance before deciding on maintenance actions.

*/

