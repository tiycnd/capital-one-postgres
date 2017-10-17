.PHONY: library-01 library-02 movies-01 movies-02 movies-03

library-01:
	psql library < 01/library/books-schema.sql
	pgloader 01/library/books.load

library-02: library-01
	cat 02/library/create-*.sql | psql library
	psql -q library < 02/library/patrons.sql

movies:
	dropdb movies
	createdb movies
	psql movies < movies.sql

movies-schema-only:
	dropdb movies
	createdb movies
	psql movies < movies-schema-only.sql
