SELECT name FROM subjects WHERE book_id = 5;

SELECT string_agg(replace(name, '_', ' '), ' ') 
FROM subjects s 
JOIN book_subjects bs ON s.id = bs.subject_id 
WHERE book_id = 5;


SELECT to_tsvector(b.title || ' ' || string_agg(replace(name, '_', ' '), ' ')) AS vector 
FROM subjects s 
JOIN book_subjects bs ON s.id = bs.subject_id 
JOIN books b ON bs.book_id = b.id
GROUP BY b.title
LIMIT 10UPDATE reviewers SET credits = credits + 1 WHERE id = 1;
;

CREATE VIEW book_fulltext AS
SELECT b.id, b.title,
to_tsvector(b.title || ' ' || string_agg(replace(name, '_', ' '), ' ')) AS fulltext 
FROM subjects s 
JOIN book_subjects bs ON s.id = bs.subject_id 
JOIN books b ON bs.book_id = b.id
GROUP BY b.id, b.title
;

