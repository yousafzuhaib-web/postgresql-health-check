/*
===============================================================================
Script: active_sessions.sql
Project: PostgreSQL Health Check Toolkit
Author: Zuhaib Yousaf Begum
Repository: postgresql-health-check

Description:
Displays all active PostgreSQL sessions with execution time, state,
client information, wait events, and the SQL statement currently running.

Useful for:
- Identifying long-running queries
- Detecting blocked or idle sessions
- Troubleshooting application connections
- Monitoring production environments

Compatible with:
- PostgreSQL 12+

Required permissions:
- pg_monitor role (recommended)
- Superuser (to see all sessions)

===============================================================================
*/

SELECT
    pid,
    usename AS username,
    datname AS database_name,
    application_name,
    client_addr,
    client_hostname,
    client_port,
    backend_start,
    xact_start,
    query_start,
    state_change,

    ROUND(
        EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - query_start)),
        2
    ) AS query_duration_seconds,

    state,
    wait_event_type,
    wait_event,

    LEFT(query, 500) AS current_query

FROM pg_stat_activity

ORDER BY
    query_start NULLS LAST;
