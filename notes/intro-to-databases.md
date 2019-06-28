## Databases, tables, rows, and columns

### Terminology

* _database management system_: the server process that holds databases, like
  PostgreSQL or Microsoft SQL Server
* _database_: a storage area for data collected into tables.
* _table_: a named collection of records, all with the same structure defined
  by columns.
* _row_: a record in a table that represents all the data that takes to
  describe the entity stored in the table.
* _column_: a field in a table that all records will have. Columns have a name
  and a type.
* _primary key_: a unique id that identifies a single row in a table. This
  will usually be an auto-incrementing number called `id`, although that is
  not a requirement of the database.
* _SQL_: Structured Query Language. A _declarative_ programming language for
  defining databases and extracting and manipulating information from them.
  
### Installing PostgreSQL

If you are using Homebrew, run:

```
brew install postgresql
brew services start postgresql
```

Alternatively, use [Postgres.app](https://postgresapp.com/).


### Connecting to PostgreSQL

Before we connect to PostgreSQL, we need a user and a database. Creating a user will vary based on your operating system, and your installation procedure may have set it up for you. If your username is `user`, then the commands would be:

```
createuser -d user
```

To create a database, run:

```
createdb <database-name>
```

To start, make a database called `test`.

To connect to PostgreSQL, run `psql <database-name>`. You should see a prompt like this:

```
psql (9.6.5, server 9.5.6)
Type "help" for help.

test=> 
```

To exit, type `\q`.
