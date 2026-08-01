/*
===============================================================================
Script: configuration_review.sql
Project: PostgreSQL Health Check Toolkit
Author: Zuhaib Yousaf Begum
Repository: postgresql-health-check

Description:
Reviews the most important PostgreSQL configuration parameters
related to memory, WAL, checkpoints, autovacuum, logging,
replication, parallelism, and connections.

Useful for:
- Health Checks
- Performance Reviews
- Capacity Planning
- PostgreSQL Best Practices
- Production Audits

Compatible with:
- PostgreSQL 12+

Permissions:
- Public (pg_settings)

===============================================================================
*/

SELECT
    name,
    setting,
    unit,
    boot_val,
    reset_val,
    source,
    short_desc
FROM pg_settings
WHERE name IN (

-- Connections
'max_connections',
'superuser_reserved_connections',

-- Memory
'shared_buffers',
'effective_cache_size',
'work_mem',
'maintenance_work_mem',
'autovacuum_work_mem',
'temp_buffers',
'huge_pages',

-- WAL
'wal_level',
'wal_buffers',
'wal_compression',
'wal_keep_size',
'max_wal_size',
'min_wal_size',

-- Checkpoints
'checkpoint_timeout',
'checkpoint_completion_target',

-- Replication
'max_wal_senders',
'max_replication_slots',
'hot_standby',

-- Autovacuum
'autovacuum',
'autovacuum_max_workers',
'autovacuum_naptime',
'autovacuum_vacuum_scale_factor',
'autovacuum_analyze_scale_factor',
'autovacuum_vacuum_cost_limit',

-- Query Planner
'default_statistics_target',
'random_page_cost',
'effective_io_concurrency',

-- Parallelism
'max_worker_processes',
'max_parallel_workers',
'max_parallel_workers_per_gather',

-- Logging
'logging_collector',
'log_min_duration_statement',
'log_checkpoints',
'log_connections',
'log_disconnections',
'log_lock_waits',

-- Timeouts
'statement_timeout',
'idle_in_transaction_session_timeout',
'lock_timeout',

-- Extensions
'shared_preload_libraries'

)
ORDER BY name;
