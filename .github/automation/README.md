# Repository Automation

This directory contains automation scripts, tools, and configurations that streamline repository management and development workflows.

## Overview

Repository automation helps us:
- **Reduce manual tasks** and human error
- **Ensure consistency** across all repository operations
- **Improve efficiency** through automated workflows
- **Maintain quality** with automated checks and validations
- **Scale operations** as the project grows

## Automation Categories

### 1. Issue Management

#### Auto-Labeling
```yaml
# .github/workflows/auto-label.yml
name: Auto Label Issues and PRs

on:
  issues:
    types: [opened, edited]
  pull_request:
    types: [opened, edited]

jobs:
  auto-label:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/labeler@v4
        with:
          repo-token: ${{ secrets.GITHUB_TOKEN }}
          configuration-path: .github/labeler.yml
```

#### Label Configuration
```yaml
# .github/labeler.yml
version: 1

labels:
  - label: "bug"
    sync: true
    matcher:
      title: '/bug|fix|issue/i'
      body: '/bug|error|crash|fail/i'

  - label: "enhancement"
    sync: true
    matcher:
      title: '/feat|feature|enhancement/i'
      body: '/add|new|feature|enhancement/i'

  - label: "documentation"
    sync: true
    matcher:
      title: '/docs|documentation|readme/i'
      body: '/docs|documentation|readme|guide/i'

  - label: "breaking-change"
    sync: true
    matcher:
      title: '/breaking|major|incompatible/i'
      body: '/breaking|major|incompatible|migration/i'
```

#### Issue Templates
```yaml
# .github/ISSUE_TEMPLATE/bug-report.yml
name: Bug Report
description: Report a bug or issue
title: "[Bug]: "
labels: ["bug", "triage"]
assignees: []
body:
  - type: markdown
    attributes:
      value: |
        Thanks for taking the time to report a bug!
  - type: input
    id: version
    attributes:
      label: Version
      description: What version of Katya are you using?
      placeholder: "e.g., 2.0.1"
    validations:
      required: true
  - type: dropdown
    id: platform
    attributes:
      label: Platform
      description: What platform are you experiencing the issue on?
      options:
        - Android
        - iOS
        - Web
        - Desktop (Windows)
        - Desktop (macOS)
        - Desktop (Linux)
    validations:
      required: true
```

### 2. Pull Request Management

#### PR Validation
```yaml
# .github/workflows/pr-validation.yml
name: PR Validation

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]

jobs:
  validate-pr:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Validate PR title
        uses: amannn/action-semantic-pull-request@v5
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          types: |
            feat
            fix
            docs
            style
            refactor
            perf
            test
            chore
          requireScope: false

      - name: Validate PR size
        uses: codacy/git-version@2.7.1
        with:
          release-branch: main
          dev-branch: develop

      - name: Check for sensitive data
        run: |
          # Check for API keys, passwords, etc.
          if grep -r "password\|api_key\|secret" --include="*.dart" --include="*.js" --include="*.ts" .; then
            echo "❌ Sensitive data found in code"
            exit 1
          fi
```

#### Auto-Merge for Routine PRs
```yaml
# .github/workflows/auto-merge.yml
name: Auto Merge

on:
  pull_request:
    types: [labeled]

jobs:
  auto-merge:
    runs-on: ubuntu-latest
    if: contains(github.event.pull_request.labels.*.name, 'auto-merge')

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Enable auto-merge
        run: gh pr merge --auto --squash "$PR_URL"
        env:
          PR_URL: ${{ github.event.pull_request.html_url }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 3. Release Automation

#### Automated Releases
```yaml
# .github/workflows/release.yml
