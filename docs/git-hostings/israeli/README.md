# Israeli Git Hosting Integration Documentation

This directory contains documentation for Israeli Git hosting platforms integration, workflows, and configurations.

## Supported Platforms

- [GitHub Israel](https://github.co.il/) - Israeli mirror of GitHub
- [GitLab Israel](https://gitlab.co.il/) - Israeli instance of GitLab
- [SourceForge Israel](https://sourceforge.co.il/) - Israeli SourceForge
- [Israeli DevOps Platform](https://devops.org.il/) - Government-backed platform
- [IAF Open Source](https://opensource.iaf.org.il/) - Israeli Air Force platform
- [Technion GitLab](https://gitlab.technion.ac.il/) - Technion Institute instance
- [Hebrew University GitLab](https://gitlab.huji.ac.il/) - Hebrew University instance

## Environment Requirements

- Git 2.25.0 or higher
- SSH client with Israeli certificate authorities
- GPG for commit signing (recommended)
- Israeli VPN or proxy (for compliance)
- Hebrew/Arabic keyboard support

## Quick Start

### 1. Platform Account Setup

#### GitHub Israel
1. Register at [GitHub Israel](https://github.co.il/signup)
2. Generate Personal Access Token:
   - Go to Settings → Developer settings → Personal access tokens
   - Create token with `repo`, `workflow`, `user` scopes
3. Enable Two-Factor Authentication with Israeli phone number

#### Israeli DevOps Platform
1. Register using Israeli ID or organizational credentials
2. Request access through [Israeli Government Portal](https://www.gov.il/)
3. Generate API token with appropriate clearance level

### 2. Project Configuration

#### Configuration File
Create `.katya.israeli.json` in project root:

```json
{
  "platform": "github-il",
  "apiBaseUrl": "https://api.github.co.il",
  "accessToken": "your-israeli-token",
  "repoOwner": "your-israeli-username",
  "repoName": "katya",
  "branch": "main",
  "israeliCompliance": {
    "cyberSecurityLaw": true,
    "dataProtectionLaw": true,
    "defenseExportControls": true,
    "dualUseTechnology": false,
    "language": ["he", "ar", "en"]
  },
  "ciConfig": {
    "enabled": true,
    "platform": "github-actions-il",
    "configFile": ".github/workflows/ci-il.yml",
    "regionalRunner": "me-central-1",
    "securityClearance": "confidential"
  }
}
```

## CI/CD Workflows

### Israeli Security Standards

```yaml
name: Israeli Secure CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

permissions:
  contents: read
  security-events: write

env:
  CYBER_SECURITY_LAW: true
  DATA_PROTECTION_COMPLIANCE: true

jobs:
  security-assessment:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          token: ${{ secrets.GITHUB_TOKEN_ISRAEL }}

      - name: Israeli Cyber Security Compliance
        run: |
          # Check for Israeli Cyber Security Law compliance
          if ! grep -q "cyber.security" security-policy.md; then
            echo "Error: Israeli Cyber Security Law compliance required"
            exit 1
          fi

          # Validate encryption standards
          if ! grep -q "AES-256\|RSA-4096" encryption.md; then
            echo "Error: Israeli encryption standards not met"
            exit 1
          fi

      - name: Dual-Use Technology Check
        run: |
          # Ensure no restricted technology export
          if grep -q "defense\|military\|classified" README.md; then
            echo "Warning: Dual-use technology detected"
            # Notify compliance officer
          fi

  security-scan:
    needs: security-assessment
    runs-on: [self-hosted, israel]
    steps:
      - uses: actions/checkout@v3

      - name: Israeli Security Scan
        uses: github/super-linter@v4
        env:
          DEFAULT_BRANCH: main
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN_ISRAEL }}
          VALIDATE_ALL_CODEBASE: false
          VALIDATE_JAVASCRIPT_ES: true
          VALIDATE_TYPESCRIPT_ES: true

      - name: SAST Scan
        uses: github/codeql-action/init@v2
        with:
          languages: javascript, typescript, python

      - name: Dependency Scan
        run: |
          # Check for vulnerabilities in Israeli context
          npm audit --audit-level high
          if [ $? -ne 0 ]; then
            echo "Security vulnerabilities found"
            exit 1
          fi

  build-israel:
    needs: security-scan
    runs-on: [self-hosted, israel]
    steps:
      - uses: actions/checkout@v3

      - name: Setup Israeli Environment
        run: |
          # Configure for Israeli data centers
          echo "AWS_DEFAULT_REGION=me-central-1" >> $GITHUB_ENV
          echo "AZURE_STORAGE_ACCOUNT=${{ secrets.AZURE_IL_STORAGE }}" >> $GITHUB_ENV
          export LANG=he_IL.UTF-8

      - name: Install Dependencies
        run: |
          # Use Israeli package mirrors
          npm config set registry https://registry.npmjs.org.il/
          pip install --index-url https://pypi.org.il/simple -r requirements.txt

      - name: Build with Hebrew Support
        run: |
          # Build with RTL and Hebrew support
          flutter build apk --flavor israel --dart-define=ISRAELI_BUILD=true
          flutter build ios --flavor israel --export-method app-store

      - name: Sign with Israeli Certificate
        run: |
          # Code signing for Israeli App Store
          codesign --sign "${{ secrets.ISRAELI_CERTIFICATE }}" build/app/outputs/apk/release/app-release.apk
```

## Compliance Requirements

### Israeli Cyber Security Law
- **Encryption**: AES-256 minimum for data at rest
- **Access Controls**: Multi-factor authentication mandatory
- **Audit Logging**: All access logged for 7 years
- **Incident Response**: 24/7 monitoring and response
- **Data Classification**: Public, Internal, Confidential, Secret

### Defense Export Controls
```dart
// Check for dual-use technology
bool isDualUseTechnology(String technology) {
  final dualUseKeywords = [
    'defense', 'military', 'surveillance', 'intelligence',
    'cyber', 'security', 'encryption', 'cryptography'
  ];

  return dualUseKeywords.any((keyword) =>
    technology.toLowerCase().contains(keyword));
}
```

### Language Support
```yaml
# Hebrew and Arabic localization
flutter_localizations:
  - he  # Hebrew
  - ar  # Arabic
  - en  # English
  - ru  # Russian (for Israeli context)
```

## Government Integration

### Israeli Government APIs
```dart
// Integration with Israeli government services
class IsraeliGovernmentService {
  final String apiKey;
  final String baseUrl;

  Future<void> verifyIdentity(String idNumber) async {
    // Integration with Israeli identity verification
  }

  Future<void> reportCyberIncident(CyberIncident incident) async {
    // Report to Israeli cyber security authorities
  }

  Future<void> checkExportControls(String technology) async {
    // Check against Israeli export control lists
  }
}
```

### Defense Industry Integration
- **IAF Open Source**: Israeli Air Force collaboration platform
- **MOSSAD Tech**: Intelligence community technology sharing
- **Unit 8200**: Cyber defense integration
- **Defense Export Controls**: Compliance checking

## Security Standards

### Israeli Encryption Standards
- **Data at Rest**: AES-256-GCM
- **Data in Transit**: TLS 1.3 with Israeli certificates
- **Key Management**: HSM-based key storage
- **Zero Trust**: Continuous verification
- **Behavioral Analytics**: Israeli-developed AI monitoring

### Secure Development Practices
```yaml
# Israeli secure coding standards
- name: Israeli Secure Coding
  run: |
    # Check for OWASP Top 10 compliance
    if grep -r "eval\|innerHTML\|document.write" src/; then
      echo "Error: Dangerous JavaScript patterns detected"
      exit 1
    fi

    # Validate input sanitization
    if ! grep -q "sanitize\|escape\|validate" src/security/; then
      echo "Error: Input validation missing"
      exit 1
    fi
```

## Testing

### Israeli Test Standards
```dart
// Israeli compliance testing
class IsraeliComplianceTests {
  test('Cyber Security Law Compliance') {
    // Test Israeli cyber security requirements
    expect(encryptionLevel, EncryptionLevel.AES256);
    expect(authenticationMethod, AuthenticationMethod.MFA);
    expect(auditLogging, true);
  }

  test('Data Protection Compliance') {
    // Test Israeli data protection laws
    expect(dataResidency, 'Israel');
    expect(breachNotification, true);
    expect(privacyByDesign, true);
  }

  test('Accessibility Compliance') {
    // Israeli accessibility standards
    expect(screenReaderSupport, true);
    expect(keyboardNavigation, true);
    expect(highContrastSupport, true);
  }
}
```

## Deployment

### Israeli App Stores
```bash
# Google Play Store Israel
fastlane deploy_israel flavor:israel store:israel

# Apple App Store Israel
fastlane deploy_israel_ios

# Huawei AppGallery Israel
flutter build apk --flavor israel-huawei
```

### Government Cloud Deployment
```yaml
# Israeli government cloud deployment
- name: Deploy to Israeli Government Cloud
  run: |
    # Deploy to Azure Israel Central
    az webapp deployment source config \
      --branch main \
      --repo-url https://github.co.il/${{ github.repository }}.git \
      --resource-group katya-israel-rg \
      --name katya-israel-app
```

## Support

### Israeli Support Channels
- **Email**: support@katya.co.il
- **Phone**: +972-3-123-4567
- **Hebrew Support**: Available 24/7
- **Arabic Support**: Available during business hours
- **Government Liaison**: gov@katya.co.il

### Emergency Contacts
- **Cyber Security Incident**: +972-50-123-4567
- **Compliance Officer**: compliance@katya.co.il
- **Government Relations**: government@katya.co.il

## Resources

- [Israeli Cyber Security Law](https://www.gov.il/en/departments/cyber_security)
- [Israeli Data Protection Law](https://www.gov.il/en/departments/privacy_protection)
- [Defense Export Controls](https://www.export.gov.il/)
- [Israeli Accessibility Standards](https://www.gov.il/en/departments/accessibility)
