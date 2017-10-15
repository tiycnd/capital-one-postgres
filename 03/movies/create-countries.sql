DROP TABLE IF EXISTS countries;

CREATE TABLE countries (
  id SERIAL PRIMARY KEY,
  code VARCHAR(2) NOT NULL UNIQUE
);

INSERT INTO countries (code)
  SELECT DISTINCT(country) FROM reviewers;

ALTER TABLE reviewers
  ADD COLUMN country_id INTEGER REFERENCES countries(id);

UPDATE reviewers SET country_id = (SELECT id FROM countries WHERE countries.code = reviewers.country);

ALTER TABLE reviewers DROP COLUMN country;
