---
task: Build a REST API
test_command: npm test
---

# Task: REST API with User Management

Build a REST API with Express.js that handles user management operations.

## Success Criteria

1. [ ] Project initialized with package.json and TypeScript
2. [ ] GET /health returns 200 OK with { status: "healthy" }
3. [ ] POST /users creates a new user and returns 201
4. [ ] GET /users/:id returns user by ID or 404
5. [ ] GET /users returns list of all users
6. [ ] DELETE /users/:id removes user and returns 204
7. [ ] Input validation on POST /users (name, email required)
8. [ ] All endpoints have proper error handling
9. [ ] All tests pass

## Context

- **Stack**: Node.js, Express.js, TypeScript
- **Storage**: In-memory (no database needed)
- **Testing**: Jest or Vitest
- **Port**: 3000

## API Specification

### POST /users
Request:
```json
{
  "name": "John Doe",
  "email": "john@example.com"
}
```

Response (201):
```json
{
  "id": "uuid",
  "name": "John Doe",
  "email": "john@example.com",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

### GET /users/:id
Response (200):
```json
{
  "id": "uuid",
  "name": "John Doe",
  "email": "john@example.com",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

Response (404):
```json
{
  "error": "User not found"
}
```

## Notes

- Use UUID for user IDs
- Validate email format
- Return appropriate HTTP status codes
- Include timestamps in ISO 8601 format

