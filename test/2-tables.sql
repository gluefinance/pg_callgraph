CREATE TABLE users (
user_id integer not null default nextval('seq_users'),
name text not null,
password text not null,
PRIMARY KEY (user_id),
UNIQUE(name)
);

CREATE TABLE accounts (
account_id integer not null default nextval('seq_accounts'),
user_id integer not null,
balance numeric not null default 0,
currency char(3) not null,
PRIMARY KEY (account_id),
UNIQUE(user_id,currency),
FOREIGN KEY (user_id) REFERENCES users(user_id),
CHECK(currency ~ '^[A-Z]{3}$')
);

CREATE TABLE transactions (
transaction_id integer not null default nextval('seq_transactions'),
user_id integer not null,
account_id integer not null,
amount numeric not null,
balance numeric not null,
PRIMARY KEY (transaction_id),
FOREIGN KEY (user_id) REFERENCES users(user_id),
FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
