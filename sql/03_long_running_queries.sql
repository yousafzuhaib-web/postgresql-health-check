/*
===============================================================================
Script: long_running_queries.sql
Project: PostgreSQL Health Check Toolkit
Author: Zuhaib Yousaf Begum
Repository: https://github.com/yousafzuhaib-web/postgresql-health-check

Description:
Identifies PostgreSQL sessions running longer than a configurable threshold.

Useful for:
- Detecting long-running SQL statements
- Identifying sessions consuming resources for extended periods
- Investigating blocking, waits, and transaction duration
- Reviewing application connection behavior
- Supporting production incident analysis

Important:
- The default threshold is 5 minutes.
- Long runtime does not automatically mean a query is problematic.
- Always review workload context, execution plans, wait events, and blockers
  before cancelling or terminating a session.
- This script is read-only.

Compatible with:
- PostgreSQL 12+

Permissions:
- pg_monitor is recommended
- Superuser privileges may be required to see full query text for all users

===============================================================================
*/

WITH parameters AS (
    SELECT INTERVAL '5 minutes' AS minimum_duration
)
SELECT
    a.pid,
    a.datname                                              AS database_name,
    a.usename                                              AS username,
    a.application_name,
    a.client_addr,
    a.client_hostname,
    a.client_port,

    a.backend_start,
    a.xact_start,
    a.query_start,
    a.state_change,

    CLOCK_TIMESTAMP() - a.query_start                      AS query_duration,
    ROUND(
        EXTRACT(EPOCH FROM (CLOCK_TIMESTAMP() - a.query_start)),
        2
    )                                                      AS query_duration_seconds,

    CASE
        WHEN a.xact_start IS NOT NULL
            THEN CLOCK_TIMESTAMP() - a.xact_start
        ELSE NULL
    END                                                    AS transaction_duration,

    a.state,
    a.wait_event_type,
    a.wait_event,

    ARRAY_LENGTH(pg_blocking_pids(a.pid), 1)               AS blocker_count,
    pg_blocking_pids(a.pid)                                AS blocking_pids,

    LEFT(a.query, 2000)                                    AS query_text

FROM pg_stat_activity AS a
CROSS JOIN parameters AS p

WHERE a.pid <> pg_backend_pid()
  AND a.query_start IS NOT NULL
  AND a.state <> 'idle'
  AND CLOCK_TIMESTAMP() - a.query_start >= p.minimum_duration

ORDER BY
    query_duration DESC,
    a.pid;

/*
You can change the threshold here:

SELECT INTERVAL '5 minutes' AS minimum_duration

For example:

SELECT INTERVAL '30 seconds' AS minimum_duration

or:

SELECT INTERVAL '15 minutes' AS minimum_duration
*/
