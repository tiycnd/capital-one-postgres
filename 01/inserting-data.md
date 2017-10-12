## Inserting data

### The `INSERT INTO` command

The `INSERT INTO` command adds rows to an existing database table. Some examples:

```sql
INSERT INTO students (name, email, graduated, cohort) VALUES ('Charlie', 'charlie@example.org', 't', 1);
INSERT INTO students (name, email, cohort) VALUES ('Harper', 'harper@example.org', 12);
INSERT INTO students (name, cohort, financial_aid)
VALUES
('Kelly', 12, 1000),
('Alexis', 12, 1500.50);
```

The `INSERT INTO` command takes a table name, a set of columns, the keyword `VALUES`, and one or more sets of values to insert into the specified set of columns. You can forgo the set of columns if your values contain values for every column, in the order they exist in the table.

### Other ways to insert data

If you have bulk data in a text or CSV file, you can add it using the `COPY` command, the `\copy` directive in the PostgreSQL shell, or a third-party tool like [pgloader](http://pgloader.io/) or [pgAdmin 3](https://www.pgadmin.org/). You can also insert data from most programming languages.

### References

* ["Inserting data" from the PostgreSQL manual](https://www.postgresql.org/docs/9.6/static/dml-insert.html)
* [`INSERT INTO` syntax](https://www.postgresql.org/docs/9.6/static/sql-insert.html)
* [`COPY` syntax](https://www.postgresql.org/docs/9.6/static/sql-copy.html)