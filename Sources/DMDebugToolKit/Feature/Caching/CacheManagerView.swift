import SwiftUI
import Foundation

struct CacheManagerView: View {

    var onBack: () -> Void = {}

    @State private var snapshot = CacheManagerSnapshot()
    @State private var isRefreshing = false
    @State private var isClearing = false
    @State private var showRefreshFeedback = false
    @State private var refreshFeedbackID = UUID()
    @State private var activeAlert: CacheManagerAlert?
    @State private var lastUpdated = Date()

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                navigationHeader

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                    overviewCard

                    sectionTitle("Cache Details")

                    VStack(spacing: 8) {
                        detailRow(
                            title: "App Cache Files",
                            subtitle: "Library/Caches directory",
                            value: CacheManagerSnapshot.formattedBytes(
                                snapshot.cachesDirectoryBytes
                            ),
                            icon: "folder",
                            color: DebugUIStyle.info
                        )

                        detailRow(
                            title: "HTTP Memory Cache",
                            subtitle: "URLCache in-memory responses",
                            value: CacheManagerSnapshot.formattedBytes(
                                Int64(snapshot.urlCacheMemoryBytes)
                            ),
                            icon: "memorychip",
                            color: DebugUIStyle.success
                        )

                        detailRow(
                            title: "HTTP Disk Cache",
                            subtitle: "URLCache disk responses",
                            value: CacheManagerSnapshot.formattedBytes(
                                Int64(snapshot.urlCacheDiskBytes)
                            ),
                            icon: "internaldrive",
                            color: DebugUIStyle.warning
                        )
                    }

                    clearCacheButton

                    Text(
                        "Clear Cache removes URLCache responses and files stored in the app's Caches directory. It does not clear UserDefaults, Keychain, or your app database."
                    )
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
                .disabled(isClearing)
            }

            if isClearing {
                ProgressView("Clearing cache...")
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.15))
            }

            if showRefreshFeedback {
                VStack {
                    Spacer()

                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Cache usage refreshed")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.black.opacity(0.88))
                    )
                    .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 5)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(2)
                .allowsHitTesting(false)
            }
        }
        .onAppear { refreshStats(showFeedback: false) }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .confirmClear:
                return Alert(
                    title: Text("Clear Cache?"),
                    message: Text(
                        "This removes cached HTTP responses and files in Library/Caches. App settings, login tokens, and database contents will not be intentionally cleared."
                    ),
                    primaryButton: .destructive(Text("Clear Cache")) {
                        clearCache()
                    },
                    secondaryButton: .cancel()
                )

            case .result(let message):
                return Alert(
                    title: Text("Cache Manager"),
                    message: Text(message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // MARK: - Navigation Header

    private var navigationHeader: some View {
        HStack {
            DebugBackButton(action: onBack)

            Spacer()

            Color.clear
                .frame(width: 40, height: 40)
        }
        .overlay {
            Text("Cache Manager")
                .font(
                    .system(
                        size: 16,
                        weight: .medium
                    )
                )
                .foregroundColor(.primary)
                .lineLimit(1)
                .allowsHitTesting(false)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Overview

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "externaldrive")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DebugUIStyle.warning)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(DebugUIStyle.warning.opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("App Cache Storage")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text("Library/Caches")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 4)

                Button { refreshStats(showFeedback: true) } label: {
                    Group {
                        if isRefreshing {
                            ProgressView()
                                .scaleEffect(0.75)
                                .frame(width: 34, height: 34)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .frame(width: 34, height: 34)
                        }
                    }
                    .background(
                        Circle()
                            .fill(Color(uiColor: .tertiarySystemBackground))
                    )
                }
                .buttonStyle(.plain)
                .disabled(isRefreshing || isClearing)
                .accessibilityLabel("Refresh cache usage")
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(
                    CacheManagerSnapshot.formattedBytes(
                        snapshot.cachesDirectoryBytes
                    )
                )
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

                Spacer(minLength: 0)

                Text("\(snapshot.fileCount) files")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 5) {
                Image(systemName: "clock")
                Text("Updated \(lastUpdated.formatted(date: .omitted, time: .shortened))")
            }
            .font(.system(size: 11))
            .foregroundStyle(.tertiary)

        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }

    // MARK: - Details

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(DebugUIStyle.sectionTitle)
            .foregroundStyle(.secondary)
            .padding(.leading, 2)
    }

    private func detailRow(
        title: String,
        subtitle: String,
        value: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(color.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }

    // MARK: - Clear Cache

    private var clearCacheButton: some View {
        Button {
            activeAlert = .confirmClear
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .semibold))

                Text("Clear Cache")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red)
            )
        }
        .buttonStyle(.plain)
        .disabled(isClearing || isRefreshing)
        .opacity(isClearing || isRefreshing ? 0.6 : 1)
    }

    // MARK: - Actions

    private func refreshStats(showFeedback: Bool = true) {
        guard !isRefreshing && !isClearing else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            isRefreshing = true
            showRefreshFeedback = false
        }

        DispatchQueue.global(qos: .utility).async {
            let updatedSnapshot = CacheManagerSnapshot.load()

            DispatchQueue.main.async {
                snapshot = updatedSnapshot
                lastUpdated = Date()

                withAnimation(.easeInOut(duration: 0.2)) {
                    isRefreshing = false
                    showRefreshFeedback = showFeedback
                }

                guard showFeedback else { return }

                // Hide the success feedback after a short moment.
                let feedbackID = UUID()
                refreshFeedbackID = feedbackID

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    guard refreshFeedbackID == feedbackID else { return }

                    withAnimation(.easeInOut(duration: 0.2)) {
                        showRefreshFeedback = false
                    }
                }
            }
        }
    }

    private func clearCache() {
        guard !isClearing else { return }
        isClearing = true

        DispatchQueue.global(qos: .utility).async {
            let failedCount = CacheManagerStorage.clearCacheFiles()
            let updatedSnapshot = CacheManagerSnapshot.load()

            DispatchQueue.main.async {
                snapshot = updatedSnapshot
                lastUpdated = Date()
                isClearing = false

                if let failedCount {
                    if failedCount == 0 {
                        activeAlert = .result("Cache cleared successfully.")
                    } else {
                        activeAlert = .result(
                            "HTTP cache was cleared, but \(failedCount) item(s) could not be removed from the Caches directory."
                        )
                    }
                } else {
                    activeAlert = .result(
                        "HTTP cache was cleared, but the Caches directory could not be fully inspected or cleared."
                    )
                }
            }
        }
    }
}

// MARK: - Cache Snapshot

private struct CacheManagerSnapshot {
    var cachesDirectoryBytes: Int64 = 0
    var urlCacheMemoryBytes: Int = 0
    var urlCacheDiskBytes: Int = 0
    var fileCount: Int = 0

    static func load() -> CacheManagerSnapshot {
        let fileManager = FileManager.default
        var directoryBytes: Int64 = 0
        var numberOfFiles = 0

        if let cachesURL = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first {
            let keys: Set<URLResourceKey> = [
                .isRegularFileKey,
                .fileSizeKey
            ]

            let enumerator = fileManager.enumerator(
                at: cachesURL,
                includingPropertiesForKeys: Array(keys),
                options: [],
                errorHandler: { _, _ in true }
            )

            while let fileURL = enumerator?.nextObject() as? URL {
                guard let values = try? fileURL.resourceValues(forKeys: keys),
                      values.isRegularFile == true else {
                    continue
                }

                directoryBytes += Int64(max(values.fileSize ?? 0, 0))
                numberOfFiles += 1
            }
        }

        let urlCache = URLCache.shared

        return CacheManagerSnapshot(
            cachesDirectoryBytes: directoryBytes,
            urlCacheMemoryBytes: urlCache.currentMemoryUsage,
            urlCacheDiskBytes: urlCache.currentDiskUsage,
            fileCount: numberOfFiles
        )
    }

    static func formattedBytes(_ bytes: Int64) -> String {
        ByteCountFormatter.string(
            fromByteCount: max(bytes, 0),
            countStyle: .file
        )
    }
}

// MARK: - Cache Storage

private enum CacheManagerStorage {

    /// Clears shared HTTP responses and files stored in the app Caches directory.
    /// This does not touch UserDefaults, Keychain, Documents, or app databases.
    static func clearCacheFiles() -> Int? {
        URLCache.shared.removeAllCachedResponses()

        guard let cachesURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }

        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: cachesURL,
                includingPropertiesForKeys: nil,
                options: []
            )

            var failedCount = 0

            for itemURL in contents {
                do {
                    try FileManager.default.removeItem(at: itemURL)
                } catch {
                    failedCount += 1
                }
            }

            return failedCount
        } catch {
            return nil
        }
    }
}

// MARK: - Cache Manager Alert

private enum CacheManagerAlert: Identifiable {
    case confirmClear
    case result(String)

    var id: String {
        switch self {
        case .confirmClear:
            return "confirmClear"
        case .result(let message):
            return "result-\(message)"
        }
    }
}

#if DEBUG
struct CacheManagerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CacheManagerView()
                .preferredColorScheme(.light)
                .previewDisplayName("Cache Manager - Light")

            CacheManagerView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Cache Manager - Dark")
        }
    }
}
#endif
