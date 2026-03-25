# API Contract: Authentication

**Base path**: `/api/auth`  
**Authentication required**: No (these endpoints are the login/logout/introspection endpoints themselves)

---

## POST /api/auth/login

Authenticate a user and establish a session.

**Request** (form-encoded, Spring Security default):

```
POST /api/auth/login
Content-Type: application/x-www-form-urlencoded

username=submitter&password=Test1234!
```

**Responses**:

| Status | Body | Condition |
|--------|------|-----------|
| 200 OK | `UserDto` (see below) | Credentials valid; session cookie set |
| 401 Unauthorized | `{"error": "Bad credentials"}` | Invalid username or password |
| 401 Unauthorized | `{"error": "Account is disabled"}` | User is deactivated (`active = false`) |

**Session cookies set** on success:
- `JSESSIONID` (HttpOnly) — session identifier
- `XSRF-TOKEN` (readable by JS, `HttpOnly=false`) — CSRF token

**UserDto**:

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "username": "submitter",
  "role": "SUBMITTER",
  "mutualityCodes": [101, 102, 103]
}
```

---

## POST /api/auth/logout

Invalidate the current session.

**Request**:

```
POST /api/auth/logout
X-XSRF-TOKEN: <token from XSRF-TOKEN cookie>
```

**Responses**:

| Status | Body | Condition |
|--------|------|-----------|
| 200 OK | `{}` | Session invalidated; cookies cleared |
| 401 Unauthorized | — | No active session |

---

## GET /api/auth/me

Return the currently authenticated user.

**Request**:

```
GET /api/auth/me
```

**Responses**:

| Status | Body | Condition |
|--------|------|-----------|
| 200 OK | `UserDto` | Authenticated |
| 401 Unauthorized | `{"error": "Not authenticated"}` | No session |

---

## Security Notes

- All state-changing requests (`POST`, `PATCH`, `DELETE`) **must** include the `X-XSRF-TOKEN` header with the value from the `XSRF-TOKEN` cookie.
- Spring Security's `CookieCsrfTokenRepository.withHttpOnlyFalse()` makes the token readable by Angular's `HttpClientXsrfModule`.
- Session timeout: configurable via `server.servlet.session.timeout` (default: 30 minutes idle).
