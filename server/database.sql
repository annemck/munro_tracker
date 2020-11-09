CREATE DATABASE munro_tracker;

CREATE TABLE users(
  user_id SERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  second_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  uk_date_format CHAR(1) DEFAULT 'Y',
  show_name CHAR(1) DEFAULT 'Y',
  photo BYTEA
);

CREATE TABLE friends(
  user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
  friend_ids INTEGER[]
);

CREATE TABLE climbed_munros(
  user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
  munro_smcid CHAR(4) NOT NULL UNIQUE,
  date_climbed DATE DEFAULT current_date,
  friends_ids INTEGER[],
  other_friends TEXT[]
);

CREATE EXTENSION pgcrypto;

CREATE OR REPLACE FUNCTION fn_secure_password()
RETURNS trigger AS '
  BEGIN
    new.password := crypt(new.password, gen_salt(''bf''));
    RETURN NEW;
  END'
LANGUAGE 'plpgsql';

CREATE TRIGGER tg_secure_password BEFORE INSERT OR UPDATE OF password
ON users
FOR EACH ROW
EXECUTE PROCEDURE fn_secure_password();

INSERT INTO users (first_name, second_name, email, password)
VALUES ('Test', 'User', 'fake@email.fake', 'password');
