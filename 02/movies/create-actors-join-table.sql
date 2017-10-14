DROP TABLE IF EXISTS movie_actors;
DROP TABLE IF EXISTS actors;

CREATE TABLE actors (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE movie_actors (
  movie_id INTEGER REFERENCES movies(id),
  actor_id INTEGER REFERENCES actors(id),
  PRIMARY KEY (movie_id, actor_id)
);

INSERT INTO actors (name)
  SELECT DISTINCT(json_array_elements(stars) ->> 'name') AS name
  FROM movies;

CREATE TEMP TABLE ma AS (SELECT id AS movie_id, json_array_elements(stars) ->> 'name' AS actor_name FROM movies);

INSERT INTO movie_actors
  SELECT ma.movie_id, actors.id FROM ma INNER JOIN actors ON ma.actor_name = actors.name;

ALTER TABLE movies
  DROP COLUMN stars;