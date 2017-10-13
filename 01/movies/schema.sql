DROP TABLE IF EXISTS movies CASCADE;

CREATE TABLE movies (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  genres VARCHAR(255),
  studio VARCHAR(255) NOT NULL,
  release_date DATE NOT NULL,
  budget_in_millions NUMERIC(5,2),
  revenue_in_millions NUMERIC(5,2),
  runtime_in_minutes INTEGER,
  average_critic_review NUMERIC(2,1),
  stars JSON
);