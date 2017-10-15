DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS reviewers CASCADE;

CREATE TABLE reviewers (
  id SERIAL PRIMARY KEY,
  username VARCHAR(30) NOT NULL UNIQUE,
  birthdate DATE NOT NULL,
  country VARCHAR(2) NOT NULL
);

CREATE TABLE reviews (
  id SERIAL PRIMARY KEY,
  reviewer_id INTEGER NOT NULL REFERENCES reviewers(id),
  movie_id INTEGER NOT NULL REFERENCES movies(id),
  score INTEGER NOT NULL,
  CHECK (score >= 1 AND score <= 5)
);