-- T008: V1__create_users.sql
-- Creates users and user_mutuality_codes tables.
-- PostgreSQL-compatible syntax; runs in H2 PostgreSQL mode during development.

CREATE TABLE users (
    id            UUID         DEFAULT gen_random_uuid() PRIMARY KEY,
    username      VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(72)  NOT NULL,
    role          VARCHAR(20)  NOT NULL CHECK (role IN ('SUBMITTER', 'READ_ONLY', 'ADMIN')),
    active        BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP    NOT NULL DEFAULT now()
);

CREATE TABLE user_mutuality_codes (
    user_id        UUID     NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    mutuality_code INTEGER NOT NULL CHECK (mutuality_code BETWEEN 101 AND 169),
    PRIMARY KEY (user_id, mutuality_code)
);

-- Seed an initial admin user (password: Admin1234! — BCrypt hash)
INSERT INTO users (id, username, password_hash, role, active, created_at)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'admin',
    '$2b$10$7iN4QsayhQ1Evq9bZce/T.kE9C1rbFINI8wZB6p21Ns.xNFZzeIiW',  -- Admin1234!
    'ADMIN',
    TRUE,
    now()
);

-- Seed a test submitter (password: Test1234!)
INSERT INTO users (id, username, password_hash, role, active, created_at)
VALUES (
    '00000000-0000-0000-0000-000000000002',
    'submitter',
    '$2b$10$PMB3ixTXPXVG6bx.opgCwe7qjWXi8kkC/KbI8HqaPk2WGeQ2ereOW',  -- Test1234!
    'SUBMITTER',
    TRUE,
    now()
);

INSERT INTO user_mutuality_codes (user_id, mutuality_code)
VALUES ('00000000-0000-0000-0000-000000000002', 101),
       ('00000000-0000-0000-0000-000000000002', 106);

-- Seed a test read-only user (password: Test1234!)
INSERT INTO users (id, username, password_hash, role, active, created_at)
VALUES (
    '00000000-0000-0000-0000-000000000003',
    'readonly',
    '$2b$10$PMB3ixTXPXVG6bx.opgCwe7qjWXi8kkC/KbI8HqaPk2WGeQ2ereOW',  -- Test1234!
    'READ_ONLY',
    TRUE,
    now()
);

INSERT INTO user_mutuality_codes (user_id, mutuality_code)
VALUES ('00000000-0000-0000-0000-000000000003', 101);
