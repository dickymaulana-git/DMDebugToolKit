import UIKit

final class DebugPositionStore {

    private let xKey = "DebugToolkit.FloatingButton.x"
    private let yKey = "DebugToolkit.FloatingButton.y"

    func save(position: CGPoint) {
        UserDefaults.standard.set(
            position.x,
            forKey: xKey
        )

        UserDefaults.standard.set(
            position.y,
            forKey: yKey
        )
    }

    func load() -> CGPoint? {

        guard UserDefaults.standard.object(forKey: xKey) != nil,
              UserDefaults.standard.object(forKey: yKey) != nil
        else {
            return nil
        }

        return CGPoint(
            x: UserDefaults.standard.double(forKey: xKey),
            y: UserDefaults.standard.double(forKey: yKey)
        )
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: xKey)
        UserDefaults.standard.removeObject(forKey: yKey)
    }
}
