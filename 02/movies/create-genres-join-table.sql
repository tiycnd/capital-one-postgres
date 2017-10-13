DROP TABLE IF EXISTS movie_genres;
DROP TABLE IF EXISTS genres;

CREATE TABLE genres (
  id SERIAL PRIMARY KEY, 
  name VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE movie_genres (
  movie_id INTEGER REFERENCES movies (id),
  genre_id INTEGER REFERENCES genres (id),
  PRIMARY KEY (movie_id, genre_id)
);

INSERT INTO genres (name) 
  SELECT distinct(unnest(string_to_array(genres, '|'))) AS genre 
  FROM movies;

CREATE TEMP TABLE mg AS (SELECT id AS movie_id, unnest(string_to_array(genres, '|')) AS genre_name FROM movies);

INSERT INTO movie_genres
  SELECT mg.movie_id, genres.id FROM mg INNER JOIN genres ON mg.genre_name = genres.name;

ALTER TABLE movies DROP COLUMN genres;