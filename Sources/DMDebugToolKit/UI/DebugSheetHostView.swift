import SwiftUI

struct DebugSheetHostView: View {

    @ObservedObject var state: DebugSheetState

    var body: some View {
        Color.clear
            .sheet(
                isPresented: $state.isPresented,
                onDismiss: {
                    state.dismiss()
                }
            ) {
                DebugView()
            }
    }
}
