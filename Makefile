.PHONY: library-01 library-02 movies-01 movies-02

library-01:
	psql library < 01/library/books-schema.sql
	pgloader 01/library/books.load

library-02: library-01
	cat 02/library/*.sql | psql library

movies-01:
	psql movies < 01/movies/schema.sql
	psql movies < 01/movies/movies.sql

movies-02: movies-01
	cat 02/movies/*.sql | psql movies
