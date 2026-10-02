import SwiftUI

struct NetworkInspectorView: View {
    
    @State private var logs: [NetworkLog] = []
    private let previewLogs: [NetworkLog]?
    private let recorder =
    NetworkRecorder.shared
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    init(
        previewLogs: [NetworkLog]? = nil
    ) {
        self.previewLogs = previewLogs
        
        _logs = State(
            initialValue: previewLogs ?? []
        )
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            navigationHeader
            
            Divider()
            
            if logs.isEmpty {
                emptyState
            } else {
                networkList
            }
        }
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
                
                refresh()
            }
        }
    }
    
    // MARK: - Navigation Header
    
    private var navigationHeader: some View {
        
        HStack {
            
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                
                HStack(spacing: 4) {
                    
                    Image(systemName: "chevron.left")
                        .font(
                            .system(
                                size: 22,
                                weight: .regular
                            )
                        )
                    
                    Text("Back")
                        .font(
                            .system(
                                size: 17,
                                weight: .regular
                            )
                        )
                }
                .foregroundStyle(
                    DebugUIStyle.accent
                )
            }
            
            Spacer()
            
            Text("Network Inspector")
                .font(
                    .system(
                        size: 17,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button("Clear") {
                recorder.clear()
                refresh()
            }
            .font(
                .system(
                    size: 17,
                    weight: .regular
                )
            )
            .foregroundStyle(
                DebugUIStyle.accent
            )
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(
            Color(.systemBackground)
        )
    }
    
    // MARK: - List
    
    private var networkList: some View {
        
        List {
            
            ForEach(
                logs.indices,
                id: \.self
            ) { index in
                
                let log = logs[index]
                
                NavigationLink {
                    NetworkDetailView(
                        log: log
                    )
                } label: {
                    
                    networkRow(log)
                }
                .listRowInsets(
                    EdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 10
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
    
    // MARK: - Network Row
    
    private func networkRow(
        _ log: NetworkLog
    ) -> some View {
        
        VStack(
            alignment: .leading,
            spacing: 5
        ) {
            
            HStack(spacing: 7) {
                
                methodBadge(
                    log.method
                )
                
                statusBadge(
                    log.statusCode
                )
                
                Spacer()
                
                durationView(
                    log.duration
                )
            }
            
            Text(log.url)
                .font(DebugUIStyle.body)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            Text(
                timeFormatter.string(
                    from: log.timestamp
                )
            )
            .font(DebugUIStyle.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    // MARK: - Method
    
    private func methodBadge(
        _ method: String
    ) -> some View {
        
        Text(method)
            .font(
                .system(
                    size: 10,
                    weight: .bold
                )
            )
            .foregroundStyle(
                DebugUIStyle.accent
            )
            .padding(
                .horizontal,
                7
            )
            .padding(
                .vertical,
                4
            )
            .background(
                Capsule()
                    .fill(
                        DebugUIStyle.accentSoft
                    )
            )
    }
    
    // MARK: - Status
    
    private func statusBadge(
        _ statusCode: Int?
    ) -> some View {
        
        let color =
        DebugUIStyle.statusColor(
            statusCode
        )
        
        return Text(
            "\(statusCode ?? 0)"
        )
        .font(
            .system(
                size: 10,
                weight: .bold
            )
        )
        .foregroundStyle(color)
        .padding(
            .horizontal,
            7
        )
        .padding(
            .vertical,
            4
        )
        .background(
            Capsule()
                .fill(
                    color.opacity(0.12)
                )
        )
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
        .foregroundStyle(.secondary)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        
        VStack(spacing: 10) {
            
            Spacer()
            
            Image(
                systemName:
                    "arrow.left.arrow.right.circle"
            )
            .font(
                .system(
                    size: 42,
                    weight: .medium
                )
            )
            .foregroundStyle(
                DebugUIStyle.accent
            )
            
            Text("No Network Requests")
                .font(
                    .system(
                        size: 18,
                        weight: .semibold
                    )
                )
            
            Text(
                "HTTP requests will appear here."
            )
            .font(DebugUIStyle.body)
            .foregroundStyle(.secondary)
            
            Spacer()
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
    
    // MARK: - Refresh
    
    private func refresh() {
        logs = recorder.allLogs()
    }
}

#if DEBUG
struct NetworkInspectorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NetworkInspectorView(
                previewLogs:
                    DebugPreviewData.networkLogs
            )
        }
    }
}
#endif
