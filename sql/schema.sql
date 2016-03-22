CREATE TABLE users (
  id            SERIAL PRIMARY KEY,
  handle        VARCHAR(16) UNIQUE  NOT NULL,
  pubkey        TEXT                NOT NULL,
  fingerprint   VARCHAR(128) UNIQUE NOT NULL,
  last_activity TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
  created_at    TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

COMMENT ON COLUMN users.handle IS 'User nickname as shown to other users';
COMMENT ON COLUMN users.pubkey IS 'An OpenSSH RSA public key';
COMMENT ON COLUMN users.fingerprint IS 'SHA512 digest of the public key. Acts as a surrogate unique column instead of the actual key';
COMMENT ON COLUMN users.last_activity IS 'Last time the user issued a command against the server';

-- Private channels are hidden to mostly everybody. In order to read and/or write to a private channel a user must first be admitted in by the channel owner.
-- Protected channels are readable by every user in the system, but they may not write to them unless explicitly admitted in by the channel owner.
-- Public channels may be read and/or written by any user in the system.
CREATE TYPE accessibility AS ENUM (
  'private', 'protected', 'public'
);

CREATE TABLE channels (
  id           SERIAL PRIMARY KEY,
  owner_id     INT                  NOT NULL REFERENCES users (id),
  name         VARCHAR(32) UNIQUE   NOT NULL,
  access_level accessibility        NOT NULL,
  created_at   TIMESTAMPTZ          NOT NULL DEFAULT NOW()
);

-- TODO A 'channel' deletion must trigger a cascade delete in the 'messages' and 'admittances' tables.

CREATE TABLE admittances (
  admittee_id INT NOT NULL REFERENCES users (id),
  channel_id  INT NOT NULL REFERENCES channels (id)
);

COMMENT ON TABLE admittances IS 'The admittances table keeps track of which users are allowed in which channels. Channel owners are implicitly admitted in their channels';

CREATE TABLE messages (
  id         SERIAL PRIMARY KEY,
  author_id  INT         NOT NULL REFERENCES users (id),
  channel_id INT         NOT NULL REFERENCES channels (id),
  content    TEXT        NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
