# Canadian Git Hosting Integration Documentation

This directory contains documentation for Canadian Git hosting platforms integration, workflows, and configurations.

## Supported Platforms

- [GitHub Canada](https://github.ca/) - Canadian mirror of GitHub
- [GitLab Canada](https://gitlab.ca/) - Canadian instance of GitLab
- [Codeberg Canada](https://codeberg.ca/) - Canadian Gitea instance
- [SourceForge Canada](https://sourceforge.ca/) - Canadian SourceForge
- [Bitbucket Canada](https://bitbucket.ca/) - Canadian Atlassian instance
- [Launchpad Canada](https://launchpad.ca/) - Canadian Launchpad mirror
- [Savannah Canada](https://savannah.ca/) - Canadian GNU Savannah

## Environment Requirements

- Git 2.25.0 or higher
- SSH client for secure connections
- GPG for commit signing (recommended)
- Canadian VPN or proxy (for compliance)

## Quick Start

### 1. Platform Account Setup

#### GitHub Canada
1. Register at [GitHub Canada](https://github.ca/signup)
2. Generate Personal Access Token:
   - Go to Settings → Developer settings → Personal access tokens
   - Create new token with `repo`, `workflow`, `user` scopes
3. Enable Two-Factor Authentication (2FA)

#### GitLab Canada
1. Register at [GitLab Canada](https://gitlab.ca/users/sign_up)
2. Generate Access Token:
   - Go to User Settings → Access Tokens
   - Create token with `api`, `read_repository`, `write_repository` scopes

### 2. Project Configuration

#### Install Dependencies
```bash
# Canadian mirror packages
pip install --index-url https://pypi.ca/simple package-name

# Or using conda-forge Canada
conda install -c conda-forge-ca package-name
```

#### Configuration File
Create `.katya.canadian.json` in project root:

```json
{
  "platform": "github-ca",
  "apiBaseUrl": "https://api.github.ca",
  "accessToken": "your-canadian-token",
  "repoOwner": "your-canadian-username",
  "repoName": "katya",
  "branch": "main",
  "canadianCompliance": {
    "pipacCompliance": true,
    "caslCompliance": true,
    "dataResidency": "canada",
    "encryptionRequired": true
  },
  "ciConfig": {
    "enabled": true,
    "platform": "github-actions-ca",
    "configFile": ".github/workflows/ci-ca.yml",
    "regionalRunner": "ca-central-1"
  }
}
```

## CI/CD Workflows

### GitHub Actions Canada Configuration
Create `.github/workflows/ci-canadian.yml`:

```yaml
name: Canadian CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  AWS_REGION: ca-central-1
  AZURE_REGION: canadacentral

jobs:
  compliance-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: PIPEDA Compliance Check
        run: |
          # Verify Canadian data protection compliance
          if ! grep -q "PIPEDA" compliance.md; then
            echo "Error: PIPEDA compliance documentation required"
            exit 1
          fi

      - name: CASL Compliance Check
        run: |
          # Check anti-spam compliance
          if ! grep -q "consent" privacy-policy.md; then
            echo "Error: CASL consent mechanism required"
            exit 1
          fi

  build-test:
    needs: compliance-check
    runs-on: [self-hosted, canada]
    steps:
      - uses: actions/checkout@v3

      - name: Setup Canadian Environment
        run: |
          # Configure for Canadian data centers
          echo "AWS_DEFAULT_REGION=ca-central-1" >> $GITHUB_ENV
          echo "AZURE_STORAGE_ACCOUNT=${{ secrets.AZURE_CA_STORAGE }}" >> $GITHUB_ENV

      - name: Install Dependencies
        run: |
          # Use Canadian package mirrors
          pip install --index-url https://pypi.ca/simple -r requirements.txt
          npm install --registry https://registry.npmjs.ca/

      - name: Run Canadian Tests
        run: |
          # Run tests with Canadian locale
          export LANG=en_CA.UTF-8
          flutter test --coverage

      - name: Build for Canada
        run: |
          flutter build apk --flavor canada
          flutter build ios --flavor canada

      - name: Security Scan
        uses: github/super-linter@v4
        env:
          DEFAULT_BRANCH: main
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  deploy-canada:
    needs: build-test
    runs-on: [self-hosted, canada]
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3

      - name: Deploy to Canadian CDN
        run: |
          # Deploy to AWS CloudFront (Canada region)
          aws s3 sync build/web/ s3://katya-canada-cdn --region ca-central-1
          aws cloudfront create-invalidation --distribution-id ${{ secrets.CF_CA_DISTRIBUTION_ID }} --paths "/*"

      - name: Deploy to Azure Canada
        uses: Azure/cli@v1
        with:
          inlineScript: |
            az webapp deployment source config --branch main --manual-integration --repo-url https://github.ca/${{ github.repository }}.git
```

### CASL Compliance Integration

```yaml
- name: CASL Compliance Validation
  run: |
    # Check for proper consent mechanisms
    if ! grep -q "consent\|permission\|opt-in" user-registration.md; then
      echo "Error: CASL consent mechanism required for Canadian users"
      exit 1
    fi

    # Validate email compliance
    if grep -q "noreply@" email-templates/; then
      echo "Error: CASL requires proper sender identification"
      exit 1
    fi
```

## Release Management

### Canadian App Store Deployment

#### Google Play Store Canada
```bash
# Build AAB for Canadian store
flutter build appbundle --flavor canada --target-platform android-arm64

# Upload to Google Play Console (Canada)
fastlane deploy_canada
```

#### Apple App Store Canada
```bash
# Build IPA for Canadian store
flutter build ios --flavor canada --export-method app-store

# Validate and upload
fastlane deploy_canada_ios
```

### Version Management
Follow [Canadian versioning standards](https://canadian-standards.ca/software-versioning):

- `1.0.0-ca.1`: First Canadian release
- `1.0.1-ca.1`: Canadian patch release
- `1.1.0-ca.1`: Canadian minor release with PIPEDA updates

## Package Management

### Canadian Package Registries

#### Python Packages
```bash
# Use Canadian PyPI mirror
pip install --index-url https://pypi.ca/simple package-name

# Or conda-forge Canada
conda install -c conda-forge-ca package-name
```

#### Node.js Packages
```bash
# Canadian npm registry
npm config set registry https://registry.npmjs.ca/
npm install package-name

# Yarn Canada
yarn config set registry https://registry.yarn.ca/
```

#### Flutter Packages
```yaml
# pubspec.yaml
dependencies:
  # Canadian mirror packages
  http: ^0.13.5
  provider: ^6.0.5

dependency_overrides:
  # Force Canadian mirrors
  http:
    git:
      url: https://github.ca/dart-lang/http.git
```

## Best Practices

### 1. Data Residency
- All Canadian user data must remain in Canada
- Use AWS `ca-central-1` or Azure `canadacentral`
- Implement data sovereignty controls

### 2. Privacy Compliance
- **PIPEDA**: Personal Information Protection and Electronic Documents Act
- **CASL**: Canadian Anti-Spam Legislation
- **Provincial Laws**: Quebec Bill 64, Ontario PIPEDA compliance

### 3. Language Support
```yaml
# Canadian localization
flutter_localizations:
  - en_CA  # Canadian English
  - fr_CA  # Canadian French
  - iu      # Inuktitut
  - mic     # Mi'kmaq
```

### 4. Accessibility
- WCAG 2.1 AA compliance (mandatory for government contracts)
- Screen reader support (NVDA, JAWS, VoiceOver)
- High contrast mode support

## Common Issues

### 1. Authentication Failures
```bash
# Canadian VPN required
git config --global credential.helper store
# Login through Canadian proxy
```

### 2. Large File Uploads
```bash
# Use Git LFS for Canadian repositories
git lfs install
git lfs track "*.zip"
git add .gitattributes
```

### 3. Regional Restrictions
```bash
# Ensure Canadian data residency
export AWS_DEFAULT_REGION=ca-central-1
export AZURE_DEFAULT_REGION=canadacentral
```

## Security Recommendations

1. **Encryption**: All data encrypted with Canadian-approved algorithms
2. **Access Controls**: Canadian users only access Canadian data centers
3. **Audit Logging**: All access logged for compliance
4. **Regular Audits**: Quarterly security assessments

## Government Integration

### 1. GC Notify
Integration with Government of Canada notification service:
```dart
// GC Notify API integration
final gcNotify = GCNotifyService(
  apiKey: 'your-gc-notify-key',
  baseUrl: 'https://api.notification.canada.ca',
);
```

### 2. Canada Digital Service
- Follow [Canada Digital Service guidelines](https://www.canada.ca/en/government/system/digital-government.html)
- Implement accessibility standards
- Use Canadian government APIs

## Testing

### Canadian Test Environment
```yaml
# GitHub Actions for Canadian testing
- name: Canadian Testing
  run: |
    export LANG=en_CA.UTF-8
    export TZ=America/Toronto
    flutter test --coverage --flavor canada
```

### Compliance Testing
```dart
// PIPEDA compliance tests
test('PIPEDA Compliance', () {
  // Test data residency
  expect(userDataLocation, 'Canada');

  // Test consent mechanisms
  expect(consentGiven, true);

  // Test data deletion
  expect(canDeleteData, true);
});
```

## Support

### Canadian Support Channels
- **Email**: support.ca@katya.app
- **Phone**: +1 (416) 555-KATYA
- **Live Chat**: Available in Canadian business hours (EST)
- **Help Center**: [help.katya.ca](https://help.katya.ca)

### Emergency Contacts
- **Privacy Officer**: privacy.ca@katya.app
- **Data Protection Officer**: dpo.ca@katya.app
- **Compliance Hotline**: 1-800-KATYA-CA

## License

All Canadian operations comply with Canadian federal and provincial laws.

## Resources

- [PIPEDA Guidelines](https://www.priv.gc.ca/en/privacy-topics/privacy-laws-in-canada/the-personal-information-protection-and-electronic-documents-act-pipeda/)
- [CASL Requirements](https://crtc.gc.ca/eng/internet/anti.htm)
- [Canadian Digital Government Standards](https://www.canada.ca/en/government/system/digital-government.html)
