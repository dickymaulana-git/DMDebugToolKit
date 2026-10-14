import SwiftUI

struct DebugSheetHostView: View {

    @ObservedObject var state: DebugSheetState

    var body: some View {
        Color.clear
            .sheet(
                isPresented: $state.isPresented,
                onDismiss: {
                    if let window = UIApplication.shared
                        .connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .flatMap(\.windows)
                        .first(where: { $0 is DebugWindow })
                        as? DebugWindow {

                        window.allowsFullInteraction = false
                    }

                    state.dismiss()
                }
            ) {
                DebugView()
            }
    }
}
