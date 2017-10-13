DROP TABLE IF EXISTS studios;

CREATE TABLE studios (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO studios (name)
  SELECT DISTINCT(studio) FROM movies;

ALTER TABLE movies
  ADD COLUMN studio_id INTEGER REFERENCES studios(id);

UPDATE movies SET studio_id = (SELECT id FROM studios WHERE studios.name = movies.studio);

ALTER TABLE movies
  DROP COLUMN studio;