
1. Declarative means you specify what you want, and the RDBMS figures out how to process the request. 
2. DDL, DML, DCL
3. Refers to a collection of data or to a particular database product. SQL, Microsoft Access, Oracle DB2.
4. True, false, null(either item DNE, or exists but value unk).
5. Entity integrity is that every record in a table(set, relation) must be unique. It is enforced using primary keys.
6. Referential integrity is enforced by a foreign key that points to the reference table.
7. Table
8. Not in 1NF, because the facCreds column is not atomic(indivisable). Fix by making 3 tables. Every cell must contain an atomic expression.
9. No, because 2NF means 1NF plus every non-key column depends on the entire primary key. 
10. No, because the City and State columns depend on the Zip Code column. Fix this by creating another table with Zip Code as PK, City, and State.
11. Server name, DB name, schema, object name.
12. Declarative=enforced by the table definitions or constraints, Procedural=enforced with code