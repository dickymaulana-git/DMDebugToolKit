import SwiftUI

struct DebugView: View {
    private static let appVersion = "1.0.2"

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(
                        alignment: .leading,
                        spacing: 28
                    ) {
                        section(title: "Network") {
                            navigationRow(
                                title: "Network Inspector",
                                subtitle: "HTTP request and response logs",
                                icon: "arrow.left.arrow.right",
                                color: DebugUIStyle.info
                            ) {
                                NetworkInspectorView()
                            }
                        }

                        section(title: "Performance") {
                            navigationRow(
                                title: "Performance Monitor",
                                subtitle: "FPS, CPU and memory usage",
                                icon: "speedometer",
                                color: DebugUIStyle.success
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

                        section(title: "Debug") {
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
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }

                versionFooter
            }
            .padding(.top, 16)
            .background(Color(uiColor: .systemBackground))
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Section

    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            Text(title)
                .font(DebugUIStyle.sectionTitle)
                .foregroundStyle(.secondary)
                .padding(.leading, 2)

            VStack(spacing: 8) {
                content()
            }
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
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(
                        .system(
                            size: 21,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(color.opacity(0.12))
                    )

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text(title)
                        .font(DebugUIStyle.bodyMedium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(DebugUIStyle.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(
                        .system(
                            size: 14,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
            .contentShape(
                RoundedRectangle(cornerRadius: 20)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Footer

    private var versionFooter: some View {
        VStack(spacing: 5) {
            Text("DM Debug Toolkit")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)

            Text("Version \(Self.appVersion)")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 20)
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
                HStack {
                    Text("Demo App")
                        .font(.largeTitle)
                    Spacer()
                }

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
