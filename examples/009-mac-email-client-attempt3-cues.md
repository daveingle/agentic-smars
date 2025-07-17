# Mac Email Client Architecture Cues

## Core Architecture Cues

(cue swiftui_architecture_pattern
  ⊨ suggests: Adopt MVVM pattern with SwiftUI for clear separation of concerns and testability
)

(cue core_data_optimization
  ⊨ suggests: Use Core Data with CloudKit for seamless sync across devices and offline capability
)

(cue combine_reactive_streams
  ⊨ suggests: Leverage Combine framework for handling asynchronous API responses and UI updates
)

(cue async_await_api_calls
  ⊨ suggests: Use Swift's async/await for modern API integration with proper error handling
)

## API Integration Cues

(cue oauth2_secure_flow
  ⊨ suggests: Implement OAuth2 PKCE flow for enhanced security without client secrets
)

(cue api_rate_limiting_strategy
  ⊨ suggests: Implement exponential backoff and request queuing for API rate limit management
)

(cue delta_sync_optimization
  ⊨ suggests: Use delta sync tokens from Microsoft Graph and Gmail API for efficient updates
)

(cue webhook_push_notifications
  ⊨ suggests: Implement push notifications via webhooks for real-time email updates
)

## Performance Cues

(cue lazy_loading_messages
  ⊨ suggests: Implement lazy loading for message lists to handle large mailboxes efficiently
)

(cue background_sync_optimization
  ⊨ suggests: Use NSBackgroundAppRefreshTask for intelligent background synchronization
)

(cue memory_management_strategy
  ⊨ suggests: Implement proper memory management for attachment handling and image caching
)

(cue search_indexing_optimization
  ⊨ suggests: Use Core Spotlight for system-wide search integration and fast local search
)

## Security Cues

(cue keychain_secure_storage
  ⊨ suggests: Store OAuth tokens and credentials in Keychain with proper access controls
)

(cue app_transport_security_config
  ⊨ suggests: Configure App Transport Security for secure network communications
)

(cue sandbox_entitlements_minimal
  ⊨ suggests: Request minimal sandbox entitlements necessary for functionality
)

(cue code_signing_hardened_runtime
  ⊨ suggests: Enable Hardened Runtime for enhanced security and notarization requirements
)

## User Experience Cues

(cue unified_inbox_smart_filtering
  ⊨ suggests: Implement smart filtering with ML-based categorization for unified inbox
)

(cue accessibility_voiceover_support
  ⊨ suggests: Ensure full VoiceOver support and keyboard navigation for accessibility
)

(cue dark_mode_dynamic_colors
  ⊨ suggests: Use dynamic colors and proper contrast ratios for Dark Mode support
)

(cue notification_management_granular
  ⊨ suggests: Provide granular notification controls per account and folder
)

## Testing Cues

(cue unit_test_coverage_comprehensive
  ⊨ suggests: Aim for 80%+ unit test coverage with focus on business logic and API integration
)

(cue ui_testing_automated
  ⊨ suggests: Implement automated UI testing for critical user flows and accessibility
)

(cue performance_testing_benchmarks
  ⊨ suggests: Establish performance benchmarks for sync operations and UI responsiveness
)

(cue security_testing_penetration
  ⊨ suggests: Conduct security testing for OAuth flows and credential storage
)

## Deployment Cues

(cue app_store_guidelines_compliance
  ⊨ suggests: Ensure compliance with App Store Review Guidelines for email applications
)

(cue automatic_updates_sparkle
  ⊨ suggests: Implement Sparkle framework for automatic updates outside App Store
)

(cue crash_reporting_integration
  ⊨ suggests: Integrate crash reporting service for production monitoring and debugging
)

(cue analytics_privacy_compliant
  ⊨ suggests: Implement privacy-compliant analytics for understanding user behavior
)