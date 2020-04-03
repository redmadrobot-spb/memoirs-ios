fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios publish_test_app
```
fastlane ios publish_test_app
```
Bump build and publish Robologs Test App to App Center.

To publish app you need to specify APP_CENTER_API_TOKEN in your enviroment.

API token is generated in https://appcenter.ms/settings/apitokens with full access.

Usage: `fastlane publish_test_app [bump_version:true]`

  Parameters:

  - bump_version: true/false. If true fastlane will also bump version, default: false.
### ios bump_version
```
fastlane ios bump_version
```
Bump minor part of version (example 0.1.4 -> 0.1.5).

Example: `fastlane bump_version target:Robologs`

Parameters:

  target - xcodeproj target to bump.

    Available targets:

    - Example - Robologs Test App

    - Robologs - Robologs SDK

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
