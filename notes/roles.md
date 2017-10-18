## Roles

Roles are used in PostgreSQL to manage users and groups. Users and groups are not separate entities -- both are roles.

When you use `creategSQL function (Experimental)user` and `dropuser` on the command line, you are creating and destroying roles. There's some options with `createuser` to control access:

```
  -d, --createdb            role can create new databases
  -D, --no-createdb         role cannot create databases (default)
  -g, --role=ROLE           new role will be a member of this role
  -l, --login               role can login (default)
  -L, --no-login            role cannot login
  -P, --pwprompt            assign a password to new role
  -r, --createrole          role can create new roles
  -R, --no-createrole       role cannot create roles (default)
  -s, --superuser           role will be superuser
  -S, --no-superuser        role will not be superuser (default)
```

These command line utilities use the SQL commands `CREATE ROLE` (or `CREATE USER`) and `DROP ROLE`.

### CREATE ROLE

When you create a role, you can pass it a set of options to set its default permissions:

* `SUPERUSER | NOSUPERUSER` - A superuser can override any access restrictions in the database. NOSUPERUSER is the default.
* `CREATEDB | NOCREATEDB` - This role can create new databases. NOCREATEDB is the default.
* `CREATEROLE | NOCREATEROLE` - This role can create roles and alter and drop other roles. NOCREATEROLE is the default.
* `INHERIT | NOINHERIT` - With INHERIT (the default), this role has all the permissions of the roles it is a member of. With NOINHERIT, a user using this role has to explicitly run `SET ROLE` to access a role's permissions. This explicitly _does not_ apply to the abilities granted by `CREATE ROLE` or `ALTER ROLE`, but instead to database-level permissions.
* `LOGIN | NOLOGIN` - This role can log in. NOLOGIN is the default except if you create a role with `CREATE USER`.
* `PASSWORD 'password'` - Set a password for this role. This does not make sense if the role cannot log in.
* `VALID UNTIL 'timestamp'` - Set a timestamp after which the password for this role is no longer valid.
* `IN ROLE role_name [, ...]` - Set the roles this role is a member of.
* `ROLE role_name [, ...]` - Add the listed roles as members of this role.
* `ADMIN role_name [, ...]` - Add the listed roles as members of this role and grant them the ability to add other roles to this role.

### GRANT

`GRANT` is used to add permissions on database entities like tables, views, and functions.

The role that created an entity has all privileges on it by default.

For tables, the permissions that can be granted are:

* SELECT
* INSERT
* UPDATE
* DELETE
* TRUNCATE
* REFERENCES (can create a foreign key referencing the table)

These can be granted on specific columns or on the entire table.

```sql
GRANT SELECT ON TABLE students TO kelly;
GRANT UPDATE (cohort, graduated) ON TABLE students TO kelly;
```

`REVOKE ... FROM ...` is the opposite of `GRANT ... TO ...`.

`GRANT` can have `WITH GRANT OPTION` at the end of it to give the role the ability to grant the same permissions to other roles.

### GRANT role TO role

`GRANT` can also be used to add a role to a group role. In this case, `WITH ADMIN OPTION` is the suffix to allow that role to add others to the group.

### Example: Read only role

```sql
CREATE USER kelly WITH PASSWORD 'kelly1';
CREATE ROLE readonly_group;
GRANT CONNECT ON DATABASE test TO readonly_group;
GRANT USAGE ON SCHEMA public TO readonly_group;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_group;
GRANT readonly_group TO kelly;
```

### Library example

Our roles will be patron, librarian, buyer, and admin. These are group roles that others can be added to.

```sql
CREATE ROLE users;
GRANT CONNECT ON DATABASE library TO users;
GRANT USAGE ON SCHEMA public TO users;

GRANT SELECT ON TABLE 
books, publishers, book_authors, authors, book_subjects, subjects, collections
TO users;

--

CREATE ROLE patrons WITH IN ROLE users;

--

CREATE ROLE librarians WITH IN ROLE users ADMIN patrons;

GRANT SELECT ON TABLE
fines, checked_out_books, overdue_books, checkouts
TO librarians;

GRANT EXECUTE ON FUNCTION checkout_book TO librarians;
GRANT EXECUTE ON FUNCTION checkin_book TO librarians;

GRANT UPDATE (available_for_checkout, collection_id) 
ON TABLE books
TO librarians;

--

CREATE ROLE buyers IN ROLE users;

GRANT INSERT ON TABLE 
books, publishers, book_subjects, book_authors, subjects, authors
TO buyers;

--

CREATE ROLE admins WITH IN ROLE users ADMIN buyers, librarians, patrons;
GRANT ALL ON ALL TABLES IN SCHEMA public TO admins;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO admins;
```