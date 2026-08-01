/*
===============================================================================
Script: replication_status.sql
Project: PostgreSQL Health Check Toolkit
Author: Zuhaib Yousaf Begum
Repository: https://github.com/yousafzuhaib-web/postgresql-health-check

Description:
Reviews physical and logical replication status in PostgreSQL.

Useful for:
- Identifying the current server role
- Monitoring physical streaming replication
- Measuring WAL lag on primary and standby servers
- Reviewing replication slots
- Monitoring logical replication subscriptions
- Supporting HA and disaster recovery health checks

Important:
- This script is read-only.
- Some sections return no rows when the relevant replication feature
  is not configured.
- WAL lag values are estimates based on the current WAL positions.
- pg_monitor is recommended for monitoring access.

Compatible with:
- PostgreSQL 12+

===============================================================================
*/

\echo '==============================================================================='
\echo '1. SERVER ROLE AND WAL POSITION'
\echo '==============================================================================='

SELECT
    current_database() AS database_name,
    CASE
        WHEN pg_is_in_recovery() THEN 'STANDBY'
        ELSE 'PRIMARY'
    END AS server_role,
    pg_is_in_recovery() AS is_in_recovery,
    CASE
        WHEN pg_is_in_recovery()
            THEN pg_last_wal_receive_lsn()
        ELSE pg_current_wal_lsn()
    END AS current_or_received_lsn,
    CASE
        WHEN pg_is_in_recovery()
            THEN pg_last_wal_replay_lsn()
        ELSE NULL
    END AS replay_lsn,
    CASE
        WHEN pg_is_in_recovery()
            THEN pg_last_xact_replay_timestamp()
        ELSE NULL
    END AS last_replayed_transaction,
    CASE
        WHEN pg_is_in_recovery()
         AND pg_last_xact_replay_timestamp() IS NOT NULL
            THEN clock_timestamp() - pg_last_xact_replay_timestamp()
        ELSE NULL
    END AS replay_time_delay;


\echo '==============================================================================='
\echo '2. PHYSICAL STREAMING REPLICATION - PRIMARY VIEW'
\echo '==============================================================================='

SELECT
    pid,
    usesysid,
    usename AS replication_user,
    application_name,
    client_addr,
    client_hostname,
    client_port,
    backend_start,
    backend_xmin,
    state,
    sent_lsn,
    write_lsn,
    flush_lsn,
    replay_lsn,

    pg_size_pretty(
        pg_wal_lsn_diff(pg_current_wal_lsn(), sent_lsn)
    ) AS sent_lag_bytes,

    pg_size_pretty(
        pg_wal_lsn_diff(pg_current_wal_lsn(), write_lsn)
    ) AS write_lag_bytes,

    pg_size_pretty(
        pg_wal_lsn_diff(pg_current_wal_lsn(), flush_lsn)
    ) AS flush_lag_bytes,

    pg_size_pretty(
        pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)
    ) AS replay_lag_bytes,

    write_lag,
    flush_lag,
    replay_lag,
    sync_priority,
    sync_state,
    reply_time

FROM pg_stat_replication

ORDER BY
    application_name,
    client_addr;


\echo '==============================================================================='
\echo '3. WAL RECEIVER STATUS - STANDBY VIEW'
\echo '==============================================================================='

SELECT
    pid,
    status,
    receive_start_lsn,
    receive_start_tli,
    written_lsn,
    flushed_lsn,
    received_tli,
    last_msg_send_time,
    last_msg_receipt_time,
    latest_end_lsn,
    latest_end_time,
    slot_name,
    sender_host,
    sender_port,
    conninfo

FROM pg_stat_wal_receiver;


\echo '==============================================================================='
\echo '4. STANDBY RECEIVE AND REPLAY LAG'
\echo '==============================================================================='

SELECT
    pg_last_wal_receive_lsn() AS received_lsn,
    pg_last_wal_replay_lsn() AS replayed_lsn,

    CASE
        WHEN pg_last_wal_receive_lsn() IS NOT NULL
         AND pg_last_wal_replay_lsn() IS NOT NULL
            THEN pg_size_pretty(
                pg_wal_lsn_diff(
                    pg_last_wal_receive_lsn(),
                    pg_last_wal_replay_lsn()
                )
            )
        ELSE NULL
    END AS receive_replay_lag,

    pg_last_xact_replay_timestamp() AS last_replay_timestamp,

    CASE
        WHEN pg_last_xact_replay_timestamp() IS NOT NULL
            THEN clock_timestamp() - pg_last_xact_replay_timestamp()
        ELSE NULL
    END AS replay_time_delay

WHERE pg_is_in_recovery();


\echo '==============================================================================='
\echo '5. REPLICATION SLOTS'
\echo '==============================================================================='

SELECT
    slot_name,
    plugin,
    slot_type,
    datoid,
    database,
    temporary,
    active,
    active_pid,
    xmin,
    catalog_xmin,
    restart_lsn,
    confirmed_flush_lsn,
    wal_status,
    safe_wal_size,

    CASE
        WHEN restart_lsn IS NOT NULL
            THEN pg_size_pretty(
                pg_wal_lsn_diff(
                    pg_current_wal_lsn(),
                    restart_lsn
                )
            )
        ELSE NULL
    END AS retained_wal,

    inactive_since,
    conflicting

FROM pg_replication_slots

ORDER BY
    active DESC,
    slot_type,
    slot_name;


\echo '==============================================================================='
\echo '6. LOGICAL REPLICATION SUBSCRIPTIONS'
\echo '==============================================================================='

SELECT
    subid,
    subname,
    pid,
    leader_pid,
    relid,
    received_lsn,
    last_msg_send_time,
    last_msg_receipt_time,
    latest_end_lsn,
    latest_end_time

FROM pg_stat_subscription

ORDER BY
    subname,
    relid NULLS FIRST;


\echo '==============================================================================='
\echo '7. LOGICAL REPLICATION WORKER ERRORS'
\echo '==============================================================================='

SELECT
    subname,
    apply_error_count,
    sync_error_count,
    stats_reset

FROM pg_stat_subscription_stats

ORDER BY
    apply_error_count DESC,
    sync_error_count DESC,
    subname;


\echo '==============================================================================='
\echo '8. REPLICATION-RELATED CONFIGURATION'
\echo '==============================================================================='

SELECT
    name,
    setting,
    unit,
    source,
    pending_restart,
    short_desc

FROM pg_settings

WHERE name IN (
    'wal_level',
    'max_wal_senders',
    'max_replication_slots',
    'wal_keep_size',
    'max_slot_wal_keep_size',
    'hot_standby',
    'hot_standby_feedback',
    'synchronous_commit',
    'synchronous_standby_names',
    'primary_conninfo',
    'primary_slot_name',
    'wal_receiver_status_interval',
    'wal_sender_timeout',
    'wal_receiver_timeout'
)

ORDER BY name;
