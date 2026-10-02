// PerformanceSummaryView.swift

import SwiftUI

struct PerformanceSummaryView: View {

    private let monitor = PerformanceMonitor.shared
    private let memoryMonitor = MemoryMonitor.shared

    @State private var memorySnapshots: [MemorySnapshot] = []

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: DebugUIStyle.sectionSpacing
            ) {

                overallHealthCard

                summarySection(title: "FPS") {
                    summaryRow(
                        title: "Average",
                        value: String(
                            format: "%.1f FPS",
                            monitor.averageFPS
                        ),
                        index: 0
                    )

                    summaryRow(
                        title: "Minimum",
                        value: String(
                            format: "%.1f FPS",
                            monitor.minimumFPS
                        ),
                        index: 1
                    )
                }

                summarySection(title: "CPU") {
                    summaryRow(
                        title: "Average",
                        value: String(
                            format: "%.1f%%",
                            monitor.averageCPUUsage
                        ),
                        index: 0
                    )

                    summaryRow(
                        title: "Peak",
                        value: String(
                            format: "%.1f%%",
                            monitor.peakCPUUsage
                        ),
                        index: 1
                    )
                }

                summarySection(title: "Memory") {
                    summaryRow(
                        title: "Start",
                        value: memoryValue(
                            memorySnapshots.first?.usedMB
                        ),
                        index: 0
                    )

                    summaryRow(
                        title: "Current",
                        value: memoryValue(
                            memorySnapshots.last?.usedMB
                        ),
                        index: 1
                    )

                    summaryRow(
                        title: "Peak",
                        value: memoryValue(
                            memorySnapshots
                                .map(\.usedMB)
                                .max()
                        ),
                        index: 2
                    )

                    summaryRow(
                        title: "Growth",
                        value: memoryGrowth,
                        index: 3
                    )
                }
            }
            .padding(DebugUIStyle.screenPadding)
        }
        .navigationTitle("Performance Summary")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            update()
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(
                    nanoseconds: 1_000_000_000
                )
                update()
            }
        }
    }

    private var overallHealthCard: some View {
        let fpsHealth = PerformanceHealth.fps(
            monitor.averageFPS
        )

        let cpuHealth = PerformanceHealth.cpu(
            monitor.averageCPUUsage
        )

        let memoryHealth = PerformanceHealth.memory(
            snapshots: memorySnapshots
        )

        let health = PerformanceHealth.overall([
            fpsHealth,
            cpuHealth,
            memoryHealth
        ])

        return HStack(spacing: 9) {

            Circle()
                .fill(health.color)
                .frame(width: 9, height: 9)

            VStack(
                alignment: .leading,
                spacing: 1
            ) {
                Text("Overall")
                    .font(DebugUIStyle.caption)
                    .foregroundStyle(.secondary)

                Text(health.title)
                    .font(
                        .system(
                            size: 16,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(health.color)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(
                cornerRadius: DebugUIStyle.cardRadius
            )
            .fill(health.color.opacity(0.08))
        )
    }

    @ViewBuilder
    private func summarySection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 5
        ) {
            Text(title)
                .font(DebugUIStyle.sectionTitle)

            VStack(spacing: 0) {
                content()
            }
            .clipShape(
                RoundedRectangle(
                    cornerRadius: DebugUIStyle.cardRadius
                )
            )
        }
    }

    private func summaryRow(
        title: String,
        value: String,
        index: Int
    ) -> some View {
        HStack {
            Text(title)
                .font(DebugUIStyle.body)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(DebugUIStyle.bodyMedium)
        }
        .padding(.horizontal, DebugUIStyle.rowHorizontalPadding)
        .padding(.vertical, DebugUIStyle.rowVerticalPadding)
        .frame(maxWidth: .infinity)
        .background(
            DebugUIStyle.rowBackground(index: index)
        )
    }

    private func update() {
        memorySnapshots = memoryMonitor.snapshots
    }

    private var memoryGrowth: String {
        guard
            let first = memorySnapshots.first?.usedMB,
            let last = memorySnapshots.last?.usedMB
        else {
            return "-"
        }

        return String(
            format: "%+.1f MB",
            last - first
        )
    }

    private func memoryValue(
        _ value: Double?
    ) -> String {
        guard let value else {
            return "-"
        }

        return String(
            format: "%.1f MB",
            value
        )
    }
}
