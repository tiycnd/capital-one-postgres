-- an ISBN
-- a title
-- a publisher
-- a year of publication
-- one or more authors (store in one column for now)
-- one or more subjects (store in one column for now)
-- a Dewey Decimal code (may be null)
-- a number of pages

CREATE TABLE publishers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE books (
  id SERIAL PRIMARY KEY,
  isbn VARCHAR(13) NOT NULL UNIQUE,
  publisher_id INTEGER NOT NULL REFERENCES publishers(id),
  year_of_publication INTEGER NOT NULL,
  dewey_decimal_code NUMERIC(6,3),
  number_of_pages INTEGER NOT NULL
);

CREATE TABLE authors (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE author_books (
  author_id INTEGER REFERENCES authors(id),
  book_id INTEGER REFERENCES books(id),
  PRIMARY KEY (author_id, book_id)
);

CREATE TABLE subjects (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE book_subjects (
  book_id INTEGER REFERENCES books(id),
  subject_id INTEGER REFERENCES subjects(id),
  PRIMARY KEY (book_id, subject_id)
);
