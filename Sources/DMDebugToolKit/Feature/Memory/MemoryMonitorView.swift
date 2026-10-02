// MemoryMonitorView.swift

import SwiftUI

struct MemoryMonitorView: View {

    @State private var currentMemory: Double = 0
    @State private var peakMemory: Double = 0
    @State private var snapshots: [MemorySnapshot] = []

    private let monitor = MemoryMonitor.shared

    var body: some View {
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
        .navigationTitle("Memory Monitor")
        .navigationBarTitleDisplayMode(.inline)
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

                update()
            }
        }
    }

    private func update() {
        currentMemory = monitor.currentMemoryMB
        peakMemory = monitor.peakMemoryMB
        snapshots = monitor.snapshots
    }

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
