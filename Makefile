.PHONY: library-01 library-02 movies-01 movies-02 movies-03

library-01:
	psql library < 01/library/books-schema.sql
	pgloader 01/library/books.load

library-02: library-01
	cat 02/library/create-*.sql | psql library
	psql -q library < 02/library/patrons.sql

movies-01:
	psql movies < 01/movies/schema.sql
	psql movies < 01/movies/movies.sql

movies-02: movies-01
	cat 02/movies/*.sql | psql movies

movies-03: movies-02
	psql movies < 03/movies/create-reviewers.sql
	psql movies < 03/movies/reviewers.sql
	psql movies < 03/movies/create-countries.sql
	psql movies < 03/movies/views.sql
