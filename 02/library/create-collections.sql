DROP TABLE IF EXISTS collections;

CREATE TABLE collections (
  id INTEGER PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  checkout_duration INTERVAL DAY NOT NULL
);

INSERT INTO collections (id, name, checkout_duration)
VALUES
(1, 'Standard', '14 days'),
(2, 'Special', '5 days');

ALTER TABLE books
ADD COLUMN collection_id INTEGER REFERENCES collections(id);

UPDATE books SET collection_id = 1;
UPDATE books SET collection_id = 2 
WHERE id IN (SELECT id FROM books ORDER BY RANDOM() LIMIT 50);
