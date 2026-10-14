
import SwiftUI

struct NetworkInspectorView: View {

    @State private var logs: [NetworkLog] = []
    @State private var searchText = ""

    private let previewLogs: [NetworkLog]?
    private let recorder = NetworkRecorder.shared

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    init(previewLogs: [NetworkLog]? = nil) {
        self.previewLogs = previewLogs
        _logs = State(initialValue: previewLogs ?? [])
    }

    // MARK: - Filtered Logs

    private var filteredLogs: [NetworkLog] {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty else {
            return logs
        }

        return logs.filter { log in
            log.url.localizedCaseInsensitiveContains(query) ||
            log.method.localizedCaseInsensitiveContains(query) ||
            String(log.statusCode ?? 0).contains(query)
        }
    }

    private var failedCount: Int {
        filteredLogs.filter {
            ($0.statusCode ?? 0) >= 400
        }.count
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            navigationHeader

            searchBar

            overviewBar

            Divider()

            if filteredLogs.isEmpty {
                emptyState
            } else {
                networkList
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
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
                .padding(.horizontal, 12)
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
        .padding(.vertical, 8)
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(
                    .system(
                        size: 15,
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
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Overview

    private var overviewBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(DebugUIStyle.accent)

            Text(
                "\(filteredLogs.count) Request\(filteredLogs.count == 1 ? "" : "s")"
            )
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.primary)

            Spacer()

            if failedCount > 0 {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 11))

                Text("\(failedCount) failed")
                    .font(.system(size: 12, weight: .medium))
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 11))

                Text("No failures")
                    .font(.system(size: 12, weight: .medium))
            }
        }
        .foregroundColor(
            failedCount > 0
                ? DebugUIStyle.critical
                : DebugUIStyle.success
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Network List

    private var networkList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(
                    filteredLogs.indices,
                    id: \.self
                ) { index in
                    let log = filteredLogs[index]

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
        VStack(spacing: 0) {
            HStack(spacing: 12) {

                // Status indicator
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        DebugUIStyle.statusColor(log.statusCode)
                    )
                    .frame(width: 4)

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    // Method, status and duration
                    HStack(spacing: 6) {
                        methodBadge(log.method)
                        statusBadge(log.statusCode)

                        Spacer(minLength: 4)

                        durationView(log.duration)
                    }

                    // Request URL
                    Text(log.url)
                        .font(
                            .system(
                                size: 13,
                                weight: .medium
                            )
                        )
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .truncationMode(.middle)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .textSelection(.enabled)

                    // Timestamp and navigation indicator
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))

                        Text(
                            timeFormatter.string(
                                from: log.timestamp
                            )
                        )
                        .font(.system(size: 11))
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.vertical, 12)
                .padding(.trailing, 14)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                DebugUIStyle.rowBackground(index: index)
            )

            Divider()
                .padding(.leading, 16)
        }
    }
    
    // MARK: - Method Badge

    private func methodBadge(
        _ method: String
    ) -> some View {
        Text(method.uppercased())
            .font(
                .system(
                    size: 10,
                    weight: .bold
                )
            )
            .foregroundColor(DebugUIStyle.accent)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(DebugUIStyle.accentSoft)
            .clipShape(Capsule())
    }

    // MARK: - Status Badge

    private func statusBadge(
        _ statusCode: Int?
    ) -> some View {
        let color = DebugUIStyle.statusColor(statusCode)
        let title = statusCode.map { String($0) } ?? "Pending"

        return Text(title)
            .font(
                .system(
                    size: 10,
                    weight: .bold
                )
            )
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
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
                size: 11,
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
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.primary)

            Text(
                searchText.isEmpty
                    ? "HTTP requests will appear here."
                    : "Try searching with another URL or status code."
            )
            .font(DebugUIStyle.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)

            if !searchText.isEmpty {
                Button("Clear Search") {
                    searchText = ""
                }
                .font(.system(size: 13, weight: .semibold))
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
