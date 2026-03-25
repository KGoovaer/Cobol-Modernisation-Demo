# Quickstart: MYFIN Web Application — Local Development

**Date**: 2026-03-23

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Java | 21 | `sdk install java 21-tem` (SDKMAN) or [Adoptium](https://adoptium.net) |
| Maven | 3.9+ | bundled Maven Wrapper (`./mvnw`) is included |
| Node.js | 22 LTS | https://nodejs.org or `nvm install 22` |
| Angular CLI | 19.x | `npm install -g @angular/cli@19` |

No database installation needed for local dev — H2 runs in-memory.  
No external service access needed — all adapters run in stub mode.

---

## Repository Layout

```
specs/001-spring-angular-app/
├── backend/     ← Spring Boot Maven project
└── frontend/    ← Angular CLI project
```

---

## Backend

### First-time setup

```bash
cd specs/001-spring-angular-app/backend
./mvnw clean install -DskipTests
```

### Run (dev + stub profiles)

```bash
./mvnw spring-boot:run \
  -Dspring-boot.run.profiles=dev,stub
```

The `dev` profile activates H2 with PostgreSQL compatibility mode.  
The `stub` profile activates all `@Profile("stub")` adapter implementations.

Spring Boot starts on **http://localhost:8080**.

### H2 Console (dev only)

Browse the in-memory database at:  
**http://localhost:8080/h2-console**

JDBC URL: `jdbc:h2:mem:MYFIN`  
Username: `sa` · Password: *(empty)*

### Flyway

Migrations run automatically on startup. To reset:

```bash
# Stop the app, then restart — H2 in-memory is wiped on JVM exit
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev,stub
```

---

## Frontend

### First-time setup

```bash
cd specs/001-spring-angular-app/frontend
npm install
```

### Run

```bash
ng serve
```

Angular devserver starts on **http://localhost:4200**.

The Angular `proxy.conf.json` forwards `/api/**` to `http://localhost:8080` so CORS is not an issue in development.

```json
{
  "/api": {
    "target": "http://localhost:8080",
    "secure": false,
    "changeOrigin": true
  }
}
```

---

## Seed Users

Flyway migration `V1__create_users.sql` inserts the following test accounts (BCrypt-hashed passwords):

| Username | Password | Role | Mutuality codes |
|----------|----------|------|-----------------|
| `submitter` | `Test1234!` | SUBMITTER | 101, 102, 103 |
| `readonly` | `Test1234!` | READ_ONLY | 101 |
| `admin` | `Test1234!` | ADMIN | — |

---

## Login

1. Open **http://localhost:4200**
2. You are redirected to the login page
3. Enter credentials from the table above
4. The Angular app reads the `XSRF-TOKEN` cookie set by Spring and attaches `X-XSRF-TOKEN` on every state-changing request

---

## Submitting a Test Payment

Use the **submitter** account. Navigate to **Submit Payment**.

**Happy path values** (accepted by stub adapters):

| Field | Value |
|-------|-------|
| Member RNR | `12345678901` |
| Destination mutuality | `101` |
| Constant ID | `TEST000001` |
| Sequence No | `0001` |
| Amount (euros) | `123.45` |
| Currency | `E` |
| Payment desc code | `5` |
| IBAN | `BE68539007547034` |
| Payment method | *(blank — SEPA transfer)* |
| Accounting type | `1` |

Expected result: **ACCEPTED** confirmation.

**Stub rejection triggers**:

| Scenario | Value to use |
|----------|-------------|
| Unknown member | Member RNR `99999999999` |
| Duplicate payment | Member RNR `12345678901` + same constant_id + same amount (submit twice) |
| Invalid IBAN | IBAN `INVALID` |
| IBAN service unavailable | IBAN `BE00000000000000` (special stub value) |
| Unknown language | Member RNR `11111111111` |
| Unknown payment desc code | Code `42` |

---

## Running Tests

### Backend

```bash
cd backend
./mvnw test
```

Runs all JUnit 5 tests. MockMvc tests use Spring's test context with `@ActiveProfiles("dev", "stub")` — no external dependencies needed.

### Frontend

```bash
cd frontend
ng test
```

Runs Jest unit tests (or Karma if configured). No backend connection required for unit tests.

---

## Useful URLs

| URL | Description |
|-----|-------------|
| http://localhost:4200 | Angular app |
| http://localhost:8080/api/auth/me | Check session (returns current user JSON) |
| http://localhost:8080/h2-console | H2 in-memory DB browser |
| http://localhost:8080/actuator/health | Spring Boot Actuator health |
