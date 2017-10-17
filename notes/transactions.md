## Transactions

Imagine that reviewers got credits for creating reviews that they could later spend for free movie tickets, posters, or other memorabilia. You might have some SQL code like this:

```sql
UPDATE reviewers SET credits = credits + 1 WHERE id = 1;
INSERT INTO reviews(reviewer_id, movie_id, score) VALUES(1, 1, 4);
```

A problem arises, though -- what if the second statement fails? You don't want to give credits for an invalid review, as in this example:

```
movies=> SELECT credits FROM reviewers WHERE id = 1;
 credits 
---------
       1
(1 row)

movies=> UPDATE reviewers SET credits = credits + 1 WHERE id = 1;
UPDATE 1
movies=> INSERT INTO reviews(reviewer_id, movie_id, score) VALUES(1, 2, 6);
ERROR:  new row for relation "reviews" violates check constraint "reviews_score_check"
DETAIL:  Failing row contains (950434, 1, 2, 6).
movies=> SELECT credits FROM reviewers WHERE id = 1;
 credits 
---------
       2
(1 row)
```

In this case, we should use a _transaction_. A transaction lets us choose a point at which to save our state. From there we can make changes and either rollback those changes if we have a problem, or commit those changes if everything is good. Let's try this again with a transaction.

```
movies=> SELECT credits FROM reviewers WHERE id = 1;
 credits 
---------
       2
(1 row)

movies=> BEGIN TRANSACTION;
BEGIN
movies=> UPDATE reviewers SET credits = credits + 1 WHERE id = 1;
UPDATE 1
movies=> INSERT INTO reviews(reviewer_id, movie_id, score) VALUES(1, 2, 6);
ERROR:  new row for relation "reviews" violates check constraint "reviews_score_check"
DETAIL:  Failing row contains (950435, 1, 2, 6).
movies=> COMMIT;
ROLLBACK
movies=> SELECT credits FROM reviewers WHERE id = 1;
 credits 
---------
       2
(1 row)
```

Notice that we tried to commit our changes and they were rolled back automatically, because we'd had an error during the transaction. This will come in especially handy later with functions.