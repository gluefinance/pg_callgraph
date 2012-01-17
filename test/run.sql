\c postgres

DROP DATABASE test;

CREATE DATABASE test;

\c test

-- Create sequences:
\i 1-sequences.sql

-- Create tables:
\i 2-tables.sql

-- Create functions:
\i 3-functions.sql

-- Call functions:
\i 4-calls.sql
