# DMDebugToolKit

A lightweight debugging toolkit for iOS applications.

DMDebugToolKit provides an in-app debugging interface for inspecting application performance, memory usage, network requests, logs, and device information without adding debugging UI directly into the application.

## Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15+

## Features

- Floating debug button
- Environment indicator
- Performance monitoring
  - FPS
  - CPU usage
  - FPS history
  - CPU history
- Memory monitoring
  - Current memory usage
  - Peak memory usage
  - Memory history
  - Memory growth
- Network Inspector
  - HTTP method
  - URL
  - Status code
  - Duration
  - Request headers
  - Request body
  - Response headers
  - Response body
- Application logs
- Device information
- Optional Moya integration
- iOS 15 compatible
- Swift Package Manager support

## Installation

### Swift Package Manager

Add DMDebugToolKit to your project using Swift Package Manager.

In Xcode:

1. Select **File → Add Package Dependencies**
2. Enter:

```text
https://github.com/dickymaulana-git/DMDebugToolKit.git
```

3. Select the package version or branch.
4. Add the `DMDebugToolKit` product to your application target.

Then import:

```swift
import DMDebugToolKit
```

## Basic Usage

Start the toolkit during application initialization:

```swift
import DMDebugToolKit

DebugToolkit.start(
    configuration: DebugToolkitConfiguration(
        environment: .dev,
        systemIcon: "ladybug.fill"
    )
)
```

The floating debug button will appear when the configured environment is enabled.

To stop the toolkit:

```swift
DebugToolkit.stop()
```

## Environment

DMDebugToolKit supports environment-based activation.

For example:

```swift
DebugToolkit.start(
    configuration: DebugToolkitConfiguration(
        environment: .dev
    )
)
```

The debug interface can be enabled for development and staging environments while remaining disabled in production.

## Custom Icon

You can provide a custom icon:

```swift
DebugToolkit.start(
    configuration: DebugToolkitConfiguration(
        environment: .dev,
        icon: UIImage(named: "debug-icon")
    )
)
```

Or use an SF Symbol:

```swift
DebugToolkit.start(
    configuration: DebugToolkitConfiguration(
        environment: .dev,
        systemIcon: "ladybug.fill"
    )
)
```

## Moya Integration

Moya integration is provided as a separate product so applications that do not use Moya do not need to depend on it.

Add:

```swift
import DMDebugToolKitMoya
```

Create the plugin:

```swift
let provider = MoyaProvider<YourTarget>(
    plugins: [
        DebugMoyaPlugin()
    ]
)
```

Network requests made through Moya will be captured by the Network Inspector.

## Network Inspector

The Network Inspector provides information about recorded HTTP requests and responses, including:

- HTTP method
- URL
- Status code
- Request duration
- Request headers
- Request body
- Response headers
- Response body

Example:

```text
GET
https://api.example.com/users/1
200
124 ms
```

## Logging

Application logs can be recorded through the debug logger:

```swift
DebugLogger.shared.info("User opened profile")
DebugLogger.shared.debug("Loading profile data")
DebugLogger.shared.warning("Slow response detected")
DebugLogger.shared.error("Failed to load profile")
```

Recorded logs can be inspected from the Logs screen.

## Performance Monitoring

The Performance Monitor provides:

- Current FPS
- Minimum FPS
- Average FPS
- Current CPU usage
- Average CPU usage
- Peak CPU usage
- FPS history
- CPU history

## Memory Monitoring

The Memory Monitor provides:

- Current memory usage
- Peak memory usage
- Memory history
- Memory growth
- Memory trend

## Architecture

DMDebugToolKit is organized into several areas:

```text
DMDebugToolKit
├── Core
├── Feature
├── Storage
├── UI
├── Preview
└── Resources

DMDebugToolKitMoya
└── DebugMoyaPlugin
```

## License

See [LICENSE](LICENSE).