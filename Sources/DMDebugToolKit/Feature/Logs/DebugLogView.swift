// DebugLogView.swift

import SwiftUI

struct DebugLogView: View {

    @State private var entries: [DebugLogEntry] = []
    @State private var selectedLevel: DebugLogLevel?

    private let logger = DebugLogger.shared

    var filteredEntries: [DebugLogEntry] {
        guard let selectedLevel else {
            return entries
        }

        return entries.filter {
            $0.level == selectedLevel
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            filterBar

            if filteredEntries.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(
                        filteredEntries.indices,
                        id: \.self
                    ) { index in

                        let entry = filteredEntries[index]

                        logRow(entry)
                            .listRowInsets(
                                EdgeInsets(
                                    top: 0,
                                    leading: 0,
                                    bottom: 0,
                                    trailing: 0
                                )
                            )
                            .listRowBackground(
                                DebugUIStyle.rowBackground(
                                    index: index
                                )
                            )
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Logs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(
                placement: .navigationBarTrailing
            ) {
                Button("Clear") {
                    logger.clear()
                    refresh()
                }
                .font(
                    .system(
                        size: 12,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    DebugUIStyle.critical
                )
            }
        }
        .onAppear {
            refresh()
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(
                    nanoseconds: 1_000_000_000
                )

                refresh()
            }
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {
            HStack(spacing: 6) {

                filterButton(
                    title: "All",
                    level: nil
                )

                filterButton(
                    title: "Info",
                    level: .info
                )

                filterButton(
                    title: "Warning",
                    level: .warning
                )

                filterButton(
                    title: "Error",
                    level: .error
                )

                filterButton(
                    title: "Debug",
                    level: .debug
                )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(
            DebugUIStyle.secondaryBackground
        )
    }

    private func filterButton(
        title: String,
        level: DebugLogLevel?
    ) -> some View {

        let isSelected = selectedLevel == level
        let color = level.map(levelColor)
            ?? DebugUIStyle.accent

        return Button {
            selectedLevel = level
        } label: {
            Text(title)
                .font(
                    .system(
                        size: 11,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    isSelected
                        ? .white
                        : color
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(
                            isSelected
                                ? color
                                : color.opacity(0.10)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Log Row

    private func logRow(
        _ entry: DebugLogEntry
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 5
        ) {
            HStack(spacing: 7) {

                levelBadge(entry.level)

                Text(
                    timeFormatter.string(
                        from: entry.timestamp
                    )
                )
                .font(
                    .system(
                        size: 10,
                        weight: .medium
                    )
                )
                .foregroundStyle(.secondary)

                Spacer()
            }

            Text(entry.message)
                .font(DebugUIStyle.body)
                .foregroundStyle(.primary)
                .textSelection(.enabled)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Level Badge

    private func levelBadge(
        _ level: DebugLogLevel
    ) -> some View {

        let color = levelColor(level)

        return Text(levelTitle(level))
            .font(
                .system(
                    size: 10,
                    weight: .bold
                )
            )
            .foregroundStyle(color)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 8) {

            Image(
                systemName: "doc.text.magnifyingglass"
            )
            .font(.system(size: 28))
            .foregroundStyle(
                DebugUIStyle.accent
            )

            Text("No Logs")
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )

            Text(
                selectedLevel == nil
                    ? "No debug logs have been recorded."
                    : "No logs for this level."
            )
            .font(DebugUIStyle.caption)
            .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }

    // MARK: - Helpers

    private func levelColor(
        _ level: DebugLogLevel
    ) -> Color {
        switch level {
        case .info:
            return DebugUIStyle.info

        case .warning:
            return DebugUIStyle.warning

        case .error:
            return DebugUIStyle.critical

        case .debug:
            return DebugUIStyle.accent
        }
    }

    private func levelTitle(
        _ level: DebugLogLevel
    ) -> String {
        switch level {
        case .info:
            return "INFO"

        case .warning:
            return "WARN"

        case .error:
            return "ERROR"

        case .debug:
            return "DEBUG"
        }
    }

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    private func refresh() {
        entries = logger.allEntries()
    }
}
