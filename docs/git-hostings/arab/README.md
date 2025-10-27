# Arab Countries Git Hosting Integration Documentation

This directory contains documentation for Arab countries Git hosting platforms integration, workflows, and configurations.

## Supported Platforms

- [GitHub Arabia](https://github.arabia/) - Pan-Arab GitHub mirror
- [GitLab MENA](https://gitlab.mena/) - Middle East & North Africa GitLab
- [SourceForge Arabia](https://sourceforge.arabia/) - Arab SourceForge
- [UAE Developer Hub](https://developer.ae/) - UAE government platform
- [Saudi Developer Portal](https://developer.sa/) - Saudi Arabia platform
- [Egypt Tech Hub](https://techhub.eg/) - Egyptian developer platform
- [Jordan Open Source](https://opensource.jo/) - Jordanian platform
- [Lebanon Tech](https://tech.lb/) - Lebanese developer platform

## Environment Requirements

- Git 2.25.0 or higher
- SSH client with Arab certificate authorities
- GPG for commit signing (recommended)
- Arabic/English keyboard support
- RTL (Right-to-Left) text support

## Quick Start

### 1. Platform Account Setup

#### UAE Developer Hub
1. Register using [UAE Pass](https://uaepass.ae/) authentication
2. Complete identity verification for UAE residents
3. Generate API token with appropriate permissions

#### Saudi Developer Portal
1. Register with [Absher](https://www.absher.sa/) credentials
2. Verify Saudi citizenship or residency
3. Generate developer token

### 2. Project Configuration

#### Configuration File
Create `.katya.arab.json` in project root:

```json
{
  "platform": "github-arabia",
  "apiBaseUrl": "https://api.github.arabia",
  "accessToken": "your-arab-token",
  "repoOwner": "your-arab-username",
  "repoName": "katya",
  "branch": "main",
  "arabCompliance": {
    "dataResidency": "mena",
    "arabicSupport": true,
    "rtlSupport": true,
    "islamicCalendar": true,
    "prayerTimes": true,
    "halalCompliance": false
  },
  "ciConfig": {
    "enabled": true,
    "platform": "github-actions-arabia",
    "configFile": ".github/workflows/ci-arabia.yml",
    "regionalRunner": "me-central-1",
    "arabicLocalization": true
  }
}
```

## CI/CD Workflows

### Arabic Language Support

```yaml
name: Arabic CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  RTL_SUPPORT: true
  ARABIC_LOCALIZATION: true
  ISLAMIC_CALENDAR: true

jobs:
  arabic-compliance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Arabic Language Validation
        run: |
          # Check for Arabic language support
          if ! grep -q "ar" pubspec.yaml; then
            echo "Error: Arabic localization required"
            exit 1
          fi

          # Validate RTL support
          if ! grep -q "textDirection.*TextDirection.rtl" lib/; then
            echo "Error: RTL support required"
            exit 1
          fi

      - name: Islamic Calendar Integration
        run: |
          # Check for Islamic calendar support
          if ! grep -q "hijri\|islamic" lib/calendar/; then
            echo "Warning: Islamic calendar integration recommended"
          fi

  build-arabic:
    needs: arabic-compliance
    runs-on: [self-hosted, mena]
    strategy:
      matrix:
        language: [ar, en, fr, ur, fa]
    steps:
      - uses: actions/checkout@v3

      - name: Setup Arabic Environment
        run: |
          # Configure for Arabic development
          export LANG=ar_AE.UTF-8
          export TZ=Asia/Dubai
          echo "AWS_DEFAULT_REGION=me-central-1" >> $GITHUB_ENV

      - name: Install Arabic Dependencies
        run: |
          # Use Middle East package mirrors
          npm config set registry https://registry.npmjs.ae/
          pip install --index-url https://pypi.mena/simple -r requirements.txt

      - name: Build with Arabic Support
        run: |
          # Build for Arabic markets
          flutter build apk --flavor arabic --dart-define=LANG=${{ matrix.language }}
          flutter build ios --flavor arabic --export-method app-store

      - name: RTL Testing
        run: |
          # Test RTL layout
          flutter test --tags rtl
          flutter test --tags arabic

      - name: Cultural Compliance Testing
        run: |
          # Test cultural appropriateness
          if grep -q "inappropriate" content/; then
            echo "Error: Content violates cultural norms"
            exit 1
          fi
```

## Regional Compliance

### UAE Compliance
```yaml
- name: UAE Compliance Check
  run: |
    # Verify UAE data protection compliance
    if ! grep -q "uae-data-protection" compliance.md; then
      echo "Error: UAE data protection compliance required"
      exit 1
    fi

    # Check for UAE federal law compliance
    if ! grep -q "federal-law-5" legal.md; then
      echo "Error: UAE Federal Law No. 5 compliance required"
      exit 1
    fi
```

### Saudi Arabia Compliance
```yaml
- name: Saudi Compliance Check
  run: |
    # Verify SAMA (Saudi Central Bank) compliance
    if ! grep -q "sama" financial.md; then
      echo "Warning: SAMA compliance recommended for financial features"
    fi

    # Check for NCSC (National Cyber Security Center) compliance
    if ! grep -q "ncsc" security.md; then
      echo "Error: NCSC compliance required"
      exit 1
    fi
```

## Language and Cultural Support

### Arabic Localization
```yaml
flutter_localizations:
  - ar      # Modern Standard Arabic
  - ar_AE   # UAE Arabic
  - ar_SA   # Saudi Arabic
  - ar_EG   # Egyptian Arabic
  - ar_JO   # Jordanian Arabic
  - ar_LB   # Lebanese Arabic
  - ar_MA   # Moroccan Arabic
  - ar_DZ   # Algerian Arabic
  - ar_TN   # Tunisian Arabic
  - ar_YE   # Yemeni Arabic
```

### RTL Support Implementation
```dart
// RTL-aware UI components
class ArabicText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextDirection textDirection;

  const ArabicText({
    Key? key,
    required this.text,
    this.style,
    this.textDirection = TextDirection.rtl,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textDirection: textDirection,
      textAlign: textDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left,
    );
  }
}
```

### Islamic Calendar Integration
```dart
// Islamic calendar support
class IslamicCalendar {
  static DateTime gregorianToHijri(DateTime gregorian) {
    // Convert Gregorian to Hijri calendar
  }

  static DateTime hijriToGregorian(int hijriYear, int hijriMonth, int hijriDay) {
    // Convert Hijri to Gregorian calendar
  }

  static List<PrayerTime> getPrayerTimes(double latitude, double longitude, DateTime date) {
    // Calculate prayer times for location and date
  }
}
```

## Cultural Features

### Prayer Times Integration
```dart
// Prayer times notification service
class PrayerTimeService {
  final LocationService _locationService;
  final NotificationService _notificationService;

  Future<void> schedulePrayerNotifications() async {
    final location = await _locationService.getCurrentLocation();
    final prayerTimes = await IslamicCalendar.getPrayerTimes(
      location.latitude,
      location.longitude,
      DateTime.now(),
    );

    for (final prayer in prayerTimes) {
      await _notificationService.scheduleNotification(
        scheduledTime: prayer.time,
        title: 'Prayer Time',
        body: '${prayer.name} prayer time',
        payload: 'prayer_${prayer.name}',
      );
    }
  }
}
```

### Arabic Typography
```css
/* Arabic font support */
.arabic-text {
  font-family: 'Noto Sans Arabic', 'Cairo', 'Amiri', sans-serif;
  direction: rtl;
  text-align: right;
  line-height: 1.8;
  letter-spacing: 0.5px;
}

/* Number formatting for Arabic */
.arabic-numbers {
  font-variant-numeric: lining-nums;
  direction: ltr;
  display: inline-block;
}
```

## Regional App Stores

### UAE App Store Deployment
```bash
# Build for UAE market
flutter build appbundle --flavor uae --target-platform android-arm64

# Deploy to Huawei AppGallery UAE
fastlane deploy_uae

# Deploy to Samsung Galaxy Store UAE
fastlane deploy_galaxy_uae
```

### Saudi App Store Deployment
```bash
# Build for Saudi market
flutter build appbundle --flavor saudi --target-platform android-arm64

# Deploy to local Saudi app stores
fastlane deploy_saudi
```

## Payment Integration

### Regional Payment Methods
```dart
// Middle East payment integration
class MenaPaymentService {
  Future<void> integrateSTC() async {
    // Saudi Telecom Company payment integration
  }

  Future<void> integrateEtisalat() async {
    // Etisalat payment integration
  }

  Future<void> integrateDu() async {
    // du (Emirates Integrated Telecommunications Company) integration
  }

  Future<void> integrateZain() async {
    // Zain Group payment integration
  }
}
```

## Government Integration

### UAE Government APIs
```dart
// UAE government service integration
class UAEGovernmentService {
  Future<void> verifyEmiratesId(String emiratesId) async {
    // Integration with UAE ID verification
  }

  Future<void> checkVisaStatus(String visaNumber) async {
    // Integration with UAE visa services
  }

  Future<void> accessDubaiNow() async {
    // Integration with Dubai Now services
  }
}
```

### Saudi Government APIs
```dart
// Saudi government service integration
class SaudiGovernmentService {
  Future<void> verifyIqama(String iqamaNumber) async {
    // Integration with Saudi residency verification
  }

  Future<void> checkAbsherStatus() async {
    // Integration with Absher services
  }

  Future<void> accessNafath() async {
    // Integration with Saudi digital identity
  }
}
```

## Testing

### Arabic Testing Standards
```dart
// Arabic localization testing
class ArabicLocalizationTests {
  test('RTL Layout') {
    expect(textDirection, TextDirection.rtl);
    expect(textAlign, TextAlign.right);
    expect(layoutDirection, TextDirection.rtl);
  }

  test('Arabic Typography') {
    expect(fontFamily, contains('Arabic'));
    expect(letterSpacing, greaterThan(0));
    expect(lineHeight, greaterThan(1.5));
  }

  test('Cultural Compliance') {
    // Test cultural appropriateness
    expect(forbiddenContent, isEmpty);
    expect(religiousContent, isRespectful);
    expect(localCustoms, isRespected);
  }
}
```

## Support

### Arabic Support Channels
- **Arabic Email**: support@katya.arabia
- **Arabic Phone**: +971-4-123-4567 (UAE)
- **Arabic Phone**: +966-11-123-4567 (Saudi)
- **WhatsApp**: +971-50-123-4567
- **Live Chat**: Arabic and English support

### Regional Business Hours
- **UAE**: Sunday-Thursday, 8 AM - 6 PM GST
- **Saudi Arabia**: Sunday-Thursday, 8 AM - 5 PM AST
- **Egypt**: Sunday-Thursday, 9 AM - 5 PM EET

## Resources

- [UAE Data Protection Law](https://www.moei.gov.ae/en/strategic-objectives/data-protection)
- [Saudi PDPL](https://www.ncsc.gov.sa/)
- [Arabic Web Standards](https://www.arabweb.org/)
- [Islamic Calendar API](https://api.aladhan.com/)
