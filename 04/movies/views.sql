DROP MATERIALIZED VIEW IF EXISTS movie_scores;
DROP VIEW IF EXISTS reviewers_weighted;

CREATE VIEW reviewers_weighted AS 
  SELECT rr.id, rr.username,
    AVG(rw.score) AS avg_score, 
    POWER(1.2, COUNT(rw.score)) AS weight 
  FROM reviewers rr 
  JOIN reviews rw ON rr.id = rw.reviewer_id 
  GROUP BY rr.id;

CREATE MATERIALIZED VIEW movie_scores AS 
  SELECT rw.movie_id, 
    ROUND(AVG(rw.score),2) AS avg_score, 
    ROUND(SUM(rw.score * rrw.weight) / SUM(rrw.weight), 2) AS weighted_score 
  FROM reviews rw 
  JOIN reviewers_weighted rrw ON rw.reviewer_id = rrw.id 
  GROUP BY rw.movie_id;
