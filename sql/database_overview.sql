/*
===============================================================================
Script: database_overview.sql
Project: PostgreSQL Health Check Toolkit
Author: Zuhaib Yousaf Begum
Repository: https://github.com/yousafzuhaib-web/postgresql-health-check

Description:
Provides a high-level overview of the PostgreSQL instance,
including server version, uptime, current database,
connection statistics, database size, and recovery status.

Useful for:
- PostgreSQL Health Checks
- Production Audits
- Capacity Planning
- Environment Documentation

Compatible with:
- PostgreSQL 12+

Permissions:
- Public
===============================================================================
*/

SELECT
    current_database()                                             AS database_name,
    current_user                                                   AS current_user,
    current_setting('server_version')                              AS server_version,
    inet_server_addr()                                             AS server_ip,
    inet_server_port()                                             AS server_port,
    inet_client_addr()                                             AS client_ip,
    inet_client_port()                                             AS client_port,

    pg_postmaster_start_time()                                     AS server_start_time,

    AGE(now(), pg_postmaster_start_time())                         AS server_uptime,

    pg_database_size(current_database())                           AS database_size_bytes,

    pg_size_pretty(pg_database_size(current_database()))           AS database_size,

    (SELECT COUNT(*)
       FROM pg_stat_activity
      WHERE datname = current_database())                          AS current_connections,

    current_setting('max_connections')                             AS max_connections,

    CASE
        WHEN pg_is_in_recovery()
            THEN 'Standby'
        ELSE 'Primary'
    END                                                            AS server_role,

    current_setting('data_directory')                              AS data_directory,

    current_setting('config_file')                                 AS config_file,

    current_setting('hba_file')                                    AS pg_hba_file,

    current_setting('ident_file')                                  AS ident_file;


/*
===============================================================================
Database Statistics
===============================================================================
*/

SELECT
    datname                                        AS database_name,
    numbackends                                    AS active_connections,
    xact_commit,
    xact_rollback,
    blks_read,
    blks_hit,

    ROUND(
        CASE
            WHEN (blks_hit + blks_read) = 0 THEN 0
            ELSE (100.0 * blks_hit / (blks_hit + blks_read))
        END,
        2
    ) AS cache_hit_ratio,

    tup_returned,
    tup_fetched,
    tup_inserted,
    tup_updated,
    tup_deleted,

    pg_size_pretty(pg_database_size(datname)) AS database_size

FROM pg_stat_database

ORDER BY pg_database_size(datname) DESC;


