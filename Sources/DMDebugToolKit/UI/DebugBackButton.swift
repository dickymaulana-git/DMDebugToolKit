
import SwiftUI

struct DebugBackButton: View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(DebugUIStyle.success)
                .frame(width: 40, height: 40)
                .background(
                    DebugUIStyle.success.opacity(0.10)
                )
                .clipShape(Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
