-- T022: V2__create_payment_tables.sql
-- Creates all domain tables for payment processing.
-- PostgreSQL-compatible syntax; H2 runs in PostgreSQL mode.

CREATE TABLE payment_descriptions (
    code           INTEGER    PRIMARY KEY CHECK (code BETWEEN 1 AND 89),
    description_nl VARCHAR(50) NOT NULL,
    description_fr VARCHAR(50) NOT NULL,
    description_de VARCHAR(50)
);

CREATE TABLE payment_requests (
    id                    UUID         DEFAULT gen_random_uuid() PRIMARY KEY,
    member_rnr            BIGINT       NOT NULL,
    destination_mutuality INTEGER     NOT NULL CHECK (destination_mutuality BETWEEN 101 AND 169),
    constant_id           VARCHAR(10)  NOT NULL,
    sequence_no           VARCHAR(4),
    amount_cents          BIGINT       NOT NULL CHECK (amount_cents > 0),
    currency              CHAR(1)      NOT NULL CHECK (currency IN ('E', 'B')),
    payment_desc_code     INTEGER     NOT NULL CHECK (payment_desc_code BETWEEN 1 AND 99),
    iban                  VARCHAR(34)  NOT NULL,
    payment_method        VARCHAR(1)   NOT NULL DEFAULT ' ' CHECK (payment_method IN (' ', 'C', 'D', 'E', 'F')),
    accounting_type       INTEGER     NOT NULL CHECK (accounting_type IN (1, 3, 4, 5, 6)),
    submitted_by          UUID         NOT NULL REFERENCES users(id),
    submitted_at          TIMESTAMP    NOT NULL DEFAULT now(),
    status                VARCHAR(10)  NOT NULL CHECK (status IN ('ACCEPTED', 'REJECTED'))
);

CREATE INDEX idx_payment_requests_member ON payment_requests(member_rnr);
CREATE INDEX idx_payment_requests_constant ON payment_requests(constant_id);
CREATE INDEX idx_payment_requests_mutuality ON payment_requests(destination_mutuality);
CREATE INDEX idx_payment_requests_submitted_at ON payment_requests(submitted_at);

CREATE TABLE payment_records (
    id                    UUID         DEFAULT gen_random_uuid() PRIMARY KEY,
    payment_request_id    UUID         NOT NULL UNIQUE REFERENCES payment_requests(id),
    member_name           VARCHAR(50)  NOT NULL,
    member_rnr            BIGINT       NOT NULL,
    amount_cents          BIGINT       NOT NULL,
    iban                  VARCHAR(34)  NOT NULL,
    bic                   VARCHAR(11),
    bank_routing          VARCHAR(10)  NOT NULL CHECK (bank_routing IN ('BELFIUS', 'KBC')),
    regional_tag          INTEGER     NOT NULL CHECK (regional_tag IN (1, 2, 4, 7, 9)),
    accounting_type       INTEGER     NOT NULL CHECK (accounting_type IN (1, 3, 4, 5, 6)),
    destination_mutuality INTEGER     NOT NULL,
    payment_desc_nl       VARCHAR(50),
    payment_desc_fr       VARCHAR(50),
    created_at            TIMESTAMP    NOT NULL DEFAULT now()
);

CREATE INDEX idx_payment_records_mutuality ON payment_records(destination_mutuality);
CREATE INDEX idx_payment_records_created_at ON payment_records(created_at);
CREATE INDEX idx_payment_records_accounting_type ON payment_records(accounting_type);

CREATE TABLE rejection_records (
    id                 UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    payment_request_id UUID        NOT NULL UNIQUE REFERENCES payment_requests(id),
    diagnostic_nl      VARCHAR(32) NOT NULL,
    diagnostic_fr      VARCHAR(32) NOT NULL,
    created_at         TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE bank_account_discrepancies (
    id                 UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    payment_request_id UUID        NOT NULL REFERENCES payment_requests(id),
    provided_iban      VARCHAR(34) NOT NULL,
    known_iban         VARCHAR(34) NOT NULL,
    created_at         TIMESTAMP   NOT NULL DEFAULT now()
);
