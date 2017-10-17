CREATE OR REPLACE FUNCTION review_weight(reviewer_id INTEGER) RETURNS numeric AS $$
  SELECT POWER(1.2, COUNT(*)) FROM reviews WHERE reviewer_id = review_weight.reviewer_id
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION add_review(integer, integer, integer) 
RETURNS void AS $$
  INSERT INTO reviews (reviewer_id, movie_id, score)
  VALUES ($1, $2, $3);
  UPDATE reviewers SET credits = credits + 1
  WHERE id = $1;
$$ LANGUAGE SQL;

CREATE FUNCTION reviewers_weighted() RETURNS 
TABLE(id int, username varchar, avg_score numeric, weight numeric) AS $$
  SELECT rr.id, rr.username,
    AVG(rw.score) AS avg_score, 
    POWER(1.2, COUNT(1)) AS weight 
  FROM reviewers rr 
  JOIN reviews rw ON rr.id = rw.reviewer_id 
  GROUP BY rr.id;
$$ LANGUAGE SQL;

CREATE FUNCTION negative_movie_reviews(int) RETURNS SETOF reviews AS $$
  SELECT * FROM reviews WHERE movie_id = $1 AND score < 3
$$ LANGUAGE SQL;