# API Contract: User Administration

**Base path**: `/api/admin`  
**Authentication required**: Yes  
**Roles allowed**: ADMIN only for all endpoints. SUBMITTER and READ_ONLY → 403.

---

## GET /api/admin/users

List all users.

**Response**:

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "username": "submitter",
    "role": "SUBMITTER",
    "active": true,
    "mutualityCodes": [101, 102, 103],
    "createdAt": "2026-03-01T08:00:00Z"
  },
  {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "username": "readonly",
    "role": "READ_ONLY",
    "active": true,
    "mutualityCodes": [101],
    "createdAt": "2026-03-01T08:05:00Z"
  }
]
```

Note: `password_hash` is never returned in any response.

---

## POST /api/admin/users

Create a new user account.

**Request**:

```json
{
  "username": "newuser",
  "password": "InitialPass1!",
  "role": "SUBMITTER",
  "mutualityCodes": [101, 102]
}
```

**Field validation**:

| Field | Constraint |
|-------|-----------|
| username | `@NotBlank` `@Size(max=100)` unique |
| password | `@NotBlank` `@Size(min=8, max=72)` |
| role | `@NotNull` one of `SUBMITTER`, `READ_ONLY`, `ADMIN` |
| mutualityCodes | Non-null list; each code 101–169; required for SUBMITTER/READ_ONLY; must be empty for ADMIN |

**Responses**:

| Status | Body | Condition |
|--------|------|-----------|
| 201 Created | `UserDto` | User created |
| 400 Bad Request | `ValidationErrorDto` | Constraint violation |
| 409 Conflict | `{"error": "Username already exists"}` | Duplicate username |
| 403 Forbidden | — | Caller is not ADMIN |

**UserDto** (returned):

```json
{
  "id": "...",
  "username": "newuser",
  "role": "SUBMITTER",
  "active": true,
  "mutualityCodes": [101, 102],
  "createdAt": "2026-03-23T10:00:00Z"
}
```

---

## PATCH /api/admin/users/{id}/deactivate

Deactivate a user account (sets `active = false`). Deactivated users cannot log in. This is a soft delete — the account remains and can be reactivated via a future endpoint if needed.

**Path parameter**: `id` — UUID of `users.id`

**Request**: No body.  
**Headers**: `X-XSRF-TOKEN: <token>`

**Responses**:

| Status | Body | Condition |
|--------|------|-----------|
| 200 OK | `UserDto` (with `active: false`) | User deactivated |
| 404 Not Found | — | User ID does not exist |
| 400 Bad Request | `{"error": "Cannot deactivate the last active ADMIN"}` | Safety check |
| 403 Forbidden | — | Caller is not ADMIN |

---

## POST /api/admin/users/{id}/reset-password

Set a new temporary password for a user. The Admin sets the password; the user must change it on next login (optional behaviour in Phase 1 — at minimum, the password is replaced).

**Path parameter**: `id` — UUID of `users.id`

**Request**:

```json
{
  "newPassword": "Temp5678!"
}
```

**Field validation**:

| Field | Constraint |
|-------|-----------|
| newPassword | `@NotBlank` `@Size(min=8, max=72)` |

**Responses**:

| Status | Body | Condition |
|--------|------|-----------|
| 200 OK | `{}` | Password updated (BCrypt re-hash applied) |
| 400 Bad Request | `ValidationErrorDto` | Password too short |
| 404 Not Found | — | User ID does not exist |
| 403 Forbidden | — | Caller is not ADMIN |

---

## Security Notes

- Admins cannot submit payments (no mutuality codes assigned to ADMIN accounts).
- The last active ADMIN account cannot be deactivated (enforced by `UserAdminService`).
- Password reset sets the hash immediately; sessions belonging to the target user are NOT invalidated in Phase 1 (add this in a future phase if needed).
- All admin write operations require the `X-XSRF-TOKEN` header (CSRF protection).
