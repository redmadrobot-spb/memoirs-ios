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
Publish Robologs Test App to App Center
### ios bump_version
```
fastlane ios bump_version
```
Publish Robologs Test App to App Center

Requires option target:<TARGET>

Available targets is:

- Example - Robologs Test App

- Robologs - Robologs SDK

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
