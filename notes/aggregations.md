## Aggregations and Functions

SQL provides functions and clauses for us to manipulate our result set from `SELECT` statements. Some of the most common functions are used for aggregations.

### COUNT

`COUNT()` is used to get a count of rows. In its simplest form, we use it to find out how many rows are in a table.

```sql
SELECT COUNT(*) FROM movies;
```

### GROUP BY

`COUNT()` becomes much more powerful with the `GROUP BY` clause. This allows us to split our result set by one of more columns before aggregating. We can use it to get a count of the records with one or more columns in common. Note that we _cannot_ use an unaggregated column in our `SELECT` statement without putting it in the `GROUP BY` clause.

```sql
-- Number of movies by studio
SELECT studio, COUNT(*) AS count
FROM movies
GROUP BY studio
ORDER BY count DESC;
```

### SUM, AVG, MIN, and MAX

`SUM()`, `AVG()`, `MIN()`, and `MAX()` aggregate a particular column and return a result.

```sql
-- Average movie run length
SELECT AVG(runtime_in_minutes) FROM movies;

-- Average movie budget by studio
SELECT studio, AVG(budget_in_millions) AS avg_budget
FROM movies
GROUP BY studio
ORDER BY avg_budget DESC;

-- Average profit by studio
SELECT studio, AVG(revenue_in_millions - budget_in_millions) AS avg_profit
FROM movies
GROUP BY studio
ORDER BY avg_profit DESC;
```

### ROUND

`ROUND()` is an example of a SQL function that does not aggregate, but works on each value in a column.

```sql
-- Average profit by studio
SELECT studio, 
  ROUND(AVG(revenue_in_millions - budget_in_millions), 3) AS avg_profit
FROM movies
GROUP BY studio
ORDER BY avg_profit DESC;
```

### EXTRACT

`EXTRACT()` is another SQL function that does not aggregate. It works on timestamp, date, time, and interval values and can pull out subfields from those values, letting you get, for example, the year or day of week from a date value.

```sql
-- Average profit by year
SELECT EXTRACT(year FROM release_date) AS year,
  ROUND(AVG(revenue_in_millions - budget_in_millions), 3) AS avg_profit
FROM movies
GROUP BY year
ORDER BY year;
```
### References

* [Functions and Operators](https://www.postgresql.org/docs/9.6/static/functions.html)
* [Aggregate Functions](https://www.postgresql.org/docs/9.6/static/functions-aggregate.html)
* [Date/Time Functions](https://www.postgresql.org/docs/9.6/static/functions-datetime.html)