## Views

Views can be used to give commonly-used queries a name and treat them like a table. They are not faster than their base queries by default, but can make writing SQL based off these queries easier.

Imagine you wish to weight the review scores of reviewers by how many reviews they have made on an exponential curve.

To get the weight of each reviewer, your SQL would look like:

```sql
SELECT rr.id, POWER(1.2, COUNT(rw.score)) AS weight 
FROM reviewers rr 
JOIN reviews rw ON rr.id = rw.reviewer_id 
GROUP BY rr.id;
```

Putting all of that into your SQL every time you wanted to get the weighted average review of a movie would be complicated. Instead, you could make a view you could later reference:

```sql
CREATE OR REPLACE VIEW reviewers_weighted AS 
  SELECT rr.id, rr.username,
    AVG(rw.score) AS avg_score, 
    POWER(1.2, COUNT(rw.score)) AS weight 
  FROM reviewers rr 
  JOIN reviews rw ON rr.id = rw.reviewer_id 
  GROUP BY rr.id;

SELECT * FROM reviewers_weight LIMIT 5;
 id |  username  |     avg_score      |        weight        
----+------------+--------------------+----------------------
  1 | gmcandie0  | 2.9333333333333333 | 237.3763137997698063
  2 | cmathivat1 | 3.3125000000000000 | 341.8218918716685211
  3 | mbarber2   | 3.7931034482758621 | 197.8135948331415053
  4 | rinstock3  | 2.7727272727272727 |  55.2061438912436418
  5 | lthebeau4  | 3.0869565217391304 |  66.2473726694923701

```

Now we can use that view to calculate weighted scores for movies.

```sql
SELECT rw.movie_id,
  ROUND(AVG(rw.score), 2) AS avg_score, 
  ROUND(SUM(rw.score * rrw.weight) / SUM(rrw.weight), 2) AS weighted_score 
FROM reviews rw 
JOIN reviewers_weighted rrw ON rw.reviewer_id = rrw.id 
GROUP BY rw.movie_id 
LIMIT 5;

--  movie_id | avg_score | weighted_score 
-- ----------+-----------+----------------
--       251 |      2.94 |           3.01
--       106 |      3.02 |           2.93
--       120 |      2.99 |           3.26
--       285 |      3.04 |           3.01
--       681 |      3.03 |           3.52
```

### Materialized views

This view makes writing the above SQL easier, but it doesn't make it any faster. Calculating weighted scores for movies is slow, and more indexes will not help. We can use a _materialized view_ to speed this up. A materialized view works like a view, but the results are stored for later retrieval. This means they will not change as the underlying data changes. It works a bit differently from a table, though, in that we can tell it to refresh without having to remember or enter the SQL definition for the view.

```sql
CREATE MATERIALIZED VIEW movie_scores AS 
  SELECT rw.movie_id, 
    ROUND(AVG(rw.score),2) AS avg_score, 
    ROUND(SUM(rw.score * rrw.weight) / SUM(rrw.weight), 2) AS weighted_score 
  FROM reviews rw 
  JOIN reviewers_weighted rrw ON rw.reviewer_id = rrw.id 
  GROUP BY rw.movie_id;
```

To update this materialized view, run:

```sql
UPDATE MATERIALIZED VIEW movie_scores;
```

For a table like this that may not need to have real-time updated data, this can be a great idea.

