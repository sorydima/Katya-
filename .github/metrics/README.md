# Custom Metrics & KPIs

This directory contains custom metrics, KPIs, and performance indicators for the Katya project.

## Overview

Custom metrics help us track and improve:
- **Product Performance**: User engagement, retention, and satisfaction
- **Development Efficiency**: Code quality, delivery speed, and team productivity
- **Business Impact**: User growth, revenue metrics, and market penetration
- **Quality Assurance**: Bug rates, test coverage, and user-reported issues

## Key Performance Indicators (KPIs)

### Product Metrics

#### User Engagement KPIs
- **Daily Active Users (DAU)**: Number of unique users active daily
- **Monthly Active Users (MAU)**: Number of unique users active monthly
- **Session Duration**: Average time users spend in the app
- **Screen Flow**: Most common user navigation paths
- **Feature Adoption**: Percentage of users using specific features

#### User Retention KPIs
- **Day 1 Retention**: Percentage of users returning after first day
- **Day 7 Retention**: Percentage of users returning after first week
- **Day 30 Retention**: Percentage of users returning after first month
- **Churn Rate**: Percentage of users who stop using the app
- **Cohort Analysis**: Retention trends by user acquisition date

#### User Satisfaction KPIs
- **App Store Rating**: Average rating on app stores
- **Net Promoter Score (NPS)**: Likelihood of users to recommend the app
- **User Feedback Score**: Average satisfaction from user feedback
- **Support Ticket Resolution**: Average time to resolve user issues

### Development Metrics

#### Code Quality KPIs
- **Test Coverage**: Percentage of code covered by automated tests
- **Code Complexity**: Average cyclomatic complexity of functions
- **Technical Debt Ratio**: Ratio of technical debt to total codebase
- **Code Review Coverage**: Percentage of code changes reviewed
- **Static Analysis Score**: Automated code quality assessment

#### Delivery Performance KPIs
- **Deployment Frequency**: Number of deployments per day/week
- **Lead Time for Changes**: Time from commit to production
- **Change Failure Rate**: Percentage of deployments causing failures
- **Mean Time to Recovery (MTTR)**: Average time to recover from incidents
- **Build Success Rate**: Percentage of successful CI/CD builds

#### Team Productivity KPIs
- **Velocity**: Story points completed per sprint
- **Throughput**: Number of completed tasks per week
- **Code Churn**: Lines of code changed/reverted
- **Review Turnaround Time**: Average time for code review completion
- **Sprint Goal Success Rate**: Percentage of sprint goals achieved

### Business Metrics

#### Growth KPIs
- **User Acquisition**: Number of new users per month
- **Market Share**: Percentage of market captured
- **Revenue per User**: Average revenue generated per user
- **Customer Lifetime Value (CLV)**: Total value from a customer over time
- **Viral Coefficient**: Average number of new users from each existing user

#### Financial KPIs
- **Monthly Recurring Revenue (MRR)**: Monthly subscription revenue
- **Customer Acquisition Cost (CAC)**: Cost to acquire a new customer
- **Churn Rate**: Percentage of customers lost per month
- **Gross Margin**: Revenue minus cost of goods sold
- **Burn Rate**: Monthly expenditure rate

## Custom Metrics Implementation

### Metrics Collection Framework

#### Event Tracking
```dart
// lib/analytics/custom_metrics.dart
class CustomMetrics {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // User Engagement Events
  static Future<void> trackUserEngagement({
    required String screenName,
    required Duration sessionDuration,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: 'user_engagement',
      parameters: {
        'screen_name': screenName,
        'session_duration': sessionDuration.inSeconds,
        'engagement_type': 'screen_view',
        ...?parameters,
      },
    );
  }

  // Feature Usage Events
