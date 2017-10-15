CREATE FUNCTION review_weight(reviewer_id INTEGER) RETURNS numeric AS $$
  SELECT POWER(1.2, COUNT(*)) FROM reviews WHERE reviewer_id = review_weight.reviewer_id
$$ LANGUAGE SQL;
