import SwiftUI

struct DebugView: View {

    var body: some View {
        NavigationView {
            List {

                // MARK: - Network

                section(
                    title: "Network",
                    icon: "network",
                    color: DebugUIStyle.info
                ) {
                    navigationRow(
                        title: "Network Inspector",
                        subtitle: "HTTP request and response logs",
                        icon: "arrow.left.arrow.right",
                        color: DebugUIStyle.info
                    ) {
                        NetworkInspectorView()
                    }
                }

                // MARK: - Performance

                section(
                    title: "Performance",
                    icon: "gauge.with.dots.needle.bottom.50percent",
                    color: DebugUIStyle.accent
                ) {
                    navigationRow(
                        title: "Performance Monitor",
                        subtitle: "FPS, CPU and memory usage",
                        icon: "speedometer",
                        color: DebugUIStyle.accent
                    ) {
                        PerformanceMonitorView()
                    }

                    navigationRow(
                        title: "Memory Monitor",
                        subtitle: "Memory usage and history",
                        icon: "memorychip",
                        color: DebugUIStyle.info
                    ) {
                        MemoryMonitorView()
                    }
                }

                // MARK: - Debug

                section(
                    title: "Debug",
                    icon: "ladybug.fill",
                    color: DebugUIStyle.warning
                ) {
                    navigationRow(
                        title: "Logs",
                        subtitle: "Application debug logs",
                        icon: "doc.text.magnifyingglass",
                        color: DebugUIStyle.warning
                    ) {
                        DebugLogView()
                    }

                    navigationRow(
                        title: "Device Info",
                        subtitle: "Device and application information",
                        icon: "iphone",
                        color: DebugUIStyle.success
                    ) {
                        DeviceInfoView()
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Debug Toolkit")
            .navigationBarTitleDisplayMode(.inline)
            .shadow(
                color: Color.black.opacity(0.12),
                radius: 10,
                x: 0,
                y: -3
            )
        }
    }

    // MARK: - Section

    private func section<Content: View>(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {

        Section {
            content()
        } header: {

            HStack(spacing: 6) {

                Image(systemName: icon)
                    .font(
                        .system(
                            size: 13,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(color)

                Text(title)
                    .font(DebugUIStyle.sectionTitle)
                    .foregroundStyle(.primary)
            }
            .textCase(nil)
        }
    }

    // MARK: - Navigation Row

    private func navigationRow<Destination: View>(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        @ViewBuilder destination: () -> Destination
    ) -> some View {

        NavigationLink {
            destination()
        } label: {

            HStack(spacing: 12) {

                Image(systemName: icon)
                    .font(
                        .system(
                            size: 16,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(color)
                    .frame(
                        width: 36,
                        height: 36
                    )
                    .background(
                        Circle()
                            .fill(
                                color.opacity(0.12)
                            )
                    )

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {

                    Text(title)
                        .font(DebugUIStyle.bodyMedium)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(DebugUIStyle.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 7)
        }
    }
}

#if DEBUG
struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()

            VStack {
                Text("Demo App")
                    .font(.largeTitle)

                Spacer()
            }
            .padding()
        }
        .sheet(
            isPresented: .constant(true)
        ) {
            DebugView()
        }
    }
}
#endif
