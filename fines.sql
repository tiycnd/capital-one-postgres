DROP TABLE IF EXISTS fines;
CREATE TABLE fines (
  id SERIAL PRIMARY KEY,
  patron_id INTEGER REFERENCES patrons(id) NOT NULL,
  book_id INTEGER REFERENCES books(id) NOT NULL,
  date DATE,
  amount MONEY
);

ALTER TABLE collections ADD COLUMN fine_per_day MONEY;

UPDATE collections SET fine_per_day = 0.25 WHERE id = 1;
UPDATE collections SET fine_per_day = 1.00 WHERE id = 2;

CREATE UNIQUE INDEX ON fines (patron_id, book_id, date);

-- Run nightly

INSERT INTO fines (patron_id, book_id, date, amount)
  SELECT ob.patron_id, ob.book_id, CURRENT_DATE, c.fine_per_day
  FROM overdue_books ob
  JOIN books b ON ob.book_id = b.id
  JOIN collections c ON b.collection_id = c.id;