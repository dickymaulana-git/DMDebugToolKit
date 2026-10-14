import SwiftUI

struct DebugView: View {
    private static let appVersion = "1.0.2"
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    List {
                        // MARK: - Network
                        section(
                            title: "Network",
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
                    .listRowSeparator(.hidden)
                    .listRowInsets(
                        EdgeInsets(
                            top: 4,
                            leading: 16,
                            bottom: 4,
                            trailing: 16
                        )
                    )
                    
                    versionFooter
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .background(Color(uiColor: .systemBackground))
            }
        }
    }

    // MARK: - Section

    private func section<Content: View>(
        title: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {

        Section {
            content()
                .listRowSeparator(.hidden)
        } header: {

            HStack(spacing: 0) {
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
        }
    }
    
    private var versionFooter: some View {
        VStack(spacing: 5) {
            Text("DM Debug Toolkit")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)

            Text("Version \(Self.appVersion)")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(uiColor: .systemBackground))
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
