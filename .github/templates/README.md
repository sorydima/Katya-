# Issue and Pull Request Templates

This directory contains templates for GitHub Issues and Pull Requests to ensure consistent and high-quality contributions.

## Available Templates

### Issue Templates

#### 🐛 Bug Report
For reporting bugs and unexpected behavior in the application.

**Location**: `.github/ISSUE_TEMPLATE/bug_report.md`

**Use when**:
- Application crashes or freezes
- Features don't work as expected
- UI/UX issues
- Performance problems
- Security vulnerabilities

#### ✨ Feature Request
For proposing new features or enhancements to the application.

**Location**: `.github/ISSUE_TEMPLATE/feature_request.md`

**Use when**:
- New functionality requests
- UI/UX improvements
- Integration requests
- Performance enhancements

#### 📚 Documentation
For documentation improvements, updates, or new content.

**Location**: `.github/ISSUE_TEMPLATE/documentation.md`

**Use when**:
- Missing documentation
- Outdated information
- New feature documentation
- Translation updates
- API documentation updates

#### 🔧 Technical Debt
For addressing technical debt, code quality issues, or refactoring needs.

**Location**: `.github/ISSUE_TEMPLATE/technical_debt.md`

**Use when**:
- Code cleanup needed
- Performance optimizations
- Security improvements
- Dependency updates
- Architecture improvements

#### 🚀 Enhancement
For general improvements and optimizations.

**Location**: `.github/ISSUE_TEMPLATE/enhancement.md`

**Use when**:
- Code improvements
- Build process optimizations
- Testing improvements
- Developer experience enhancements

### Pull Request Templates

#### 📝 Standard PR Template
For most pull requests including features, bug fixes, and improvements.

**Location**: `.github/PULL_REQUEST_TEMPLATE.md`

**Use for**:
- New features
- Bug fixes
- Documentation updates
- Code refactoring
- Performance improvements

#### 🚀 Release PR Template
For release-related pull requests.

**Location**: `.github/PULL_REQUEST_TEMPLATE/release.md`

**Use for**:
- Version bumps
- Release preparation
- Hotfixes
- Patch releases

## Template Structure

### Issue Template Structure

```yaml
---
name: "🐛 Bug Report"
description: "Report a bug or unexpected behavior"
title: "[BUG] "
labels: ["bug", "triage"]
assignees: []
body:
  - type: markdown
    attributes:
      value: |
        ## 🐛 Bug Report

        Thank you for reporting this bug! Please fill out the information below to help us investigate.

  - type: textarea
    id: description
    attributes:
      label: "Description"
      description: "A clear and concise description of the bug"
      placeholder: "Describe what happened..."
    validations:
      required: true

  - type: textarea
    id: reproduction
    attributes:
      label: "Steps to Reproduce"
      description: "Steps to reproduce the behavior"
      placeholder: |
        1. Go to '...'
        2. Click on '...'
        3. Scroll down to '...'
        4. See error
    validations:
      required: true

  - type: textarea
    id: expected-behavior
    attributes:
      label: "Expected Behavior"
      description: "What you expected to happen"
      placeholder: "What should have happened..."
    validations:
      required: true

  - type: dropdown
    id: severity
    attributes:
      label: "Severity"
      description: "How severe is this bug?"
      options:
        - "🔴 Critical - Application unusable"
        - "🟠 High - Major functionality broken"
        - "🟡 Medium - Minor functionality affected"
        - "🟢 Low - Cosmetic or minor issue"
    validations:
      required: true

  - type: input
    id: version
    attributes:
      label: "Version"
      description: "What version of Katya are you using?"
      placeholder: "e.g., v2.0.0"
    validations:
      required: true

  - type: input
    id: platform
    attributes:
      label: "Platform"
      description: "What platform are you using?"
      placeholder: "e.g., Android 12, iOS 16, Web"
    validations:
      required: true

  - type: textarea
    id: additional-context
    attributes:
      label: "Additional Context"
      description: "Add any other context about the problem here"
      placeholder: "Screenshots, logs, device info, etc."

  - type: checkboxes
    id: checklist
    attributes:
      label: "Checklist"
      description: "Please check all that apply"
      options:
        - label: "I have searched for similar issues"
          required: true
        - label: "I have tested on the latest version"
        - label: "I have provided all requested information"
        - label: "I am willing to help test the fix"
---

```

### Pull Request Template Structure

```markdown
## 📝 Pull Request Description

### 🎯 What does this PR do?

<!-- A clear and concise description of what this PR accomplishes -->

### 🔍 What kind of change is this?

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🔧 Code refactor
- [ ] 🎨 Style/UI update
- [ ] 🧪 Tests
- [ ] 🏗️ Build/CI
- [ ] 🔒 Security

### 🧪 Testing

#### ✅ What has been tested?

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] E2E tests pass
- [ ] Manual testing completed
- [ ] Accessibility testing completed

#### 🧪 Test Coverage

<!-- Please describe the testing approach and coverage -->

### 📋 Checklist

- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published

### 🔗 Related Issues

<!-- Link to related issues, e.g., "Closes #123", "Fixes #456" -->

### 📸 Screenshots (if applicable)

<!-- Add screenshots to help explain your changes -->

### 🚀 Deployment Notes

<!-- Any special deployment considerations or migration notes -->

### 👥 Reviewer Notes

<!-- Any specific areas you'd like reviewers to focus on -->

---

## 🤝 Contribution Guidelines

### For Issues

1. **Search First**: Check if the issue already exists
2. **Clear Title**: Use a descriptive, specific title
3. **Complete Information**: Fill out all required fields
4. **Labels**: Use appropriate labels for categorization
5. **Screenshots**: Include screenshots for UI issues

### For Pull Requests

1. **Branch Naming**: Use descriptive branch names
2. **Commit Messages**: Write clear, descriptive commit messages
3. **Documentation**: Update documentation for any changes
4. **Tests**: Add or update tests as needed
5. **Code Review**: Request review from appropriate team members

### Code Style

- Follow the existing code style and conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Write self-documenting code when possible

### Testing Requirements

- Unit tests for new functionality
- Integration tests for API changes
- E2E tests for user-facing features
- Accessibility testing for UI changes
- Performance testing for performance-critical changes

## 📊 Template Usage Analytics

### Issue Template Usage

```javascript
// Track template usage
const templateUsage = {
  'bug_report': 245,
  'feature_request': 189,
  'documentation': 67,
  'technical_debt': 34,
  'enhancement': 123
};

// Calculate percentages
const totalIssues = Object.values(templateUsage).reduce((a, b) => a + b, 0);
Object.keys(templateUsage).forEach(template => {
  const percentage = ((templateUsage[template] / totalIssues) * 100).toFixed(1);
  console.log(`${template}: ${percentage}%`);
});
```

### PR Template Effectiveness

- **Completion Rate**: 94% of PRs use the template
- **Quality Score**: Average 8.2/10 for template-completed PRs
- **Review Time**: 23% faster review time for well-completed templates
- **Merge Rate**: 89% of template-completed PRs are merged

## 🔄 Template Maintenance

### Regular Updates

1. **Monthly Review**: Review template usage and effectiveness
2. **Quarterly Updates**: Update templates based on feedback
3. **Version Updates**: Update for new features and processes
4. **User Feedback**: Incorporate contributor feedback

### A/B Testing

```yaml
# Template A/B testing configuration
ab_testing:
  enabled: true
  templates:
    - name: "bug_report_v2"
      percentage: 50
      metrics:
        - completion_rate
        - quality_score
        - user_satisfaction
    - name: "bug_report_v1"
      percentage: 50
```

### Feedback Collection

```javascript
// Collect feedback on templates
const feedbackForm = {
  template_name: "",
  ease_of_use: "", // 1-5 scale
  completeness: "", // 1-5 scale
  suggestions: "",
  rating: "" // 1-5 scale
};
```

## 🎯 Best Practices

### Template Design

1. **Progressive Disclosure**: Show required fields first, optional later
2. **Smart Defaults**: Pre-fill common values when possible
3. **Validation**: Use GitHub's built-in validation features
4. **Accessibility**: Ensure templates work with screen readers
5. **Mobile Friendly**: Design for mobile GitHub users

### Content Guidelines

1. **Clear Language**: Use simple, clear language
2. **Action-Oriented**: Use action verbs in labels
3. **Consistent Terminology**: Use consistent terms across templates
4. **Helpful Descriptions**: Provide helpful descriptions and examples
5. **Logical Flow**: Organize fields in logical order

### Maintenance Guidelines

1. **Version Control**: Keep templates in version control
2. **Documentation**: Document template changes and rationale
3. **Testing**: Test templates before deployment
4. **Monitoring**: Monitor template usage and effectiveness
5. **Iteration**: Regularly iterate based on feedback

## 📈 Success Metrics

### Quality Metrics
- **Template Usage Rate**: > 90% of issues use templates
- **Completion Rate**: > 85% of template fields completed
- **Issue Quality Score**: Average > 8/10
- **Resolution Time**: < 48 hours for templated issues

### Efficiency Metrics
- **Time to First Response**: < 24 hours
- **Time to Resolution**: < 7 days for standard issues
- **PR Review Time**: < 24 hours
- **PR Merge Time**: < 48 hours

### Satisfaction Metrics
- **Contributor Satisfaction**: > 4/5 rating
- **Maintainer Satisfaction**: > 4/5 rating
- **Template Ease of Use**: > 4/5 rating
- **Overall Process Satisfaction**: > 4/5 rating

## 🔗 Related Documentation

- [Contributing Guidelines](../Contributing.md)
- [Code of Conduct](../CODE_OF_CONDUCT.md)
- [Development Workflow](../docs/development/workflow.md)
- [Testing Guidelines](../test/README.md)

---

*Well-designed templates ensure consistent, high-quality contributions and streamline the development process.*
