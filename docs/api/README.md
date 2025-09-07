# API Documentation

This directory contains API documentation for the Katya project, including OpenAPI specifications, endpoint documentation, and integration guides.

## Structure

- `openapi/` - OpenAPI/Swagger specifications
- `endpoints/` - Detailed endpoint documentation
- `integrations/` - Third-party integration guides
- `webhooks/` - Webhook documentation

## API Overview

Katya provides RESTful APIs for:
- User authentication and management
- Chat and messaging functionality
- Blockchain integration
- AI-powered features
- Matrix protocol bridge operations

## Authentication

All API requests require authentication using JWT tokens obtained through the login endpoint.

```
Authorization: Bearer <your-jwt-token>
```

## Base URL

```
https://api.katya.rechain.network/v1
```

## Rate Limiting

- 1000 requests per hour for authenticated users
- 100 requests per hour for unauthenticated users

## Error Handling

All errors follow this format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {}
  }
}
```

## Quick Start

1. Obtain API credentials
2. Authenticate to get JWT token
3. Make authenticated requests to endpoints

## SDKs and Libraries

- [Dart SDK](https://pub.dev/packages/katya_sdk)
- [JavaScript SDK](https://www.npmjs.com/package/katya-js-sdk)
- [Python SDK](https://pypi.org/project/katya-python-sdk/)

## Support

For API support, please contact: api-support@rechain.network
