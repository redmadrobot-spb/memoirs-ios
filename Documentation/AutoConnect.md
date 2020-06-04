# Bonjour (DNS-SD) Auto Connect for iOS

SDK contains two classes (BonjourServer, BonjourClient), that help with auto connection console applications to SDK that is being debugged with RemoteLogger turned on.

You usually do not need to use BonjourServer (it is integrated in Debug version of the SDK. BonjourClient can be easily used to find out connection parameters (API url, Sender id) of connected SDKs. Please refer to code for finding out how BonjourServer works.

## Agreements on DNS usage

- Domain: `local.`
- Type: `_robologs._tcp.`
- Name: `Robologs-UUID`. UUID here is needed so that client is able to catch service disappearance and match it to service and connection id.
- Port: random port from range 48000 ..< 65536. If port is busy, server must try again with different random port.
- TXT structure (all the values are utf-8 strings):
  - `name`: Name of the SDK, how we can display it in the selection list.
  - `endpoint`: API endpoint to connect to.
  - `senderId`: Sender id of the SDK.
  - Device specific entries:
    - `iOSSimulator`: Optional hash of the UDID of the simulator device in the form `base64(SHA256("Device UDID"))`. It must be generated from `SIMULATOR_UDID` environment variable. It must look like this `cL0t1naVppYqUpDfmY1VTJIjmsaduBWmJJVXZSFEjks=` for the device UDID `F10FA17D-0D76-4CE6-9D13-6D7525753C4E`.

## How Client Matches Service With Local Devices?

Well, there are heuristics for this.

Precondition: Xcode must be installed (I've tested with Xcode 11.4.1, 11.5 beta) for step 2.

1. Check if the connection is from localhost (127.0.0.1 or similar). If it is — connect automatically.
2. iOS Simulator matching. If TXT does have `deviceId` record, we need to get all possible local devices (`instruments -s devices` command will give you almost what you need. Some parsing required) and match. If match is found, device is local and we can auto connect.
3. iOS Devices matching. Client always watches for bonjour services with type `_rdlink._tcp.`. This services are appearing when the device is being connected to a Mac via USB. So we can match IP addresses that are resolved for these services with `_rdlink._tcp.` type with addresses that are resolved for Robologs services. If `_rdlink._tcp.` service with same IP is found, there is a match! We can auto-connect.

All other Robologs services are considered non-local. They can be connected to (or be tried to connect to) manually.
