# PostgreSQL Health Check Toolkit

Production-ready SQL scripts for PostgreSQL health checks, performance analysis, replication monitoring, capacity planning, and troubleshooting.

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12--18-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![SQL](https://img.shields.io/badge/Language-SQL-orange)
![Status](https://img.shields.io/badge/Status-Active-success)

## Features

- ✅ PostgreSQL 12–18 compatible
- ✅ Read-only queries
- ✅ Production-safe
- ✅ Open Source
- ✅ Well documented
- ✅ Enterprise-ready

---

## Scripts

|           Script            |                    Description                    |
|-----------------------------|---------------------------------------------------|
| `database_overview.sql`     | General information about the PostgreSQL instance |
| `active_sessions.sql`       | Lists current database sessions                   |
| `long_running_queries.sql`  | Identifies long-running SQL statements            |
| `table_sizes.sql`           | Displays table and index storage usage            |
| `index_usage.sql`           | Reviews index utilization statistics              |
| `unused_indexes.sql`        | Identifies candidate unused indexes               |
| `dead_tuples.sql`           | Reviews dead tuples and autovacuum activity       |
| `replication_status.sql`    | Monitors physical and logical replication         |
| `configuration_review.sql`  | Reviews key PostgreSQL configuration settings     |

---

## Health Checks Included

- Database overview
- Active sessions
- Long-running queries
- Table and database sizes
- Index usage analysis
- Unused index detection
- Dead tuple analysis
- Replication monitoring
- Configuration review

---

## Use Cases

This toolkit can be used for:

- Production Health Checks
- PostgreSQL Performance Reviews
- Capacity Planning
- Cloud Migration Assessments
- High Availability Validation
- Preventive Maintenance
- PostgreSQL Audits

---

## Requirements

- PostgreSQL 12 or later
- Read access to PostgreSQL system catalogs and statistics views
- `pg_monitor` role recommended for complete visibility

---

## Getting Started

Clone the repository:

```bash
git clone https://github.com/yousafzuhaib-web/postgresql-health-check.git
```

Navigate to the SQL directory:

```bash
cd postgresql-health-check/sql
```

Run any script using psql:

```bash
psql -d your_database -f database_overview.sql
```

---

## Repository Structure

```text
postgresql-health-check/
│
├── LICENSE
├── README.md
├── docs/
│   └── sample-report.md
│
└── sql/
    ├── active_sessions.sql
    ├── configuration_review.sql
    ├── database_overview.sql
    ├── dead_tuples.sql
    ├── index_usage.sql
    ├── long_running_queries.sql
    ├── replication_status.sql
    ├── table_sizes.sql
    └── unused_indexes.sql
```

---

## Roadmap

Future additions include:

- Blocking Queries
- Lock Monitoring
- Table Bloat Analysis
- Index Bloat Analysis
- Cache Hit Ratio
- WAL Statistics
- Backup Validation
- Tablespace Usage
- Role & Security Audit
- pg_stat_statements Analysis

---

## Contributing

Contributions, issues, and feature requests are welcome.

If you have ideas for additional health check scripts or improvements, feel free to open an issue or submit a pull request.

---

## Disclaimer

These scripts are provided for diagnostic purposes only.

Always review the output before making changes to production systems. Test maintenance operations in a non-production environment whenever possible.

---

## Author

**Zuhaib Yousaf Begum**

PostgreSQL Consultant | High Availability | Performance Tuning | AWS & Azure

- LinkedIn: https://www.linkedin.com/in/zuhaib-yousaf-begum-6417b289
- GitHub: https://github.com/yousafzuhaib-web
