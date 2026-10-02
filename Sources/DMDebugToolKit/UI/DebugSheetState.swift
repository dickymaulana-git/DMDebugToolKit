import SwiftUI

final class DebugSheetState: ObservableObject {

    @Published var isPresented = false

    var onDismiss: (() -> Void)?

    func present() {
        isPresented = true
    }

    func dismiss() {
        isPresented = false
    }
}
