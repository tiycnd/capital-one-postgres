-- ALTER TABLE books
-- ALTER COLUMN checked_out_by INTEGER REFERENCES patrons(id);

CREATE OR REPLACE VIEW checked_out_books AS
SELECT b.id AS book_id, b.title AS book_title, 
p.id AS patron_id, p.name AS patron_name, 
date_trunc('day', b.checked_out_at + c.checkout_duration)::DATE AS due_date
FROM books b 
JOIN patrons p ON b.checked_out_by = p.id 
JOIN collections c ON b.collection_id = c.id; 


CREATE OR REPLACE VIEW overdue_books AS
SELECT book_id, book_title, patron_id, patron_name, due_date,
CURRENT_DATE - due_date AS days_overdue
FROM checked_out_books
WHERE due_date < CURRENT_DATE;
