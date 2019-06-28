DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS authors;

CREATE TABLE authors (
  id SERIAL PRIMARY KEY, 
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE book_authors (
  book_id INTEGER REFERENCES books (id),
  author_id INTEGER REFERENCES authors (id),
  PRIMARY KEY (book_id, author_id)
);

INSERT INTO authors (name) 
  SELECT distinct(unnest(string_to_array(author, '|'))) AS author 
  FROM books;

CREATE TEMP TABLE ba AS (SELECT id AS book_id, unnest(string_to_array(author, '|')) AS author_name FROM books);

INSERT INTO book_authors
  SELECT ba.book_id, authors.id FROM ba INNER JOIN authors ON ba.author_name = authors.name;

ALTER TABLE books DROP COLUMN author;