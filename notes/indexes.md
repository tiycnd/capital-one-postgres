## Indexes

Indexes are used to speed up querying data from the database. They operate in a similar fashion to an index in a book -- imagine a list of unique values from one or more columns, each with a set of row ids that match those values. Database indexes are more complex than this, but this mental model can help you understand them.

Indexes are automatically added when you make a column unique or when you create a foreign key.

To create more indexes, use the `CREATE INDEX` command. An example:

```sql
CREATE INDEX ON movies (average_critic_review);
```

Indexes can be created on multiple columns as well:

```sql
CREATE INDEX ON movies (budget_in_millions, revenue_in_millions);
```

Functions can be used when creating indexes. The `LOWER()` function is commonly used when you want to run case-insensitive searches on a column:

```sql
CREATE INDEX ON movies (LOWER(title));
```

Note: while indexes can speed up reading, you do not want to overuse them. Not only do they take up disk space, but they also slow down writing into the database.

### References

* ["Indexes" from the PostgreSQL documentation](https://www.postgresql.org/docs/9.6/static/indexes.html)