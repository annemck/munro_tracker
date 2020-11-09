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
  user_id INTEGER FOREIGN KEY REFERENCES users(user_id) ON DELETE CASCADE,
  friend_ids INTEGER[]
);

CREATE TABLE climbed_munros(
  user_id INTEGER FOREIGN KEY REFERENCES users(user_id) ON DELETE CASCADE,
  munro_smcid CHAR(4) NOT NULL UNIQUE,
  date_climbed DATE DEFAULT current_date,
  friends_ids INTEGER[],
  other_friends TEXT[],
);
