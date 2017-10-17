## Foreign Keys and Joins

When we think about data, we find relationships naturally forming out of that data. Some examples:

- A publisher has many books
- A studio has many movies
- A person has one or more email addresses
- A book has one or more authors
- An author has one or more books
- A movie has one or more actors
- An actor has one or more movies
- A student has many classes
- A class has many students

We can use a relational database like PostgreSQL to store these relationships in multiple tables.

### What is a foreign key?

A _foreign key_ is used to connect tables to form these relationships. Here is a simplified table structure for movies and studios:

```sql
CREATE TABLE studios (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE movies (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  studio_id INTEGER NOT NULL REFERENCES studios(id)
);
```

The `movies` table has a column, `studio_id`, that references the `id` column from `studios`. Each entry in the `studio_id` column should be an id from the `studios` table. We say that a movie _belongs to_ a studio or _has one_ studio, while a studio _has many_ movies.

When you have a relationship like actors and movies -- a movie has many actors; an actor has many movies -- you use a _join table_.

```sql
CREATE TABLE actors (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE movies (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL
);

CREATE TABLE movie_actors (
  movie_id INTEGER NOT NULL REFERENCES movies(id),
  actor_id INTEGER NOT NULL REFERENCES actors(id)
);
```

We say that an actor _has and belongs to many_ movies, or a movie _has and belongs to many actors_.

### Joins

To connect tables, we use the `JOIN` clause with `SELECT` statements. Let's see an example:

```sql
SELECT movies.title, studios.name AS studio
FROM movies
JOIN studios ON movies.studio_id = studios.id;
```

```
-[ RECORD 1 ]-------------------------------------------------------------------------------------------------------
title  | Visions of Europe
studio | Megascreen Filmworks
-[ RECORD 2 ]-------------------------------------------------------------------------------------------------------
title  | Spring is Here
studio | Megascreen Filmworks
-[ RECORD 3 ]-------------------------------------------------------------------------------------------------------
title  | 10th & Wolf
studio | Jast Studios
```

There's a lot to unpack in this one statement. First, see the `AS` clause after `studios.name`. We can use `AS` in several contexts to give a new name to a value. Then, look at the `JOIN` clause. We state a table we want to join to our table from our `FROM` clause, and then use `ON` to specify the condition on which it should be joined.

This style of join is called an _inner join_. With an inner join, only rows that have a match on both sides of the `ON` clause are displayed. If we had movies with no `studio_id`, they would not appear, and if a movie had a `studio_id` that did not have an `id` in the `studios` table, that row would also not appear. This is often what we want, but not always.

Imagine we have movies that might not have a studio, but we want them to show up anyway in our list. First, let's see a query with an inner join:

```sql
UPDATE movies SET studio_id = NULL WHERE id = 183;

SELECT movies.id, movies.title, studios.name AS studio
FROM movies
JOIN studios ON movies.studio_id = studios.id
LIMIT 2;

-- -[ RECORD 1 ]----------------
-- id     | 49
-- title  | Visions of Europe
-- studio | Megascreen Filmworks
-- -[ RECORD 2 ]----------------
-- id     | 474
-- title  | 10th & Wolf
-- studio | Jast Studios
```

Now, let's use a _left join_, where all rows on the left side of our join show up:

```sql
SELECT movies.id, movies.title, studios.name AS studio
FROM movies
LEFT JOIN studios ON movies.studio_id = studios.id
LIMIT 2;

-- -[ RECORD 1 ]----------------
-- id     | 49
-- title  | Visions of Europe
-- studio | Megascreen Filmworks
-- -[ RECORD 2 ]----------------
-- id     | 183
-- title  | Spring is Here
-- studio | 
```

`RIGHT JOIN` and `FULL JOIN` also exist, allowing for all rows on the right side of the join, or all rows on both sides of the join respectively.

### Why design databases this way?

Database theory is outside of the scope of this class, but you should read up on database normalization for more info.

### References

* [A Visual Representation of SQL Joins](https://www.codeproject.com/Articles/33052/Visual-Representation-of-SQL-Joins)
* ["Joins Between Tables" from the PostgreSQL documentation](https://www.postgresql.org/docs/9.6/static/tutorial-join.html)
* [An introduction to database normalization](http://phlonx.com/resources/nf3/)