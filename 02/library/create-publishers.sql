DROP TABLE IF EXISTS publishers;

CREATE TABLE publishers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO publishers (name)
  SELECT DISTINCT(publisher) FROM books;

ALTER TABLE books
  ADD COLUMN publisher_id INTEGER REFERENCES publishers(id);

UPDATE books 
  SET publisher_id = (SELECT id FROM publishers 
                      WHERE publishers.name = books.publisher);

ALTER TABLE books
  DROP COLUMN publisher;