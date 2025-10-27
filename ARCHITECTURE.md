# Katya Project Architecture

This document outlines the scaled architecture of the Katya project, including verticals, horizontals, bridges, and multi-platform support.

## Verticals (Feature Modules)

- **Messaging**: Core messaging functionality, chat rooms, and communication features.
- **Blockchain**: Wallet integration, Web3 support, and cryptocurrency features.
- **Trust Network**: Reputation systems, verification, and security features.
- **Backup**: Data backup, recovery, and synchronization.
- **Analytics**: Performance monitoring, user analytics, and reporting.

## Horizontals (Architectural Layers)

- **Presentation Layer**: UI components, widgets, and user interface logic.
- **Domain Layer**: Business logic, use cases, and domain entities.
- **Data Layer**: Data repositories, storage, and external API integrations.

## Platforms Supported

- **Mobile**: Android, iOS
- **Desktop**: macOS, Windows, Linux
- **Web**: Web browsers
- **Specialized**: WinUWP, Aurora OS

## Build System

- Enhanced Fastlane configuration for multi-platform builds.
- CI/CD pipelines for GitHub, GitLab, and other hosting platforms.
- Automated icon generation for all platforms.

## Bridges

- Integration bridges for external services (Discord, Slack, Telegram, etc.).
- Modular bridge system for easy extension.

## Git Hosting Integrations

- **GitHub**: Full CI/CD with Actions, releases, and package management.
- **GitLab**: Pipelines for builds, tests, and deployments.
- **Domestic (Russian)**: SourceCraft, GitFlic, GitVerse.
- **International**: Canadian, Israeli, Arabic, Australian, Chinese platforms.

## Documentation

- Platform-specific documentation in `docs/platform-specific/`.
- Git hosting documentation in `docs/git-hostings/`.
- Architecture guides in `lib/verticals/` and `lib/horizontals/`.

## Getting Started

1. Clone the repository.
2. Run `flutter pub get`.
3. Choose your platform and run `flutter run -d <device>`.

For more details, refer to the specific platform and feature documentation.
