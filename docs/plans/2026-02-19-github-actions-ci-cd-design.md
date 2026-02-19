# GitHub Actions CI/CD Workflow Design

**Date**: 2026-02-19
**Project**: kitty_protocol

## Overview

Design an automated CI/CD workflow for the kitty_protocol Dart/Flutter package that:
1. Runs code analysis and tests on every push/PR
2. Automatically publishes to pub.dev when a version tag is pushed

## Goals

- **CI**: Automated code quality checks (analyze + test) on every code change
- **CD**: Automated publishing to pub.dev with version validation
- **Unattended**: Fully automated once configured, no manual intervention needed

## Requirements

1. Run `flutter analyze` and `flutter test` on every push/PR to main branch
2. Publish to pub.dev automatically when a git tag (e.g., v1.2.0) is pushed
3. Validate that the tag version matches pubspec.yaml version before publishing
4. Use official Flutter/Dart GitHub Actions for reliability

## Architecture

### Single Workflow File

```
.github/workflows/ci-cd.yml
```

Two jobs in a single workflow:

1. **ci** - Runs on every push/PR
   - Checkout code
   - Setup Flutter
   - `flutter pub get`
   - `flutter analyze`
   - `flutter test`

2. **publish** - Runs only on version tags
   - Depends on: ci job (must pass first)
   - Trigger: when git tag matches `v*` pattern
   - Same setup as ci
   - Version validation (tag version == pubspec version)
   - `flutter publish --pub-server pub.dev`

### Version Management

- **Tag format**: `v1.2.0` (v + semver)
- **Manual version bump**: Developer updates `version:` in pubspec.yaml before creating tag
- **Validation**: Workflow checks tag version matches pubspec.yaml version

## Data Flow

```
[Developer] --push commit--> [GitHub]
                              |
                              v
                        [CI Job]
                        - analyze
                        - test
                              |
                        [Pass?]
                         /      \
                       No       Yes
                        |         |
                        v         v
                    [Fail]    [Wait for tag]
                                  |
                                  v
                           [Push v1.2.0]
                                  |
                                  v
                        [Publish Job]
                        - validate version
                        - publish to pub.dev
```

## Error Handling

| Scenario | Handling |
|----------|----------|
| analyze fails | CI job fails, no publish |
| test fails | CI job fails, no publish |
| version mismatch | publish job fails with clear error |
| publish token missing | workflow fails (needs repo secret) |

## Security

- Use `GITHUB_TOKEN` for checkout (automatic)
- Use `PUB_DEV_PUBLISH_ACCESS_TOKEN` secret for pub.dev authentication
- Token setup: https://pub.dev/packages/kitty_protocol/settings

## Testing Strategy

- CI job must pass before any publish
- No parallel jobs to ensure sequential validation
- Version check prevents accidental wrong versions

## Implementation Plan

1. Create `.github/workflows/ci-cd.yml`
2. Add workflow_dispatch for manual testing
3. Document token setup in README

## References

- https://github.com/subosito/flutter-action
- https://flutter.dev/docs/deployment/cd
- https://docs.pub.dev/packages/hosting-and-domain/using-pub-dev
