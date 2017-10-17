## Creating tables

### The `CREATE TABLE` command

The `CREATE TABLE` command is used to make new database tables. An example:

This example shows the syntax for `CREATE TABLE`.

```sql
CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE,
  graduated BOOLEAN NOT NULL DEFAULT 'f',
  cohort INTEGER NOT NULL,
  resume TEXT,
  financial_aid NUMERIC(7,2),
  enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

`CREATE TABLE` takes two arguments: the name of the table and a list of columns. Each column has a name, data type, and options. The columns in the above example explained:

* `id SERIAL PRIMARY KEY`: The `id` column is of type `SERIAL`, which is an integer that is automatically incremented and set when a row is inserted. The option `PRIMARY KEY` says that we will use this column as a unique identifier for each row. This requires that the column is both unique and not nullable.
* `name VARCHAR(100) NOT NULL`: The `name` column is a string with a maximum length of 100 characters. It cannot have a null value.
* `email VARCHAR(100) UNIQUE`: The `email` column is a string with a maximum length of 100 characters. It _can_ be null, but if it has a value, it must be a unique value.
* `graduated BOOLEAN NOT NULL DEFAULT 'f'`: The `graduated` column is a true/false value. It cannot be null, but if you insert a row and do not set the value, it will automatically be set to false.
* `cohort INTEGER NOT NULL`: The `cohort` column is an integer value and cannot be null.
* `resume TEXT`: The `resume` column stores strings of arbitrary length. It can be null.
* `financial_aid NUMERIC(7,2)`: The `financial_aid_per_year` column is a decimal value with precision (total number of digits) of 7 and scale (digits right of the decimal point) of 2. It can be null.
* `enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP`: The `enrolled_at` column is a date and time value and cannot be null. If not specified, the current date and time are used.

There are more datatypes for columns, including complex ones that can hold multiple values. Some of the common simple ones are:

* REAL (floating point number)
* DATE
* TIME
* INTERVAL (amount of time)

### Deleting tables

To delete a table, use `DROP TABLE <tablename>`. If you want PostgreSQL to not throw an error if the table does not exist -- this is a nice thing to put at the top of a schema definition file -- use `DROP TABLE IF EXISTS <tablename>`.

### References

* ["Data Definition" from the PostgreSQL manual](https://www.postgresql.org/docs/9.6/static/ddl.html)
* ["Data Types" from the PostgreSQL manual](https://www.postgresql.org/docs/9.6/static/datatype.html)
* [`CREATE TABLE` syntax](https://www.postgresql.org/docs/9.6/static/sql-createtable.html)
* [`DROP TABLE` syntax](https://www.postgresql.org/docs/9.6/static/sql-droptable.html)
