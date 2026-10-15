
import SwiftUI

struct NetworkInspectorView: View {

    @State private var logs: [NetworkLog] = []
    @State private var searchText = ""
    @State private var selectedFilter: StatusFilter = .all

    private let previewLogs: [NetworkLog]?
    private let recorder = NetworkRecorder.shared

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    private enum StatusFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case success = "2xx"
        case clientError = "4xx"
        case serverError = "5xx"

        var id: String { rawValue }

        func matches(_ statusCode: Int?) -> Bool {
            guard let statusCode else {
                return self == .all
            }

            switch self {
            case .all:
                return true
            case .success:
                return (200...299).contains(statusCode)
            case .clientError:
                return (400...499).contains(statusCode)
            case .serverError:
                return (500...599).contains(statusCode)
            }
        }

        var tint: Color {
            switch self {
            case .all:
                return DebugUIStyle.accent
            case .success:
                return DebugUIStyle.success
            case .clientError:
                return DebugUIStyle.warning
            case .serverError:
                return DebugUIStyle.critical
            }
        }
    }

    init(previewLogs: [NetworkLog]? = nil) {
        self.previewLogs = previewLogs
        _logs = State(initialValue: previewLogs ?? [])
    }

    // MARK: - Filtered Logs

    private var filteredLogs: [NetworkLog] {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return logs.filter { log in
            let matchesStatus = selectedFilter.matches(
                log.statusCode
            )

            let matchesSearch =
                query.isEmpty ||
                log.url.localizedCaseInsensitiveContains(query) ||
                log.method.localizedCaseInsensitiveContains(query) ||
                String(log.statusCode ?? 0).contains(query)

            return matchesStatus && matchesSearch
        }
    }

    private func count(for filter: StatusFilter) -> Int {
        logs.filter {
            filter.matches($0.statusCode)
        }.count
    }

    private var failedCount: Int {
        logs.filter {
            ($0.statusCode ?? 0) >= 400
        }.count
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            navigationHeader
            Divider()
            if filteredLogs.isEmpty {
                emptyState
            } else {
                networkList
            }
            searchBar
            overviewBar
        }
        .background(
            Color(uiColor: .systemGroupedBackground)
        )
        .navigationBarHidden(true)
        .onAppear {
            if previewLogs == nil {
                refresh()
            }
        }
        .task {
            guard previewLogs == nil else {
                return
            }

            while !Task.isCancelled {
                try? await Task.sleep(
                    nanoseconds: 1_000_000_000
                )

                guard !Task.isCancelled else {
                    break
                }

                refresh()
            }
        }
    }

    // MARK: - Navigation Header

    private var navigationHeader: some View {
        HStack {
            DebugBackButton()

            Spacer()

            Button(action: clearLogs) {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                        .font(
                            .system(
                                size: 13,
                                weight: .semibold
                            )
                        )

                    Text("Clear")
                        .font(
                            .system(
                                size: 13,
                                weight: .semibold
                            )
                        )
                }
                .foregroundColor(DebugUIStyle.critical)
                .padding(.horizontal, 13)
                .frame(height: 38)
                .background(
                    DebugUIStyle.critical.opacity(0.10)
                )
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(logs.isEmpty)
            .opacity(logs.isEmpty ? 0.5 : 1)
        }
        .overlay {
            Text("Network Inspector")
                .font(
                    .system(
                        size: 18,
                        weight: .semibold
                    )
                )
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .allowsHitTesting(false)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Color(uiColor: .systemBackground)
        )
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(
                    .system(
                        size: 16,
                        weight: .medium
                    )
                )
                .foregroundColor(.secondary)

            TextField(
                "Search URL, method or status...",
                text: $searchText
            )
            .font(.system(size: 14))
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(
                        systemName: "xmark.circle.fill"
                    )
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(
            Color(uiColor: .systemBackground)
        )
    }

    // MARK: - Overview

    private var overviewBar: some View {
        HStack(spacing: 7) {
            Image(systemName: "arrow.left.arrow.right")
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )
                .foregroundColor(DebugUIStyle.accent)

            Text("\(logs.count) Requests")
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )
                .foregroundColor(.primary)

            Spacer()

            if failedCount > 0 {
                Image(
                    systemName: "exclamationmark.circle.fill"
                )
                .font(.system(size: 12))

                Text("\(failedCount) failed")
                    .font(
                        .system(
                            size: 12,
                            weight: .medium
                        )
                    )
            } else {
                Image(
                    systemName: "checkmark.circle.fill"
                )
                .font(.system(size: 12))

                Text("No failures")
                    .font(
                        .system(
                            size: 12,
                            weight: .medium
                        )
                    )
            }
        }
        .foregroundColor(
            failedCount > 0
                ? DebugUIStyle.critical
                : DebugUIStyle.success
        )
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            Color(uiColor: .systemBackground)
        )
    }

    // MARK: - Status Filters

    private var statusFilterBar: some View {
        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {
            HStack(spacing: 8) {
                ForEach(StatusFilter.allCases) { filter in
                    filterChip(filter)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
        }
        .background(
            Color(uiColor: .secondarySystemGroupedBackground)
        )
    }

    private func filterChip(
        _ filter: StatusFilter
    ) -> some View {
        let isSelected = selectedFilter == filter

        return Button {
            selectedFilter = filter
        } label: {
            HStack(spacing: 8) {
                Text(filter.rawValue)
                    .font(
                        .system(
                            size: 13,
                            weight: .semibold
                        )
                    )

                Text("\(count(for: filter))")
                    .font(
                        .system(
                            size: 11,
                            weight: .bold
                        )
                    )
                    .foregroundColor(
                        isSelected ? .white : filter.tint
                    )
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        isSelected
                            ? Color.white.opacity(0.20)
                            : filter.tint.opacity(0.12)
                    )
                    .clipShape(Capsule())
            }
            .foregroundColor(
                isSelected ? .white : .primary
            )
            .padding(.horizontal, 12)
            .frame(minHeight: 42)
            .background(
                isSelected
                    ? DebugUIStyle.accent
                    : Color(uiColor: .systemBackground)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Network List

    private var networkList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(
                    Array(filteredLogs.enumerated()),
                    id: \.element.id
                ) { index, log in
                    NavigationLink {
                        NetworkDetailView(log: log)
                    } label: {
                        networkRow(log, index: index)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .background(
            Color(uiColor: .systemGroupedBackground)
        )
    }

    // MARK: - Network Row

    private func networkRow(
        _ log: NetworkLog,
        index: Int
    ) -> some View {
        let parts = splitURL(log.url)

        return HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    DebugUIStyle.statusColor(log.statusCode)
                )
                .frame(width: 4)
                .frame(maxHeight: .infinity)

            HStack(spacing: 10) {
                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {
                    // Method, status and duration
                    HStack(spacing: 7) {
                        methodBadge(log.method, log.statusCode)

                        statusBadge(log.statusCode)

                        Spacer(minLength: 4)

                        durationView(log.duration)
                    }

                    // Host
                    Text(parts.host)
                        .font(
                            .system(
                                size: 13,
                                weight: .medium
                            )
                        )
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .textSelection(.enabled)

                    // Path
                    if !parts.path.isEmpty {
                        Text(parts.path)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .textSelection(.enabled)
                    }

                    // Timestamp
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))

                        Text(
                            timeFormatter.string(
                                from: log.timestamp
                            )
                        )
                        .font(.system(size: 12))
                    }
                    .foregroundColor(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(
                        .system(
                            size: 13,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(
                        Color.secondary.opacity(0.65)
                    )
            }
            .padding(.leading, 12)
            .padding(.trailing, 16)
            .padding(.vertical, 12)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color(uiColor: .systemBackground)
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.secondary.opacity(0.16))
                .frame(height: 0.5)
                .padding(.leading, 36)
        }
    }

    // MARK: - URL Formatting

    private func splitURL(
        _ rawURL: String
    ) -> (host: String, path: String) {
        guard
            let components = URLComponents(string: rawURL),
            let host = components.host
        else {
            return (rawURL, "")
        }

        let hostWithPort: String

        if let port = components.port {
            hostWithPort = "\(host):\(port)"
        } else {
            hostWithPort = host
        }

        let path = components.percentEncodedPath
        let query = components.percentEncodedQuery.map {
            "?\($0)"
        } ?? ""

        return (
            hostWithPort,
            path + query
        )
    }

    // MARK: - Method Badge

    private func methodBadge(
        _ method: String,
        _ statusCode: Int?
    ) -> some View {
        Text(method.uppercased())
            .font(
                .system(
                    size: 11,
                    weight: .bold
                )
            )
            .foregroundColor(DebugUIStyle.statusColor(statusCode))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                DebugUIStyle.statusColor(statusCode).opacity(0.12)
            )
            .clipShape(Capsule())
    }

    // MARK: - Status Badge

    private func statusBadge(
        _ statusCode: Int?
    ) -> some View {
        let color = DebugUIStyle.statusColor(statusCode)
        let title = statusCode.map {
            String($0)
        } ?? "Pending"

        return Text(title)
            .font(
                .system(
                    size: 11,
                    weight: .bold
                )
            )
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                color.opacity(0.12)
            )
            .clipShape(Capsule())
    }

    // MARK: - Duration

    private func durationView(
        _ duration: TimeInterval
    ) -> some View {
        Text(
            String(
                format: "%.0f ms",
                duration * 1000
            )
        )
        .font(
            .system(
                size: 12,
                weight: .medium
            )
        )
        .foregroundColor(.secondary)
        .fixedSize()
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()

            Image(
                systemName: searchText.isEmpty
                    ? "arrow.left.arrow.right.circle"
                    : "magnifyingglass"
            )
            .font(.system(size: 42, weight: .medium))
            .foregroundColor(DebugUIStyle.accent)

            Text(
                searchText.isEmpty
                    ? "No Network Requests"
                    : "No Matching Requests"
            )
            .font(
                .system(
                    size: 17,
                    weight: .semibold
                )
            )
            .foregroundColor(.primary)

            Text(
                searchText.isEmpty
                    ? "HTTP requests will appear here."
                    : "Try another URL, method or status code."
            )
            .font(DebugUIStyle.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)

            if !searchText.isEmpty ||
                selectedFilter != .all {
                Button("Reset Filters") {
                    searchText = ""
                    selectedFilter = .all
                }
                .font(
                    .system(
                        size: 13,
                        weight: .semibold
                    )
                )
                .foregroundColor(DebugUIStyle.accent)
                .padding(.top, 4)
            }

            Spacer()
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .padding()
    }

    // MARK: - Actions

    private func clearLogs() {
        searchText = ""
        selectedFilter = .all

        if previewLogs != nil {
            logs.removeAll()
        } else {
            recorder.clear()
            refresh()
        }
    }

    private func refresh() {
        guard previewLogs == nil else {
            return
        }

        logs = recorder.allLogs()
    }
}

// MARK: - Preview

#if DEBUG
struct NetworkInspectorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NetworkInspectorView(
                previewLogs: DebugPreviewData.networkLogs
            )
        }
        .navigationViewStyle(.stack)
    }
}
#endif
