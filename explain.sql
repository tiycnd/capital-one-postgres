CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  system_id INTEGER NOT NULL,
  name VARCHAR(100) NOT NULL,
  priority INTEGER NOT NULL,
  key VARCHAR(20) NOT NULL
);

--  2113004341 | 2115504046

EXPLAIN SELECT * FROM users;

ANALYZE users;
EXPLAIN ANALYZE SELECT * FROM users;

-- Why is there a difference in rows?
EXPLAIN SELECT * FROM users WHERE system_id > 2113006000;
EXPLAIN ANALYZE SELECT * FROM users WHERE system_id > 2113006000;

-- Why does one use the index and the other doesn't?
CREATE INDEX ON users (system_id);
EXPLAIN SELECT * FROM users WHERE system_id > 2113006000;
EXPLAIN SELECT * FROM users WHERE system_id > 2115000000;

EXPLAIN ANALYZE SELECT * FROM users WHERE system_id > 2115000000 AND key LIKE 'Q%';
EXPLAIN ANALYZE SELECT * FROM users WHERE key LIKE 'Q%';

-- Why doesn't the index work?
CREATE INDEX ON users (key);
EXPLAIN ANALYZE SELECT * FROM users WHERE key LIKE 'Q%';

-- LIKE won't index unless you specify the operator type
CREATE INDEX ON users (key varchar_pattern_ops);
EXPLAIN ANALYZE SELECT * FROM users WHERE key LIKE 'Q%';

-- Let's try ILIKE
EXPLAIN ANALYZE SELECT * FROM users WHERE key ILIKE 'Q%';

-- How to index for ILIKE?
CREATE INDEX ON users (LOWER(key) varchar_pattern_ops);
-- Nope
EXPLAIN ANALYZE SELECT * FROM users WHERE key ILIKE 'Q%';
-- Yes
EXPLAIN ANALYZE SELECT * FROM users WHERE LOWER(key) LIKE 'q%';

-- Covering indexes
EXPLAIN SELECT system_id FROM users WHERE system_id > 2115000000;

/*
Sequential Scan
  - read all the table in sequential order
Index Scan
  - read the index to filter on the WHERE clause
  - and the table to filter the “invisible” rows
Bitmap Index Scan
  - the same
  - but read fully the index, and then the table
  - much quicker for a bigger number of rows
Index Only Scan
  - for covering index
*/

-- Sorting
DROP INDEX users_system_id_idx;
EXPLAIN ANALYZE SELECT * FROM users ORDER BY system_id;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users ORDER BY system_id;

SET work_mem TO '200MB';
EXPLAIN ANALYZE SELECT * FROM users ORDER BY system_id;

CREATE INDEX ON users (system_id);
EXPLAIN ANALYZE SELECT * FROM users ORDER BY system_id;
SET work_mem TO '4MB';

-- Create a table for join
CREATE TABLE flags (
  system_id INTEGER NOT NULL, 
  active BOOLEAN NOT NULL, 
  admin BOOLEAN NOT NULL DEFAULT 'f'
);

INSERT INTO flags
  SELECT system_id, system_id % 2 = 0, system_id % 12 = 0 FROM users;

ANALYZE flags;

EXPLAIN ANALYZE SELECT * FROM users JOIN flags ON users.system_id = flags.system_id;

CREATE INDEX ON flags(system_id);
EXPLAIN ANALYZE SELECT * FROM users JOIN flags ON users.system_id = flags.system_id;

-- Aggregates
EXPLAIN SELECT COUNT(*) FROM users;

DROP INDEX users_system_id_idx;

EXPLAIN SELECT MAX(system_id) FROM users;
CREATE INDEX ON users (system_id);
EXPLAIN SELECT MAX(system_id) FROM users;

EXPLAIN ANALYZE SELECT priority, COUNT(*) FROM users GROUP BY priority;

SET work_mem TO '200MB';
EXPLAIN ANALYZE SELECT priority, COUNT(*) FROM users GROUP BY priority;
