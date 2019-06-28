DROP TABLE IF EXISTS books CASCADE;

CREATE TABLE books (
  id SERIAL PRIMARY KEY,
  isbn VARCHAR(13) NOT NULL,
  title VARCHAR(500) NOT NULL,
  author VARCHAR(500),
  year_published INTEGER NOT NULL,
  publisher VARCHAR(200),
  dewey_decimal NUMERIC(6,3),
  lcc_number VARCHAR(20),
  subjects TEXT,
  available_for_check_out BOOLEAN DEFAULT true NOT NULL,
  checked_out_at TIMESTAMP,
  checked_out_by VARCHAR(20)
);
       
