# Translation Management System

This directory contains the translation management system for the Katya project, including tools, workflows, and resources for managing multilingual content.

## Overview

The translation management system ensures consistent, high-quality translations across all supported languages and platforms. It includes automated workflows, quality assurance processes, and collaboration tools for translators and developers.

## Supported Platforms

### Core Application
- **Flutter Mobile App**: iOS and Android
- **Web Application**: React-based web interface
- **Desktop Applications**: Windows, macOS, Linux

### Supporting Platforms
- **Documentation**: GitHub Pages and external docs
- **Marketing Website**: Company website and landing pages
- **API Documentation**: Swagger/OpenAPI documentation
- **Email Templates**: Transactional and marketing emails
- **Support Content**: Help center and knowledge base

## Language Matrix

| Language | Code | Status | Coverage | Priority | Native Speakers |
|----------|------|--------|----------|----------|------------------|
| English | en | ✅ Complete | 100% | Critical | 1.5B+ |
| Spanish | es | ✅ Complete | 95% | High | 460M |
| French | fr | ✅ Complete | 90% | High | 280M |
| German | de | ✅ Complete | 85% | High | 100M |
| Portuguese | pt | 🔄 In Progress | 60% | Medium | 260M |
| Italian | it | 🔄 In Progress | 55% | Medium | 65M |
| Russian | ru | 📋 Planned | 0% | Medium | 260M |
| Chinese (Simplified) | zh-CN | 📋 Planned | 0% | Medium | 1.1B |
| Japanese | ja | 📋 Planned | 0% | Low | 125M |
| Korean | ko | 📋 Planned | 0% | Low | 75M |

## Translation Workflow

### 1. Content Identification

#### Source Content Types
- **UI Strings**: Buttons, labels, messages, tooltips
- **Help Content**: User guides, FAQs, tutorials
- **Marketing Content**: Website copy, blog posts, social media
- **Legal Content**: Terms of service, privacy policies
- **API Documentation**: Endpoint descriptions, error messages
- **Email Templates**: Welcome emails, notifications

#### Content Classification
```json
{
  "content_type": "ui_string",
  "priority": "high",
  "context": "login_screen",
  "max_length": 50,
  "placeholders": ["username"],
  "screenshots": ["login_screen.png"],
  "notes": "Keep it short and friendly"
}
```

### 2. String Extraction

#### Automated Extraction
```bash
# Flutter app strings
flutter pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/**/*.dart

# React app strings
i18next-scanner --config i18next-scanner.config.js

# Documentation strings
crowdin upload sources --config crowdin.yml
```

#### Manual Extraction Process
1. **Identify new strings** in code changes
2. **Add context information** for translators
3. **Include screenshots** when helpful
4. **Specify character limits** for UI elements
5. **Mark placeholders** and formatting requirements

### 3. Translation Process

#### Translation Platform Integration
```yaml
# Crowdin configuration
project_id: "katya"
api_token: ${{ secrets.CROWDIN_TOKEN }}
base_path: "."

files:
  - source: "/lib/l10n/app_en.arb"
    translation: "/lib/l10n/app_%two_letters_code%.arb"
  - source: "/web/locales/en/*.json"
    translation: "/web/locales/%two_letters_code%/%original_file_name%"
  - source: "/docs/**/*.md"
    translation: "/docs/%two_letters_code%/%original_file_name%"
```

#### Translator Guidelines
- **Maintain context**: Use provided screenshots and descriptions
- **Be consistent**: Follow established terminology
- **Consider culture**: Adapt content for local preferences
- **Respect limits**: Stay within character limits
- **Test translations**: Review in actual UI context

### 4. Quality Assurance

#### Automated Quality Checks
```python
# Translation quality validation
def validate_translation(source, translation, language):
    """Validate translation quality and format"""

    # Check for common issues
    issues = []

    # Placeholder validation
    source_placeholders = extract_placeholders(source)
    translation_placeholders = extract_placeholders(translation)

    if source_placeholders != translation_placeholders:
        issues.append("Placeholder mismatch")

    # Length validation
    if len(translation) > len(source) * 2:
        issues.append("Translation too long")

    # Character validation
    if not is_valid_for_language(translation, language):
        issues.append("Invalid characters for language")

    return issues

# Run validation
issues = validate_translation("Hello {name}!", "Hola {name}!", "es")
if issues:
    print(f"Validation issues: {issues}")
```

#### Manual Review Process
1. **Context Review**: Check translation fits the context
2. **Cultural Review**: Ensure cultural appropriateness
3. **Technical Review**: Verify technical accuracy
4. **UI Review**: Test in actual application interface
5. **Stakeholder Review**: Get feedback from native speakers

### 5. Integration and Deployment

#### Continuous Integration
```yaml
# GitHub Actions for translation deployment
name: Translation Deployment

on:
  push:
    branches: [ main ]
    paths:
      - 'lib/l10n/*.arb'
      - 'web/locales/**/*.json'

jobs:
  deploy-translations:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Download translations
        uses: crowdin/github-action@v1
        with:
          download_translations: true
        env:
          CROWDIN_PERSONAL_TOKEN: ${{ secrets.CROWDIN_TOKEN }}

      - name: Generate Flutter localizations
        run: flutter pub run intl_translation:generate_from_arb lib/**/*.dart lib/l10n/*.arb

      - name: Build and test
        run: |
          flutter build apk --split-per-abi
          flutter test

      - name: Deploy to staging
        if: success()
        run: |
          # Deploy to staging environment
          echo "Deploying translations to staging"

      - name: Create release
        if: github.ref == 'refs/heads/main'
        run: |
          # Create release with translations
          echo "Creating production release"
```

## Translation Memory and Glossary

### Translation Memory
```json
{
  "source": "Welcome to Katya",
  "translations": {
    "es": "Bienvenido a Katya",
    "fr": "Bienvenue sur Katya",
    "de": "Willkommen bei Katya"
  },
  "context": "login_screen",
  "last_updated": "2024-01-15",
  "usage_count": 5
}
```

### Terminology Glossary
```json
{
  "terms": {
    "room": {
      "en": "Room",
      "es": "Sala",
      "fr": "Salle",
      "de": "Raum",
      "context": "Chat room or conversation space",
      "do_not_translate": false
    },
    "message": {
      "en": "Message",
      "es": "Mensaje",
      "fr": "Message",
      "de": "Nachricht",
      "context": "Chat message",
      "do_not_translate": false
    }
  }
}
```

## Tools and Platforms

### Translation Platforms
- **Crowdin**: Primary translation platform
- **Lokalise**: Alternative platform for complex projects
- **Transifex**: Enterprise-grade translation management
- **Phrase**: Modern platform with strong API

### Development Tools
- **Flutter Intl**: VS Code extension for Flutter i18n
- **i18next**: JavaScript internationalization framework
- **react-i18next**: React integration for i18next
- **gettext**: Traditional translation tool for documentation

### Quality Assurance Tools
- **LanguageTool**: Grammar and style checking
- **DeepL**: AI-powered translation assistance
- **Google Translate API**: Automated translation for initial drafts
- **Custom validation scripts**: Project-specific quality checks

## Metrics and Reporting

### Translation Metrics
- **Coverage**: Percentage of content translated per language
- **Quality Score**: Average quality rating of translations
- **Time to Complete**: Average time for translation completion
- **Update Frequency**: How often translations are updated

### Performance Metrics
- **Load Time**: Impact of translations on app load time
- **Bundle Size**: Size increase due to translation files
- **Memory Usage**: Memory impact of loaded translations
- **Cache Hit Rate**: Effectiveness of translation caching

### Usage Analytics
```javascript
// Track translation usage
i18next.on('languageChanged', (lng) => {
  analytics.track('language_changed', {
    language: lng,
    user_id: getCurrentUserId(),
    timestamp: new Date().toISOString()
  });
});

// Track missing translations
i18next.on('missingKey', (lng, ns, key, fallbackValue) => {
  analytics.track('missing_translation', {
    language: lng,
    namespace: ns,
    key: key,
    fallback: fallbackValue
  });
});
```

## Cultural Adaptation

### Regional Preferences
```javascript
// Date format preferences by region
const dateFormats = {
  'en-US': 'MM/dd/yyyy',
  'en-GB': 'dd/MM/yyyy',
  'es-ES': 'dd/mm/yyyy',
  'es-MX': 'dd/mm/yyyy',
  'fr-FR': 'dd/mm/yyyy',
  'de-DE': 'dd.mm.yyyy'
};

// Currency preferences
const currencyFormats = {
  'en-US': { symbol: '$', position: 'before' },
  'es-ES': { symbol: '€', position: 'after' },
  'fr-FR': { symbol: '€', position: 'after' },
  'de-DE': { symbol: '€', position: 'before' }
};
```

### Content Localization
- **Images and Icons**: Use culturally appropriate visuals
- **Colors**: Consider color meanings in different cultures
- **Numbers**: Format numbers according to local conventions
- **Units**: Use appropriate measurement units (metric vs imperial)

## Automation and Integration

### API Integration
```python
# Translation platform API integration
import requests

class TranslationManager:
    def __init__(self, api_key, project_id):
        self.api_key = api_key
        self.project_id = project_id
        self.base_url = "https://api.crowdin.com/api/v2"

    def upload_source_files(self, files):
        """Upload source files for translation"""
        url = f"{self.base_url}/projects/{self.project_id}/files"
        headers = {"Authorization": f"Bearer {self.api_key}"}

        for file_path in files:
            with open(file_path, 'rb') as f:
                files = {'file': f}
                response = requests.post(url, headers=headers, files=files)
                print(f"Uploaded {file_path}: {response.status_code}")

    def download_translations(self, language_codes):
        """Download completed translations"""
        for lang_code in language_codes:
            url = f"{self.base_url}/projects/{self.project_id}/translations/{lang_code}"
            headers = {"Authorization": f"Bearer {self.api_key}"}

            response = requests.get(url, headers=headers)
            if response.status_code == 200:
                # Save translation file
                with open(f"translations/{lang_code}.json", 'w') as f:
                    f.write(response.text)
```

### Webhook Integration
```javascript
// Handle translation updates via webhooks
app.post('/webhooks/crowdin', (req, res) => {
  const { event, project, file } = req.body;

  if (event === 'file.translated') {
    console.log(`File translated: ${file.name}`);

    // Trigger CI/CD pipeline
    triggerDeployment(project.id, file.language);

    // Notify team
    notifyTeam('Translation completed', {
      project: project.name,
      file: file.name,
      language: file.language
    });
  }

  res.status(200).send('OK');
});
```

## Training and Resources

### Translator Training
- **Platform Training**: How to use translation platforms
- **Style Guide**: Project-specific translation guidelines
- **Glossary Training**: Understanding project terminology
- **Quality Standards**: What makes a good translation

### Developer Training
- **i18n Best Practices**: How to write internationalizable code
- **String Extraction**: How to properly extract strings
- **Context Provision**: How to provide good context for translators
- **Testing**: How to test internationalized applications

## Budget and Resource Planning

### Translation Cost Estimation
```python
def estimate_translation_cost(source_words, languages, complexity='medium'):
    """Estimate translation costs"""

    rates = {
        'simple': 0.10,    # $0.10 per word
        'medium': 0.15,    # $0.15 per word
        'complex': 0.25    # $0.25 per word
    }

    base_rate = rates[complexity]
    total_cost = source_words * len(languages) * base_rate

    # Add platform fees (10%)
    platform_fee = total_cost * 0.10

    # Add review costs (20% of base)
    review_cost = total_cost * 0.20

    return {
        'translation_cost': total_cost,
        'platform_fee': platform_fee,
        'review_cost': review_cost,
        'total_cost': total_cost + platform_fee + review_cost
    }
```

### Resource Allocation
- **Full-time Translators**: 2-3 dedicated translators
- **Reviewers**: Native speakers for quality assurance
- **Project Managers**: 1 coordinator for translation projects
- **Tools and Platforms**: Subscription to translation platforms

## Compliance and Legal

### Data Protection
- **Translator Agreements**: NDA and data protection agreements
- **Content Security**: Secure handling of sensitive content
- **Privacy Compliance**: GDPR and privacy regulation compliance
- **IP Protection**: Protection of intellectual property

### Quality Standards
- **ISO 17100**: Translation services quality standard
- **Industry Best Practices**: Following localization industry standards
- **Client Requirements**: Meeting specific client quality requirements
- **Continuous Improvement**: Regular quality assessments and improvements

## Monitoring and Analytics

### Translation Analytics
```sql
-- Translation completion tracking
SELECT
  language_code,
  COUNT(*) as total_strings,
  SUM(CASE WHEN translated_at IS NOT NULL THEN 1 ELSE 0 END) as translated_strings,
  ROUND(
    SUM(CASE WHEN translated_at IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2
  ) as completion_percentage
FROM translations
GROUP BY language_code
ORDER BY completion_percentage DESC;

-- Translation quality metrics
SELECT
  language_code,
  AVG(quality_score) as avg_quality,
  COUNT(*) as review_count,
  SUM(CASE WHEN quality_score >= 8 THEN 1 ELSE 0 END) as high_quality_count
FROM translation_reviews
GROUP BY language_code;
```

### Performance Monitoring
- **Translation Load Times**: Monitor impact on application performance
- **Cache Effectiveness**: Track translation cache hit rates
- **Error Rates**: Monitor translation loading errors
- **User Experience**: Track user satisfaction with translations

## Future Enhancements

### Planned Improvements
- **Machine Translation Integration**: Use AI for initial translations
- **Real-time Collaboration**: Live collaboration between translators
- **Advanced Quality Assurance**: AI-powered quality checking
- **Automated Context Extraction**: Better context provision for translators
- **Mobile Translation**: Translation on mobile devices
- **Voice Translation**: Support for voice-based content

### Technology Roadmap
- **Neural Machine Translation**: Improve automated translation quality
- **Computer-Aided Translation**: Better tools for human translators
- **Translation Analytics**: Advanced analytics and reporting
- **Integration APIs**: Better integration with development workflows

## Contact Information

- **Translation Manager**: translations@katya.rechain.network
- **i18n Technical Lead**: i18n@katya.rechain.network
- **Quality Assurance**: qa@katya.rechain.network
- **Platform Support**: platform-support@katya.rechain.network

## References

- [Crowdin Documentation](https://support.crowdin.com/)
- [Flutter Internationalization](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
- [i18next Documentation](https://www.i18next.com/)
- [Unicode CLDR](https://cldr.unicode.org/)
- [ISO 17100 Standard](https://www.iso.org/standard/59149.html)

---

*This translation management system ensures high-quality, consistent translations across all Katya platforms and languages. Regular monitoring and improvement maintain translation quality and user satisfaction.*
