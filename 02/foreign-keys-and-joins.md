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