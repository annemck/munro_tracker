CREATE DATABASE munro_tracker;

/**/
/*TABLE CREATION*/
/**/
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


/**/
/*CREATION OF INDEXES/EXTENSIONS*/
/**/
CREATE EXTENSION pgcrypto;

CREATE INDEX inx_friend_ids_list ON friends USING gin (friend_ids);

CREATE INDEX inx_friend_ids_climbed_with ON climbed_munros USING gin (friends_ids);

CREATE INDEX inx_other_friends_climbed_with ON climbed_munros USING gin (other_friends);


/**/
/*CREATION OF FUNCTIONS FOR TRIGGERS*/
/**/
CREATE OR REPLACE FUNCTION fn_secure_password()
RETURNS trigger AS '
  BEGIN
    new.password := crypt(new.password, gen_salt(''bf''));
    RETURN NEW;
  END'
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION fn_remove_from_friend_lists()
RETURNS TRIGGER AS '
  BEGIN
    UPDATE friends
    SET friend_ids = array_remove(friend_ids, old.user_id)
    WHERE old.user_id=ANY(friend_ids);
    RETURN OLD;
  END'
LANGUAGE 'plpgsql';


/**/
/*CREATION OF TRIGGERS*/
/**/
CREATE TRIGGER tg_secure_password BEFORE INSERT OR UPDATE OF password
ON users
FOR EACH ROW
EXECUTE PROCEDURE fn_secure_password();

CREATE TRIGGER tg_remove_from_friend_lists BEFORE DELETE
ON users
FOR EACH ROW
EXECUTE PROCEDURE fn_remove_from_friend_lists();





/**/
/*TEST USER CREATION*/
/**/
INSERT INTO users (first_name, second_name, email, password)
VALUES ('Test', 'User', 'fake@email.fake', 'password');
