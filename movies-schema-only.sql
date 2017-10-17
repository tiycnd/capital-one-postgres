DROP TABLE IF EXISTS movies CASCADE;
DROP TABLE IF EXISTS studios CASCADE;
DROP TABLE IF EXISTS movie_genres CASCADE;
DROP TABLE IF EXISTS genres CASCADE;
DROP TABLE IF EXISTS movie_actors CASCADE;
DROP TABLE IF EXISTS actors CASCADE;
DROP TABLE IF EXISTS reviewers CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;

CREATE TABLE studios (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE movies (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  studio_id INTEGER NOT NULL REFERENCES studios(id),
  release_date DATE NOT NULL,
  budget_in_millions NUMERIC(5,2),
  revenue_in_millions NUMERIC(5,2),
  runtime_in_minutes INTEGER,
  average_critic_review NUMERIC(2,1)
);

CREATE TABLE genres (
  id SERIAL PRIMARY KEY, 
  name VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE movie_genres (
  movie_id INTEGER REFERENCES movies (id),
  genre_id INTEGER REFERENCES genres (id),
  PRIMARY KEY (movie_id, genre_id)
);

CREATE TABLE actors (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE movie_actors (
  movie_id INTEGER REFERENCES movies(id),
  actor_id INTEGER REFERENCES actors(id),
  PRIMARY KEY (movie_id, actor_id)
);

CREATE TABLE reviewers (
  id SERIAL PRIMARY KEY,
  username VARCHAR(30) NOT NULL UNIQUE,
  birthdate DATE NOT NULL,
  credits INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE reviews (
  id SERIAL PRIMARY KEY,
  reviewer_id INTEGER NOT NULL REFERENCES reviewers(id),
  movie_id INTEGER NOT NULL REFERENCES movies(id),
  score INTEGER NOT NULL,
  UNIQUE (reviewer_id, movie_id),
  CHECK (score >= 1 AND score <= 5)
);

-- Functions

DROP FUNCTION reviewer_weight (int) CASCADE;
DROP FUNCTION add_review (int, int, int) CASCADE;

CREATE FUNCTION reviewer_weight(reviewer_id int) 
RETURNS numeric AS $$
  SELECT POWER(1.2, COUNT(*)) 
  FROM reviews 
  WHERE reviewer_id = reviewer_weight.reviewer_id
$$ LANGUAGE SQL;

CREATE FUNCTION add_review(integer, integer, integer) 
RETURNS void AS $$
  INSERT INTO reviews (reviewer_id, movie_id, score)
  VALUES ($1, $2, $3);
  UPDATE reviewers SET credits = credits + 1
  WHERE id = $1;
$$ LANGUAGE SQL;

-- Views

DROP MATERIALIZED VIEW IF EXISTS movie_scores CASCADE;
DROP VIEW IF EXISTS reviewers_weighted CASCADE;

CREATE VIEW reviewers_weighted AS 
  SELECT rr.id, rr.username,
    reviewer_weight(rr.id) AS weight 
  FROM reviewers rr;

CREATE MATERIALIZED VIEW movie_scores AS 
  SELECT rw.movie_id, 
    ROUND(AVG(rw.score),2) AS avg_score, 
    ROUND(SUM(rw.score * rrw.weight) / SUM(rrw.weight), 2) AS weighted_score 
  FROM reviews rw 
  JOIN reviewers_weighted rrw ON rw.reviewer_id = rrw.id 
  GROUP BY rw.movie_id;