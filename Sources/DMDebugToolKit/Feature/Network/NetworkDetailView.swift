import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct NetworkDetailView: View {
    
    let log: NetworkLog
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    @State private var copiedItem: String?
    @State private var expandedSections: Set<String> = [
        "INFO",
        "REQUEST",
        "RESPONSE"
    ]
    @State private var isActionMenuPresented = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                navigationHeader

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        // MARK: - INFO
                        sectionContainer(
                            title: "INFO",
                            color: DebugUIStyle.accent
                        ) {
                            VStack(spacing: 0) {
                                infoRow(
                                    title: "URL",
                                    value: log.url,
                                    copyID: "info-url"
                                )

                                infoRow(
                                    title: "Method",
                                    value: log.method,
                                    copyID: "info-method"
                                )

                                infoRow(
                                    title: "Status",
                                    value: "\(log.statusCode ?? 0)",
                                    copyID: "info-status"
                                )

                                infoRow(
                                    title: "Time interval",
                                    value: String(
                                        format: "%.8f",
                                        log.duration
                                    ),
                                    copyID: "info-duration"
                                )
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        // MARK: - REQUEST
                        sectionContainer(
                            title: "REQUEST",
                            color: DebugUIStyle.info
                        ) {
                            subsectionTitle("Headers", color: DebugUIStyle.info)

                            headersView(
                                log.requestHeaders,
                                color: DebugUIStyle.info,
                                prefix: "request-header"
                            )

                            if let requestBody = log.requestBody {
                                subsectionTitle("Body", color: DebugUIStyle.info)

                                bodyView(
                                    requestBody,
                                    color: DebugUIStyle.info,
                                    copyID: "request-body"
                                )
                            }
                        }

                        // MARK: - RESPONSE
                        sectionContainer(
                            title: "RESPONSE",
                            color: DebugUIStyle.success
                        ) {
                            subsectionTitle("Headers", color: DebugUIStyle.success)

                            headersView(
                                log.responseHeaders,
                                color: DebugUIStyle.success,
                                prefix: "response-header"
                            )

                            if let responseBody = log.responseBody {
                                subsectionTitle("Body", color: DebugUIStyle.success)

                                bodyView(
                                    responseBody,
                                    color: DebugUIStyle.success,
                                    copyID: "response-body"
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)

            // Keep the dismissing backdrop and popup inside the same ZStack
            // so the popup overlays the detail screen.
            if isActionMenuPresented {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.15)) {
                            isActionMenuPresented = false
                        }
                    }
                    .zIndex(1)

                actionMenuPopup
                    .padding(.top, 48)
                    .padding(.trailing, 16)
                    .transition(
                        .opacity.combined(
                            with: .scale(
                                scale: 0.95,
                                anchor: .topTrailing
                            )
                        )
                    )
                    .zIndex(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .animation(.easeOut(duration: 0.15), value: isActionMenuPresented)
    }

    // MARK: - Navigation Header
    
    private var navigationHeader: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(DebugUIStyle.success)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(DebugUIStyle.success.opacity(0.10))
                        )
                        .contentShape(Circle())
                }
                .foregroundStyle(
                    DebugUIStyle.accent
                )
            }
            
            Spacer()
            
            Text(urlTitle)
                .font(
                    .system(
                        size: 14,
                        weight: .semibold
                    )
                )
            
            Spacer()
            
Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    isActionMenuPresented.toggle()
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(DebugUIStyle.success)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(DebugUIStyle.success.opacity(0.10))
                    )
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .frame(minWidth: 62, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(
            Color(.systemBackground)
        )
    }
    
    // MARK: - Custom Action Menu

    private var actionMenuPopup: some View {
        VStack(spacing: 0) {
            actionMenuRow(
                title: "Copy All",
                subtitle: "Copy all request details",
                icon: "doc.on.doc",
                tint: DebugUIStyle.success
            ) {
                copyAll()
            }

            actionMenuDivider

            actionMenuRow(
                title: "Copy as cURL",
                subtitle: "Copy command for debugging",
                icon: "terminal",
                tint: DebugUIStyle.info
            ) {
                copyAsCurl()
            }

            actionMenuDivider

            actionMenuRow(
                title: "Export JSON",
                subtitle: "Share request details as JSON",
                icon: "doc.text",
                tint: DebugUIStyle.warning
            ) {
                shareJSON()
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .frame(width: 280)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.16), radius: 22, x: 0, y: 10)
    }

    private var actionMenuDivider: some View {
        Divider()
            .padding(.leading, 54)
            .padding(.trailing, 8)
    }

    private func actionMenuRow(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) {
                isActionMenuPresented = false
            }

            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(tint)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(tint.opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func shareJSON() {
        let activityVC = UIActivityViewController(
            activityItems: [exportJSON],
            applicationActivities: nil
        )

        guard
            let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
            let rootVC = scene.windows.first(where: \.isKeyWindow)?
                .rootViewController
        else {
            return
        }

        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(
                x: topVC.view.bounds.midX,
                y: topVC.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        topVC.present(activityVC, animated: true)
    }
    
    private func copyAsCurl() {
        var command = "curl"
        
        command += " -X \(shellEscape(log.method))"
        command += " \(shellEscape(log.url))"
        
        for key in log.requestHeaders.keys.sorted() {
            let value = log.requestHeaders[key] ?? ""
            let header = "\(key): \(value)"
            
            command += " -H \(shellEscape(header))"
        }
        
        if let body = log.requestBody, !body.isEmpty {
            command += " --data-raw \(shellEscape(body))"
        }
        
        UIPasteboard.general.string = command
        copiedItem = "curl"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if copiedItem == "curl" {
                copiedItem = nil
            }
        }
    }
    
    private var exportJSON: String {
        let data: [String: Any] = [
            "url": log.url,
            "method": log.method,
            "statusCode": log.statusCode as Any? ?? NSNull(),
            "duration": log.duration,
            "requestHeaders": log.requestHeaders,
            "requestBody": log.requestBody as Any? ?? NSNull(),
            "responseHeaders": log.responseHeaders,
            "responseBody": log.responseBody as Any? ?? NSNull()
        ]
        
        guard
            let jsonData = try? JSONSerialization.data(
                withJSONObject: data,
                options: [.prettyPrinted, .sortedKeys]
            ),
            let json = String(data: jsonData, encoding: .utf8)
        else {
            return "{}"
        }
        
        return json
    }
    
    private func shellEscape(_ value: String) -> String {
        "'" + value.replacingOccurrences(
            of: "'",
            with: "'\\''"
        ) + "'"
    }
    
    private var urlTitle: String {
        let components = log.url
            .components(separatedBy: "/")
            .filter { !$0.isEmpty }
        
        guard !components.isEmpty else {
            return "Request"
        }
        
        return components
            .suffix(2)
            .joined(separator: "/")
    }
    
    // MARK: - Section
    
    
    
    
    private func sectionContainer<Content: View>(
        title: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let isExpanded = expandedSections.contains(title)

        return VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    if isExpanded {
                        expandedSections.remove(title)
                    } else {
                        expandedSections.insert(title)
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: {
                        switch title {
                        case "INFO": return "info.circle.fill"
                        case "REQUEST": return "arrow.up.right.circle.fill"
                        default: return "arrow.down.left.circle.fill"
                        }
                    }())
                    .font(.system(size: 20))
                    .foregroundStyle(color)

                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(color)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(color)
                        .rotationEffect(
                            .degrees(isExpanded ? 0 : -90)
                        )
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(color.opacity(0.07))

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    content()
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity)
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color.opacity(0.18), lineWidth: 1)
        )
    }


    
    // MARK: - Subsection
    
    private func subsectionTitle(
        _ title: String,
        color: Color
    ) -> some View {
        
        HStack(spacing: 7) {
            
            Image(
                systemName:
                    title == "Headers"
                ? "list.bullet.rectangle"
                : "doc.text"
            )
            .font(
                .system(
                    size: 14,
                    weight: .semibold
                )
            )
            .foregroundStyle(color)
            
            Text(title)
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.primary)
        }
        .padding(.top, 2)
    }
    
    // MARK: - Info Row
    private func infoRow(
        title: String,
        value: String,
        copyID: String
    ) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)

            Text(value.isEmpty ? "-" : value)
                .font(.system(size: 12))
                .foregroundStyle(.primary)
                .textSelection(.enabled)
                .lineLimit(title == "URL" ? 3 : 1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            copyButton(
                value: value.isEmpty ? "-" : value,
                id: copyID
            )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            DebugUIStyle.rowBackground(index: infoRowIndex(title))
        )
    }
    
    private func infoRowIndex(_ title: String) -> Int {
        switch title {
        case "URL": return 0
        case "Method": return 1
        case "Status": return 2
        default: return 3
        }
    }
    // MARK: - Headers
    
    private func headersView(
        _ headers: [String: String],
        color: Color,
        prefix: String
    ) -> some View {
        
        let keys = headers.keys.sorted()
        
        return VStack(spacing: 0) {
            if keys.isEmpty {
                HStack {
                    Text("No headers")
                        .font(DebugUIStyle.body)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding(12)
                
            } else {
                
                ForEach(
                    keys.indices,
                    id: \.self
                ) { index in
                    
                    let key = keys[index]
                    let value = headers[key] ?? ""
                    
                    headerRow(
                        title: key,
                        value: value,
                        color: color,
                        copyID: "\(prefix)-\(key)",
                        index: index
                    )
                }
            }
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: DebugUIStyle.cardRadius
            )
        )
    }
    
    // MARK: - Header Row

    private func headerRow(
        title: String,
        value: String,
        color: Color,
        copyID: String,
        index: Int
    ) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(width: 130, alignment: .leading)

            Text(value.isEmpty ? "-" : value)
                .font(.system(size: 12))
                .foregroundStyle(.primary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)

            copyButton(value: value, id: copyID)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(
            DebugUIStyle.rowBackground(index: index)
        )
    }

    // MARK: - Body
    
    private func bodyView(
        _ value: String,
        color: Color,
        copyID: String
    ) -> some View {
        
        VStack(
            alignment: .leading,
            spacing: 0
        ) {
            
            HStack {
                
                Text("Body")
                    .font(DebugUIStyle.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                copyButton(
                    value: value,
                    id: copyID
                )
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            
            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                
                Text(value)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(12)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius: DebugUIStyle.cardRadius
            )
            .fill(
                DebugUIStyle.cardBackground
            )
        )
    }
    
    // MARK: - Copy Button
    
    private func copyButton(
        value: String,
        id: String
    ) -> some View {
        
        Button {
            
            copy(
                value: value,
                id: id
            )
            
        } label: {
            
            Image(
                systemName:
                    copiedItem == id
                ? "checkmark"
                : "doc.on.doc"
            )
            .font(
                .system(
                    size: 13,
                    weight: .medium
                )
            )
            .foregroundStyle(
                copiedItem == id
                ? DebugUIStyle.success
                : DebugUIStyle.accent
            )
            .frame(
                width: 28,
                height: 28
            )
            .background(
                Circle()
                    .fill(
                        copiedItem == id
                        ? DebugUIStyle.success.opacity(0.10)
                        : DebugUIStyle.accentSoft
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Copy
    
    private func copy(
        value: String,
        id: String
    ) {
        guard !value.isEmpty else {
            copiedItem = id
            return
        }
        
        UIPasteboard.general.setValue(
            value,
            forPasteboardType: "public.utf8-plain-text"
        )
        
        print("COPY VALUE:", value)
        print(
            "PASTEBOARD VALUE:",
            UIPasteboard.general.string ?? "NIL"
        )
        
        copiedItem = id
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1.2
        ) {
            if copiedItem == id {
                copiedItem = nil
            }
        }
    }
    
    // MARK: - Copy All
    
    private func copyAll() {
        
        var output = ""
        
        output += """
        ** INFO **
        
        [URL]
        \(log.url)
        
        [Method]
        \(log.method)
        
        [Status]
        \(log.statusCode ?? 0)
        
        [Time interval]
        \(String(format: "%.8f", log.duration))
        
        
        """
        
        output += """
        ** REQUEST **
        -- Headers --
        
        """
        
        for key in log.requestHeaders.keys.sorted() {
            output += """
            [\(key)]
            \(log.requestHeaders[key] ?? "")
            
            """
        }
        
        if let requestBody = log.requestBody {
            output += """
            
            -- Body --
            
            \(requestBody)
            
            """
        }
        
        output += """
        
        ** RESPONSE **
        -- Headers --
        
        """
        
        for key in log.responseHeaders.keys.sorted() {
            output += """
            [\(key)]
            \(log.responseHeaders[key] ?? "")
            
            """
        }
        
        if let responseBody = log.responseBody {
            output += """
            
            -- Body --
            
            \(responseBody)
            
            """
        }
        
        UIPasteboard.general.setValue(
            output,
            forPasteboardType: "public.utf8-plain-text"
        )
        
        print("COPY ALL:")
        print(output)
        print(
            "PASTEBOARD:",
            UIPasteboard.general.string ?? "NIL"
        )
        
        copiedItem = "all"
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1.2
        ) {
            if copiedItem == "all" {
                copiedItem = nil
            }
        }
    }
}

#if DEBUG
struct NetworkDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NetworkDetailView(
                log: DebugPreviewData.networkLogs[0]
            )
        }
    }
}
#endif
