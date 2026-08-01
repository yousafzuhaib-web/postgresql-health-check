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


/* Only show active sessions */

SELECT
    pid,
    usename,
    datname,
    application_name,
    client_addr,
    state,

    ROUND(
        EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - query_start)),
        2
    ) AS running_seconds,

    wait_event_type,
    wait_event,

    LEFT(query, 500) AS query

FROM pg_stat_activity

WHERE state = 'active'
    AND pid <> pg_backend_pid()

ORDER BY running_seconds DESC;

/* Highlight long-running queries (>5 minutes) */

SELECT
    pid,
    usename,
    datname,
    application_name,

    AGE(CURRENT_TIMESTAMP, query_start) AS duration,

    state,

    LEFT(query, 500) AS query

FROM pg_stat_activity

WHERE query_start IS NOT NULL
    AND CURRENT_TIMESTAMP - query_start > INTERVAL '5 minutes'
    AND pid <> pg_backend_pid()

ORDER BY duration DESC;





