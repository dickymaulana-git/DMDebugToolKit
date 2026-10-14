
import SwiftUI

struct MemoryMonitorView: View {

    @State private var currentMemory: Double = 0
    @State private var peakMemory: Double = 0
    @State private var snapshots: [MemorySnapshot] = []

    private let monitor = MemoryMonitor.shared

    var body: some View {
        VStack(spacing: 0) {
            navigationHeader

            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: DebugUIStyle.sectionSpacing
                ) {
                    HStack(spacing: 8) {
                        memoryCard(
                            title: "Current",
                            value: currentMemory
                        )

                        memoryCard(
                            title: "Peak",
                            value: peakMemory
                        )
                    }

                    VStack(
                        alignment: .leading,
                        spacing: 6
                    ) {
                        Text("Memory Usage")
                            .font(DebugUIStyle.sectionTitle)

                        memoryGraphCard
                    }
                }
                .padding(DebugUIStyle.screenPadding)
            }
        }
        .background(Color(uiColor: .systemBackground))
        .navigationBarHidden(true)
        .onAppear {
            monitor.start()
            update()
        }
        .onDisappear {
            monitor.stop()
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(
                    nanoseconds: 1_000_000_000
                )

                guard !Task.isCancelled else { break }
                update()
            }
        }
    }

    // MARK: - Navigation Header

    private var navigationHeader: some View {
        HStack {
            DebugBackButton()

            Spacer()

            // Menjaga title tetap tepat di tengah.
            Color.clear
                .frame(width: 40, height: 40)
        }
        .overlay {
            Text("Memory Monitor")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .allowsHitTesting(false)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Update

    private func update() {
        currentMemory = monitor.currentMemoryMB
        peakMemory = monitor.peakMemoryMB
        snapshots = monitor.snapshots
    }

    // MARK: - Memory Card

    private func memoryCard(
        title: String,
        value: Double
    ) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(DebugUIStyle.caption)
                .foregroundStyle(.secondary)

            Text(
                String(
                    format: "%.1f MB",
                    value
                )
            )
            .font(
                .system(
                    size: 21,
                    weight: .bold
                )
            )
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 68
        )
        .background(
            RoundedRectangle(
                cornerRadius: DebugUIStyle.cardRadius
            )
            .fill(DebugUIStyle.cardBackground)
        )
    }

    // MARK: - Memory Graph

    private var memoryGraphCard: some View {
        MemoryGraphView(
            snapshots: snapshots
        )
        .frame(
            height: DebugUIStyle.graphHeight
        )
        .padding(8)
        .background(
            RoundedRectangle(
                cornerRadius: DebugUIStyle.cardRadius
            )
            .fill(DebugUIStyle.cardBackground)
        )
    }
}

#if DEBUG
struct MemoryMonitorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MemoryMonitorView()
        }
        .navigationViewStyle(.stack)
    }
}
#endif
