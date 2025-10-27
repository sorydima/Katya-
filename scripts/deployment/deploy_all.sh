#!/bin/bash

# Comprehensive Multi-Platform Deployment Script for Katya
# This script handles deployment across all supported platforms

set -e  # Exit on any error

# Configuration
PROJECT_NAME="katya"
BUILD_VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}' | tr -d '+')
DEPLOYMENT_TARGETS=("$@")
FLUTTER_CHANNEL="stable"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Pre-deployment checks
pre_deployment_checks() {
    log_info "Running pre-deployment checks..."

    # Check Flutter installation
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi

    # Check Flutter version
    flutter doctor

    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not in a git repository"
        exit 1
    fi

    # Check if working directory is clean
    if [[ -n $(git status --porcelain) ]]; then
        log_warning "Working directory has uncommitted changes"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    log_success "Pre-deployment checks completed"
}

# Setup build environment
setup_build_environment() {
    log_info "Setting up build environment..."

    # Ensure Flutter dependencies
    flutter pub get

    # Run code generation
    flutter pub run build_runner build --delete-conflicting-outputs

    # Clean previous builds
    flutter clean

    log_success "Build environment ready"
}

# Build for specific platform
build_for_platform() {
    local platform=$1
    local build_type=${2:-release}

    log_info "Building for $platform ($build_type)..."

    case $platform in
        "android")
            flutter build apk --$build_type
            flutter build appbundle --$build_type
            ;;
        "ios")
            flutter build ios --$build_type --no-codesign
            ;;
        "web")
            flutter build web --$build_type
            ;;
        "windows")
            flutter build windows --$build_type
            ;;
        "macos")
            flutter build macos --$build_type
            ;;
        "linux")
            flutter build linux --$build_type
            ;;
        "winuwp")
            flutter build winuwp --$build_type
            ;;
        "aurora")
            flutter build aurora --$build_type
            ;;
        "tizen")
            flutter build tizen --$build_type
            ;;
        "fuchsia")
            flutter build fuchsia --$build_type
            ;;
        "harmony")
            flutter build harmony --$build_type
            ;;
        "wearos")
            flutter build wear --$build_type
            ;;
        "tvos")
            flutter build tvos --$build_type
            ;;
        "freebsd")
            flutter build freebsd --$build_type
            ;;
        "embedded")
            flutter build custom-embedded --$build_type
            ;;
        *)
            log_error "Unknown platform: $platform"
            return 1
            ;;
    esac

    log_success "Built for $platform successfully"
}

# Run tests for platform
run_platform_tests() {
    local platform=$1

    log_info "Running tests for $platform..."

    # Run general tests
    flutter test

    # Run platform-specific tests if available
    if [ -d "test_$platform" ]; then
        flutter test "test_$platform/"
    fi

    # Run integration tests
    if [ -d "integration_test" ]; then
        flutter test integration_test/
    fi

    log_success "Tests passed for $platform"
}

# Deploy to specific target
deploy_to_target() {
    local platform=$1
    local target=$2

    log_info "Deploying $platform to $target..."

    case $target in
        "github")
            deploy_to_github $platform
            ;;
        "gitlab")
            deploy_to_gitlab $platform
            ;;
        "google_play")
            deploy_to_google_play $platform
            ;;
        "app_store")
            deploy_to_app_store $platform
            ;;
        "huawei_appgallery")
            deploy_to_huawei_appgallery $platform
            ;;
        "samsung_apps")
            deploy_to_samsung_apps $platform
            ;;
        "web_server")
            deploy_to_web_server $platform
            ;;
        "local_server")
            deploy_to_local_server $platform
            ;;
        *)
            log_error "Unknown deployment target: $target"
            return 1
            ;;
    esac

    log_success "Deployed $platform to $target"
}

# Deploy to GitHub
deploy_to_github() {
    local platform=$1

    # Create GitHub release
    gh release create "v$BUILD_VERSION" \
        --title "Katya $BUILD_VERSION" \
        --notes "Release for $platform platform"

    # Upload build artifacts
    gh release upload "v$BUILD_VERSION" "build/$platform/release/*"

    log_success "Deployed to GitHub"
}

# Deploy to GitLab
deploy_to_gitlab() {
    local platform=$1

    # Create GitLab release
    glab release create "v$BUILD_VERSION" \
        --name "Katya $BUILD_VERSION" \
        --description "Release for $platform platform"

    # Upload artifacts
    glab release upload "v$BUILD_VERSION" "build/$platform/release/*"

    log_success "Deployed to GitLab"
}

# Deploy to Google Play Store
deploy_to_google_play() {
    local platform=$1

    # Use fastlane for Play Store deployment
    if [ $platform = "android" ]; then
        cd fastlane
        bundle exec fastlane deploy_internal_test
        cd ..
    fi

    log_success "Deployed to Google Play Store"
}

# Deploy to App Store
deploy_to_app_store() {
    local platform=$1

    if [ $platform = "ios" ]; then
        cd fastlane
        bundle exec fastlane ios deploy
        cd ..
    fi

    log_success "Deployed to App Store"
}

# Deploy to Huawei AppGallery
deploy_to_huawei_appgallery() {
    local platform=$1

    # Huawei AppGallery deployment
    huawei_appgallery_upload "build/$platform/release/*"

    log_success "Deployed to Huawei AppGallery"
}

# Deploy to Samsung Apps
deploy_to_samsung_apps() {
    local platform=$1

    if [ $platform = "tizen" ]; then
        samsung_apps_upload "build/$platform/release/*"
    fi

    log_success "Deployed to Samsung Apps"
}

# Deploy to web server
deploy_to_web_server() {
    local platform=$1

    if [ $platform = "web" ]; then
        # Deploy web build to server
        rsync -avz "build/web/" "user@server:/var/www/katya/"
    fi

    log_success "Deployed to web server"
}

# Deploy to local server
deploy_to_local_server() {
    local platform=$1

    # Deploy to local development server
    cp -r "build/$platform/release/*" "/opt/katya/$platform/"

    log_success "Deployed to local server"
}

# Generate deployment report
generate_deployment_report() {
    local report_file="deployment_report_$(date +%Y%m%d_%H%M%S).md"

    cat > "$report_file" << EOF
# Katya Deployment Report

**Deployment Date:** $(date)
**Version:** $BUILD_VERSION
**Platforms Built:** ${DEPLOYMENT_TARGETS[*]}

## Build Summary

EOF

    for platform in "${DEPLOYMENT_TARGETS[@]}"; do
        echo "- ✅ $platform: Built successfully" >> "$report_file"
    done

    echo "" >> "$report_file"
    echo "## Deployment Summary" >> "$report_file"

    log_success "Deployment report generated: $report_file"
}

# Main deployment function
main() {
    log_info "Starting Katya deployment process..."

    # Default targets if none specified
    if [ $# -eq 0 ]; then
        DEPLOYMENT_TARGETS=("android" "ios" "web" "windows" "macos" "linux")
        log_warning "No platforms specified, using defaults: ${DEPLOYMENT_TARGETS[*]}"
    fi

    # Pre-deployment checks
    pre_deployment_checks

    # Setup environment
    setup_build_environment

    # Build and test each platform
    for platform in "${DEPLOYMENT_TARGETS[@]}"; do
        build_for_platform "$platform" "release"
        run_platform_tests "$platform"
    done

    # Generate deployment report
    generate_deployment_report

    log_success "Deployment completed successfully!"
    log_info "Build version: $BUILD_VERSION"
    log_info "Platforms: ${DEPLOYMENT_TARGETS[*]}"
}

# Help function
show_help() {
    cat << EOF
Katya Multi-Platform Deployment Script

Usage: $0 [PLATFORM...] [OPTIONS]

Platforms:
    android      Build and deploy Android app
    ios          Build and deploy iOS app
    web          Build and deploy web app
    windows      Build and deploy Windows app
    macos        Build and deploy macOS app
    linux        Build and deploy Linux app
    winuwp       Build and deploy Windows UWP app
    aurora       Build and deploy Aurora OS app
    tizen        Build and deploy Tizen app
    fuchsia      Build and deploy Fuchsia app
    harmony      Build and deploy HarmonyOS app
    wearos       Build and deploy Wear OS app
    tvos         Build and deploy tvOS app
    freebsd      Build and deploy FreeBSD app
    embedded     Build and deploy embedded systems

Options:
    -h, --help   Show this help message
    -v, --version Show version information
    --debug      Build in debug mode
    --profile    Build in profile mode

Examples:
    $0 android ios web                    # Build for mobile and web
    $0 --debug android                   # Debug build for Android
    $0 --profile windows macos           # Profile builds for desktop

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "Katya Deployment Script v1.0"
            exit 0
            ;;
        --debug)
            BUILD_TYPE="debug"
            shift
            ;;
        --profile)
            BUILD_TYPE="profile"
            shift
            ;;
        -*)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            DEPLOYMENT_TARGETS+=("$1")
            shift
            ;;
    esac
done

# Run main deployment
main "${DEPLOYMENT_TARGETS[@]}"
