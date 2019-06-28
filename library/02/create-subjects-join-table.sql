DROP TABLE IF EXISTS book_subjects;
DROP TABLE IF EXISTS subjects;

CREATE TABLE subjects (
  id SERIAL PRIMARY KEY, 
  name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE book_subjects (
  book_id INTEGER REFERENCES books (id),
  subject_id INTEGER REFERENCES subjects (id),
  PRIMARY KEY (book_id, subject_id)
);

INSERT INTO subjects (name) 
  SELECT distinct(unnest(string_to_array(subjects, '|'))) AS subject 
  FROM books;

CREATE TEMP TABLE bs AS (SELECT id AS book_id, unnest(string_to_array(subjects, '|')) AS subject_name FROM books);

INSERT INTO book_subjects
  SELECT bs.book_id, subjects.id FROM bs INNER JOIN subjects ON bs.subject_name = subjects.name;

ALTER TABLE books DROP COLUMN subjects;