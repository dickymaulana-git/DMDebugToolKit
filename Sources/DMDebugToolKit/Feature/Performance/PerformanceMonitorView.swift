// PerformanceMonitorView.swift

import SwiftUI

struct PerformanceMonitorView: View {

    @State private var fps: Double = 0
    @State private var cpu: Double = 0
    @State private var peakCPU: Double = 0
    @State private var snapshots: [PerformanceSnapshot] = []
    @State private var memorySnapshots: [MemorySnapshot] = []

    private let monitor =
        PerformanceMonitor.shared

    var body: some View {
        ScrollView {
            VStack(
                spacing: DebugUIStyle.sectionSpacing
            ) {

                summaryLink

                VStack(spacing: 8) {

                    HStack(spacing: 8) {
                        metricCard(
                            title: "FPS",
                            value: String(
                                format: "%.1f",
                                fps
                            ),
                            subtitle: "Current",
                            health: PerformanceHealth.fps(fps),
                            icon: "speedometer"
                        )

                        metricCard(
                            title: "CPU",
                            value: String(
                                format: "%.1f%%",
                                cpu
                            ),
                            subtitle: String(
                                format: "Peak %.1f%%",
                                peakCPU
                            ),
                            health: PerformanceHealth.cpu(cpu),
                            icon: "cpu"
                        )
                    }

                    memoryCard
                }

                graphSection(
                    title: "FPS History",
                    icon: "chart.line.uptrend.xyaxis"
                ) {
                    FPSGraphView(
                        snapshots: snapshots
                    )
                    .frame(
                        height: DebugUIStyle.graphHeight
                    )
                }

                graphSection(
                    title: "CPU History",
                    icon: "waveform.path.ecg"
                ) {
                    CPUGraphView(
                        snapshots: snapshots
                    )
                    .frame(
                        height: DebugUIStyle.graphHeight
                    )
                }
            }
            .padding(DebugUIStyle.screenPadding)
        }
        .navigationTitle("Performance Monitor")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            monitor.start()
            MemoryMonitor.shared.start()
            update()
        }
        .onDisappear {
            monitor.stop()
            MemoryMonitor.shared.stop()
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

    // MARK: - Summary

    private var summaryLink: some View {
        NavigationLink {
            PerformanceSummaryView()
        } label: {
            HStack(spacing: 9) {

                Image(
                    systemName: "chart.bar.xaxis"
                )
                .font(
                    .system(
                        size: 13,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    DebugUIStyle.accent
                )

                Text("Performance Summary")
                    .font(
                        DebugUIStyle.bodyMedium
                    )

                Spacer()

                Image(
                    systemName: "chevron.right"
                )
                .font(
                    .system(
                        size: 10,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(
                    cornerRadius:
                        DebugUIStyle.cardRadius
                )
                .fill(
                    DebugUIStyle.accentSoft
                )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Metric

    private func metricCard(
        title: String,
        value: String,
        subtitle: String,
        health: PerformanceHealth,
        icon: String
    ) -> some View {
        VStack(spacing: 3) {

            HStack(spacing: 5) {

                Image(systemName: icon)
                    .font(
                        .system(
                            size: 10,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        DebugUIStyle.accent
                    )

                Text(title)
                    .font(
                        DebugUIStyle.caption
                    )
                    .foregroundStyle(
                        .secondary
                    )
            }

            Text(value)
                .font(
                    .system(
                        size: 24,
                        weight: .bold
                    )
                )

            Text(subtitle)
                .font(
                    DebugUIStyle.caption
                )
                .foregroundStyle(
                    .secondary
                )

            HStack(spacing: 4) {

                Circle()
                    .fill(health.color)
                    .frame(
                        width: 7,
                        height: 7
                    )

                Text(health.title)
                    .font(
                        DebugUIStyle.captionMedium
                    )
                    .foregroundStyle(
                        health.color
                    )
            }
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 96
        )
        .background(
            RoundedRectangle(
                cornerRadius:
                    DebugUIStyle.cardRadius
            )
            .fill(
                DebugUIStyle.cardBackground
            )
        )
    }

    // MARK: - Memory

    private var memoryCard: some View {

        let current =
            memorySnapshots.last?.usedMB ?? 0

        let start =
            memorySnapshots.first?.usedMB ?? current

        let growth =
            current - start

        let health =
            PerformanceHealth.memory(
                snapshots: memorySnapshots
            )

        return HStack(spacing: 10) {

            Image(systemName: "memorychip")
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    DebugUIStyle.accent
                )

            VStack(
                alignment: .leading,
                spacing: 2
            ) {
                Text("Memory")
                    .font(
                        DebugUIStyle.caption
                    )
                    .foregroundStyle(
                        .secondary
                    )

                Text(
                    String(
                        format: "%.1f MB",
                        current
                    )
                )
                .font(
                    .system(
                        size: 21,
                        weight: .bold
                    )
                )

                Text(
                    String(
                        format:
                            "Growth %+.1f MB",
                        growth
                    )
                )
                .font(
                    DebugUIStyle.caption
                )
                .foregroundStyle(
                    .secondary
                )
            }

            Spacer()

            HStack(spacing: 4) {

                Circle()
                    .fill(health.color)
                    .frame(
                        width: 7,
                        height: 7
                    )

                Text(health.title)
                    .font(
                        DebugUIStyle.captionMedium
                    )
                    .foregroundStyle(
                        health.color
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(
                cornerRadius:
                    DebugUIStyle.cardRadius
            )
            .fill(
                DebugUIStyle.cardBackground
            )
        )
    }

    // MARK: - Graph

    private func graphSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            HStack(spacing: 6) {

                Image(systemName: icon)
                    .font(
                        .system(
                            size: 11,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        DebugUIStyle.accent
                    )

                Text(title)
                    .font(
                        DebugUIStyle.sectionTitle
                    )
            }

            content()
                .padding(8)
                .background(
                    RoundedRectangle(
                        cornerRadius:
                            DebugUIStyle.cardRadius
                    )
                    .fill(
                        DebugUIStyle.cardBackground
                    )
                )
        }
    }

    private func update() {
        fps =
            monitor.currentFPS

        cpu =
            monitor.currentCPUUsage

        peakCPU =
            monitor.peakCPUUsage

        snapshots =
            monitor.snapshots

        memorySnapshots =
            MemoryMonitor.shared.snapshots
    }
}
