CREATE OR REPLACE FUNCTION review_weight(reviewer_id INTEGER) RETURNS numeric AS $$
  SELECT POWER(1.2, COUNT(*)) FROM reviews WHERE reviewer_id = review_weight.reviewer_id
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION add_review(integer, integer, integer) RETURNS void AS $$
  INSERT INTO reviews (reviewer_id, movie_id, score)
  VALUES ($1, $2, $3);
  UPDATE reviewers SET credits = credits + 1
  WHERE id = $1;
$$ LANGUAGE SQL;