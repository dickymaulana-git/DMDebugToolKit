
import SwiftUI

struct MemoryMonitorView: View {

    @State private var currentMemory: Double = 0
    @State private var peakMemory: Double = 0
    @State private var snapshots: [MemorySnapshot] = []

    private let monitor = MemoryMonitor.shared

    private var averageMemory: Double? {
        guard !snapshots.isEmpty else {
            return nil
        }

        let values = snapshots.map(\.usedMB)
        return values.reduce(0, +) / Double(values.count)
    }

    private var recentGrowth: Double? {
        let window = Array(snapshots.suffix(30))

        guard window.count >= 15 else {
            return nil
        }

        let baseline = Array(window.prefix(5)).map(\.usedMB)
        let recent = Array(window.suffix(5)).map(\.usedMB)

        let baselineAverage =
            baseline.reduce(0, +) / Double(baseline.count)

        let recentAverage =
            recent.reduce(0, +) / Double(recent.count)

        return recentAverage - baselineAverage
    }

    private var memoryHealth: PerformanceHealth {
        PerformanceHealth.memory(snapshots: snapshots)
    }

    private var insightMessage: String {
        guard let growth = recentGrowth else {
            return "Collecting memory samples. Health assessment will be available after at least 15 samples."
        }

        switch memoryHealth {
        case .collecting:
            return "Collecting memory samples."

        case .healthy:
            if growth < -5 {
                return "Recent memory usage is decreasing. Keep monitoring during repeated app interactions."
            }

            return "Recent memory usage is relatively stable. No sustained growth detected in the current sample window."

        case .warning:
            return String(
                format: "Memory usage increased by %.1f MB in the recent sample window. Continue monitoring to see whether it stabilizes.",
                growth
            )

        case .critical:
            return String(
                format: "Memory usage increased by %.1f MB in recent samples. Repeat the same user flow and inspect allocations with Xcode Instruments to investigate a possible leak.",
                growth
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationHeader

            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: 16
                ) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10)
                        ],
                        spacing: 10
                    ) {
                        statCard(
                            title: "Current",
                            value: String(
                                format: "%.1f MB",
                                currentMemory
                            ),
                            icon: "memorychip"
                        )

                        statCard(
                            title: "Peak",
                            value: String(
                                format: "%.1f MB",
                                peakMemory
                            ),
                            icon: "arrow.up.to.line"
                        )

                        statCard(
                            title: "Average",
                            value: averageMemory.map {
                                String(format: "%.1f MB", $0)
                            } ?? "—",
                            icon: "chart.bar"
                        )

                        statCard(
                            title: "Recent Growth",
                            value: recentGrowth.map {
                                String(format: "%+.1f MB", $0)
                            } ?? "—",
                            icon: "chart.line.uptrend.xyaxis"
                        )
                    }

                    VStack(
                        alignment: .leading,
                        spacing: 8
                    ) {
                        HStack {
                            Text("Memory Usage")
                                .font(DebugUIStyle.sectionTitle)

                            Spacer()

                            Text("\(snapshots.count) samples")
                                .font(DebugUIStyle.caption)
                                .foregroundColor(.secondary)
                        }

                        MemoryGraphView(snapshots: snapshots)
                            .frame(height: 240)
                            .padding(12)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: DebugUIStyle.cardRadius
                                )
                                .fill(DebugUIStyle.cardBackground)
                            )
                    }

                    memoryInsightsCard
                }
                .padding(DebugUIStyle.screenPadding)
            }
            .background(
                Color(uiColor: .systemGroupedBackground)
            )
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

                guard !Task.isCancelled else {
                    break
                }

                update()
            }
        }
    }

    // MARK: - Navigation Header

    private var navigationHeader: some View {
        HStack {
            DebugBackButton()

            Spacer()

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
        .padding(.vertical, 16)
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Statistics

    private func statCard(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(DebugUIStyle.accent)

                Text(title)
                    .font(DebugUIStyle.caption)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 78,
            alignment: .leading
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(
                cornerRadius: DebugUIStyle.cardRadius
            )
            .fill(DebugUIStyle.cardBackground)
        )
    }

    // MARK: - Memory Insights

    private var memoryInsightsCard: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            HStack(spacing: 8) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(memoryHealth.color)

                Text("Memory Insights")
                    .font(DebugUIStyle.sectionTitle)

                Spacer()

                Text(memoryHealth.title)
                    .font(DebugUIStyle.captionMedium)
                    .foregroundColor(memoryHealth.color)
            }

            Text(insightMessage)
                .font(DebugUIStyle.body)
                .foregroundColor(.secondary)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text("Assessment uses recent samples, not total memory usage alone.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(14)
        .background(
            RoundedRectangle(
                cornerRadius: DebugUIStyle.cardRadius
            )
            .fill(DebugUIStyle.cardBackground)
        )
    }

    // MARK: - Update

    private func update() {
        currentMemory = monitor.currentMemoryMB
        peakMemory = monitor.peakMemoryMB
        snapshots = monitor.snapshots
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
