// DebugLogView.swift

import SwiftUI

struct DebugLogView: View {

    @State private var entries: [DebugLogEntry] = []
    @State private var selectedLevel: DebugLogLevel?

    @Environment(\.presentationMode) private var presentationMode
    @State private var searchText = ""
    private let logger = DebugLogger.shared

    var filteredEntries: [DebugLogEntry] {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return entries.filter { entry in
            let matchesLevel =
                selectedLevel == nil ||
                entry.level == selectedLevel

            let matchesText =
                query.isEmpty ||
                entry.message.localizedCaseInsensitiveContains(query) ||
                entry.level.rawValue.localizedCaseInsensitiveContains(query) ||
                timeFormatter.string(
                    from: entry.timestamp
                ).localizedCaseInsensitiveContains(query)

            return matchesLevel && matchesText
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)

            TextField("Search logs...", text: $searchText)
                .font(.system(size: 14))
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 42)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationHeader
            filterBar
            searchBar
            
            if filteredEntries.isEmpty {
                emptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(
                            Array(filteredEntries.enumerated()),
                            id: \.element.id
                        ) { index, entry in
                            logRow(entry)
                                .padding(12)
                                .background(
                                    DebugUIStyle.rowBackground(index: index)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(levelColor(entry.level))
                                        .frame(width: 4)
                                }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
        }
        .background(Color(uiColor: .systemBackground))
        .navigationBarHidden(true)
        .onAppear {
            refresh()
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { break }
                refresh()
            }
        }
    }
    
    private var navigationHeader: some View {
        HStack {
            DebugBackButton()

            Spacer()

            Button {
                logger.clear()
                refresh()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(DebugUIStyle.critical)
                    .frame(width: 40, height: 40)
                    .background(
                        DebugUIStyle.critical.opacity(0.10)
                    )
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .overlay {
            Text("Debug Logs")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .allowsHitTesting(false)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(uiColor: .systemBackground))
    }
    
    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterButton(
                    title: "All",
                    level: nil,
                    count: entries.count
                )
                filterButton(
                    title: "Debug",
                    level: .debug,
                    count: count(for: .debug)
                )
                filterButton(
                    title: "Error",
                    level: .error,
                    count: count(for: .error)
                )
                filterButton(
                    title: "Info",
                    level: .info,
                    count: count(for: .info)
                )

                filterButton(
                    title: "Warning",
                    level: .warning,
                    count: count(for: .warning)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
    }

    private func count(for level: DebugLogLevel) -> Int {
        entries.filter { $0.level == level }.count
    }

    private func filterButton(
        title: String,
        level: DebugLogLevel?,
        count: Int
    ) -> some View {
        let isSelected = selectedLevel == level
        let color = level.map(levelColor) ?? DebugUIStyle.success

        return Button {
            selectedLevel = level
        } label: {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))

                Text("\(count)")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule().fill(
                            isSelected
                                ? Color.white.opacity(0.20)
                                : color.opacity(0.12)
                        )
                    )
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                Capsule().fill(
                    isSelected ? color : color.opacity(0.09)
                )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Log Row

    private func logRow(_ entry: DebugLogEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                levelBadge(entry.level)

                Text(timeFormatter.string(from: entry.timestamp))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Text(entry.message)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
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


#if DEBUG
struct DebugLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DebugLogView()
        }
        .onAppear {
            let logger = DebugLogger.shared

            logger.clear()

            logger.info("Application started")

            logger.debug("""
            User configuration loaded:
            {
              "theme": "dark",
              "language": "id",
              "notifications": true
            }
            """)

            logger.warning("""
            Request took longer than expected:
            {
              "endpoint": "/api/user/profile",
              "duration": 3200,
              "threshold": 2000
            }
            """)

            logger.error("""
            Failed to load user profile:
            {
              "statusCode": 500,
              "error": "Internal Server Error",
              "message": "Failed to retrieve user data",
              "requestId": "req-a1b2c3d4"
            }
            """)

            logger.info("""
            User profile response:
            {
              "status": "success",
              "data": {
                "id": 12345,
                "name": "John Doe",
                "email": "john@example.com",
                "membership": {
                  "type": "premium",
                  "active": true
                },
                "address": {
                  "city": "Jakarta",
                  "country": "Indonesia"
                }
              }
            }
            """)
        }
    }
}
#endif
