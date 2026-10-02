import UIKit

struct DeviceInfo {

    let model: String
    let systemName: String
    let systemVersion: String

    let screenSize: String
    let screenScale: String

    let locale: String
    let timezone: String

    let bundleIdentifier: String
    let appVersion: String
    let appBuild: String

    static var current: DeviceInfo {
        let device = UIDevice.current
        let screen = UIScreen.main

        let bundle = Bundle.main

        let version =
            bundle.object(
                forInfoDictionaryKey: "CFBundleShortVersionString"
            ) as? String ?? "-"

        let build =
            bundle.object(
                forInfoDictionaryKey: "CFBundleVersion"
            ) as? String ?? "-"

        let size = screen.bounds.size

        return DeviceInfo(
            model: device.model,
            systemName: device.systemName,
            systemVersion: device.systemVersion,
            screenSize: "\(Int(size.width)) × \(Int(size.height))",
            screenScale: "\(screen.scale)x",
            locale: Locale.current.identifier,
            timezone: TimeZone.current.identifier,
            bundleIdentifier: bundle.bundleIdentifier ?? "-",
            appVersion: version,
            appBuild: build
        )
    }
}
