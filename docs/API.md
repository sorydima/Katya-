# Katya API Documentation

This document provides detailed information about the Katya application's API, including endpoints, data structures, and usage examples.

## Table of Contents
- [Overview](#overview)
- [Authentication](#authentication)
- [Endpoints](#endpoints)
- [Data Models](#data-models)
- [Error Handling](#error-handling)
- [Rate Limiting](#rate-limiting)
- [Examples](#examples)

## Overview

Katya provides a RESTful API for interacting with the application's core functionalities. The API is designed to be simple, consistent, and follows standard HTTP conventions.

### Base URL
```
https://api.katya.app/v1/  # Production
http://localhost:8080/v1/   # Development
```

### Response Format
All API responses are in JSON format with the following structure:

```json
{
  "success": true,
  "data": {
    // response data
  },
  "message": "Operation successful",
  "timestamp": "2023-12-07T10:30:00Z"
}
```

### HTTP Status Codes
- `200 OK` - Successful request
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid input parameters
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

## Authentication

Most API endpoints require authentication. Katya uses JWT (JSON Web Tokens) for authentication.

### Obtaining a Token

```bash
curl -X POST https://api.katya.app/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "yourpassword"
  }'
```

Response:
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe"
    }
  }
}
```

### Using the Token
Include the token in the Authorization header:

```bash
curl -X GET https://api.katya.app/v1/users/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Endpoints

### Authentication Endpoints

#### POST /auth/login
Authenticate a user and receive a JWT token.

**Request Body:**
```json
{
  "email": "string",
  "password": "string"
}
```

#### POST /auth/register
Register a new user.

**Request Body:**
```json
{
  "email": "string",
  "password": "string",
  "name": "string"
}
```

#### POST /auth/logout
Invalidate the current JWT token.

#### POST /auth/refresh
Refresh an expired JWT token.

### User Endpoints

#### GET /users/me
Get current user profile.

#### PUT /users/me
Update current user profile.

**Request Body:**
```json
{
  "name": "string",
  "email": "string"
}
```

#### GET /users/{id}
Get user by ID (admin only).

### Data Endpoints

#### GET /data
List all data items with pagination.

**Query Parameters:**
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 20)
- `sort` - Sort field (default: createdAt)
- `order` - Sort order (asc/desc)

#### POST /data
Create a new data item.

**Request Body:**
```json
{
  "title": "string",
  "description": "string",
  "value": "number"
}
```

#### GET /data/{id}
Get a specific data item by ID.

#### PUT /data/{id}
Update a data item.

**Request Body:**
```json
{
  "title": "string",
  "description": "string",
  "value": "number"
}
```

#### DELETE /data/{id}
Delete a data item.

## Data Models

### User Model
```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "John Doe",
  "createdAt": "2023-12-07T10:30:00Z",
  "updatedAt": "2023-12-07T10:30:00Z"
}
```

### Data Item Model
```json
{
  "id": 1,
  "title": "Sample Item",
  "description": "This is a sample item",
  "value": 42,
  "userId": 1,
  "createdAt": "2023-12-07T10:30:00Z",
  "updatedAt": "2023-12-07T10:30:00Z"
}
```

## Error Handling

### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input parameters",
    "details": [
      {
        "field": "email",
        "message": "Email must be valid"
      }
    ]
  },
  "timestamp": "2023-12-07T10:30:00Z"
}
```

### Common Error Codes
- `VALIDATION_ERROR` - Input validation failed
- `AUTHENTICATION_ERROR` - Invalid credentials
- `AUTHORIZATION_ERROR` - Insufficient permissions
- `NOT_FOUND_ERROR` - Resource not found
- `INTERNAL_ERROR` - Server error

## Rate Limiting

API requests are rate-limited to prevent abuse:
- 100 requests per minute for authenticated users
- 10 requests per minute for unauthenticated users

Rate limit headers are included in responses:
- `X-RateLimit-Limit` - Total requests allowed
- `X-RateLimit-Remaining` - Requests remaining
- `X-RateLimit-Reset` - Time when limit resets

## Examples

### Complete Workflow Example

1. **Register a new user:**
```bash
curl -X POST https://api.katya.app/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "securepassword123",
    "name": "New User"
  }'
```

2. **Login to get token:**
```bash
curl -X POST https://api.katya.app/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "securepassword123"
  }'
```

3. **Create a data item:**
```bash
curl -X POST https://api.katya.app/v1/data \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "title": "My First Item",
    "description": "This is my first data item",
    "value": 100
  }'
```

4. **Retrieve data items:**
```bash
curl -X GET https://api.katya.app/v1/data \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## SDKs and Client Libraries

### Dart/Flutter Client
```dart
import 'package:katya_client/katya_client.dart';

final client = KatyaClient(
  baseUrl: 'https://api.katya.app/v1/',
  token: 'YOUR_JWT_TOKEN',
);

// Example usage
final user = await client.users.getMe();
final items = await client.data.list();
```

### JavaScript Client
```javascript
import { KatyaClient } from 'katya-client';

const client = new KatyaClient({
  baseURL: 'https://api.katya.app/v1/',
  token: 'YOUR_JWT_TOKEN'
});

// Example usage
const user = await client.users.getMe();
const items = await client.data.list();
```

## Versioning

The API is versioned through the URL path (e.g., `/v1/`). Breaking changes will result in a new version number.

## Support

For API-related questions and support:
- Check the [API documentation](https://github.com/sorydima/Katya-/docs/API.md)
- Create an [issue](https://github.com/sorydima/Katya-/issues) for bugs
- Join the [discussions](https://github.com/sorydima/Katya-/discussions) for questions

## Changelog

See [CHANGELOG.md](../CHANGELOG.md) for API changes and updates.