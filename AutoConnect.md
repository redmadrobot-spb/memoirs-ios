# Bonjour (DNS-SD) Auto Connect for iOS

SDK contains two classes (BonjourServer, BonjourClient), that help with auto connection console applications to SDK that is being debugged with RemoteLogger turned on.

You usually do not need to use BonjourServer (it is integrated in Debug version of the SDK. BonjourClient can be easily used to find out connection id (Sender Id) of connected SDKs. Please refer to code for that.

## Agreements on DNS usage

- Domain: `local.`
- Type: `_robologs._tcp.`
- Name: `Robologs-UUID`. UUID here is needed so that client is able to catch service disappearance and match it to service and connection id.
- TXT structure:
  - `deviceId`: SHA256 hash of the UDID of the simulator device. It is being filled from `SIMULATOR_UDID` environment variable. It must look like this: `SHA256 digest: df9d18931b7f7b4e2c3e5e8bd629909a29aef6867d0c337183c7f7463b3b333b` (? first solution, we should change to something more common and easily made in both iOS, macOS and Java)
  - `senderId`: Sender Id of the SDK.

## How Client Matches Service With Local Devices?

Well, there are heuristics for this.

Precondition: Xcode must be installed (I've tested with 11.4.1 version)

1. Simulator matching. If TXT does have `deviceId` record, we need to get all possible local devices (`instruments -s devices` command will give you almost what you need. Some parsing required) and match. If match is found, device is local and we can auto connect.
2. Client always watches for bonjour services with type `_rdlink._tcp.`. This services are appearing when the device is being connected to a Mac via USB. So we can match IP addresses that are resolved for these services with `_rdlink._tcp.` type with addresses that are resolved for Robologs services. If `_rdlink._tcp.` service with same IP is found, there is a match! We can auto-connect.

All other Robologs services are considered non-local and can be connected to, but auto connection is not recommended.
