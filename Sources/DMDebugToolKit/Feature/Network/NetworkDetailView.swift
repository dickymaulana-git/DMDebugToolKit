
import SwiftUI
import UIKit

struct NetworkDetailView: View {

    let log: NetworkLog
    @State private var showCopyToast = false
    @State private var copyToastMessage = "Berhasil disalin"
    
    @Environment(\.presentationMode)
    private var presentationMode

    @State private var copiedItem: String?
    @State private var expandedSections: Set<String> = [
        "INFO",
        "REQUEST",
        "RESPONSE"
    ]
    @State private var isActionMenuPresented = false

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                navigationHeader

                ScrollView(showsIndicators: false) {
                    VStack(
                        alignment: .leading,
                        spacing: 16
                    ) {
                        // MARK: - INFO

                        sectionContainer(
                            title: "INFO",
                            color: DebugUIStyle.accent
                        ) {
                            VStack(spacing: 6) {
                                infoRow(
                                    title: "BASE URL",
                                    value: baseURL,
                                    copyID: "info-base-url"
                                )
                                
                                infoRow(
                                    title: "ENDPOINT",
                                    value: endpoint,
                                    copyID: "info-endpoint"
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
                                        format: "%.8f s (%.0f ms)",
                                        log.duration,
                                        log.duration * 1000
                                    ),
                                    copyID: "info-duration"
                                )
                            }
                        }

                        // MARK: - REQUEST

                        sectionContainer(
                            title: "REQUEST",
                            color: DebugUIStyle.info
                        ) {
                            subsectionTitle(
                                "Headers",
                                color: DebugUIStyle.info
                            )

                            headersView(
                                log.requestHeaders,
                                color: DebugUIStyle.info,
                                prefix: "request-header"
                            )

                            if let requestBody = log.requestBody {
                                subsectionTitle(
                                    "Body",
                                    color: DebugUIStyle.info
                                )

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
                            subsectionTitle(
                                "Headers",
                                color: DebugUIStyle.success
                            )

                            headersView(
                                log.responseHeaders,
                                color: DebugUIStyle.success,
                                prefix: "response-header"
                            )

                            if let responseBody = log.responseBody {
                                subsectionTitle(
                                    "Body",
                                    color: DebugUIStyle.success
                                )

                                bodyView(
                                    responseBody,
                                    color: DebugUIStyle.success,
                                    copyID: "response-body"
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarHidden(true)

            // MARK: - Action Menu Overlay

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
            if showCopyToast {
                VStack {
                    Spacer()

                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)

                        Text(copyToastMessage)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Color.green.opacity(0.95),
                        in: Capsule()
                    )
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
                .zIndex(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .navigationBarHidden(true)
        .animation(
            .easeOut(duration: 0.15),
            value: isActionMenuPresented
        )
    }

    private func showCopySuccess(_ message: String = "Berhasil disalin") {
        copyToastMessage = message

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showCopyToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.2)) {
                showCopyToast = false
            }
        }
    }
    
    // MARK: - URL Components

    private var baseURL: String {
        guard let components = URLComponents(string: log.url),
              let scheme = components.scheme,
              let host = components.host else {
            return log.url
        }

        let port = components.port.map { ":\($0)" } ?? ""

        return "\(scheme)://\(host)\(port)"
    }

    private var endpoint: String {
        guard let components = URLComponents(string: log.url) else {
            return ""
        }

        let path = components.path
        let query = components.percentEncodedQuery.map { "?\($0)" } ?? ""

        return path + query
    }
    
    // MARK: - Navigation Header

    private var navigationHeader: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(
                        .system(
                            size: 18,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(DebugUIStyle.success)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(
                                DebugUIStyle.success.opacity(0.10)
                            )
                    )
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8)

            Text(urlTitle)
                .font(
                    .system(
                        size: 16,
                        weight: .medium
                    )
                )
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity)
                .allowsHitTesting(false)

            Spacer(minLength: 8)

            Button {
                withAnimation(
                    .spring(
                        response: 0.28,
                        dampingFraction: 0.86
                    )
                ) {
                    isActionMenuPresented.toggle()
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(DebugUIStyle.success)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(
                                DebugUIStyle.success.opacity(0.10)
                            )
                    )
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(height: 56)
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Action Menu

    private var actionMenuPopup: some View {
        VStack(spacing: 0) {
            actionMenuRow(
                title: "Copy All",
                subtitle: "Copy all request details",
                icon: "doc.on.doc",
                tint: DebugUIStyle.success
            ) {
                copyAll()
                showCopySuccess("Semua detail berhasil disalin")
            }

            actionMenuDivider

            actionMenuRow(
                title: "Copy as cURL",
                subtitle: "Copy command for debugging",
                icon: "terminal",
                tint: DebugUIStyle.info
            ) {
                copyAsCurl()
                showCopySuccess("cURL berhasil disalin")
            }

            actionMenuDivider

            actionMenuRow(
                title: "Export JSON",
                subtitle: "Share request details as JSON",
                icon: "doc.text",
                tint: DebugUIStyle.warning
            ) {
                shareJSON()
                showCopySuccess("JSON berhasil disalin")
            }
        }
        .padding(6)
        .frame(width: 280)
        .background(Color(uiColor: .systemBackground))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .stroke(
                Color.primary.opacity(0.06),
                lineWidth: 1
            )
        }
        .shadow(
            color: .black.opacity(0.16),
            radius: 22,
            x: 0,
            y: 10
        )
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
                    .font(
                        .system(
                            size: 16,
                            weight: .medium
                        )
                    )
                    .foregroundColor(tint)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 10,
                            style: .continuous
                        )
                        .fill(tint.opacity(0.12))
                    )

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {
                    Text(title)
                        .font(
                            .system(
                                size: 14,
                                weight: .semibold
                            )
                        )
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

    // MARK: - Section Container

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
                    Image(systemName: sectionIcon(for: title))
                        .font(.system(size: 19))
                        .foregroundColor(color)

                    Text(title)
                        .font(
                            .system(
                                size: 15,
                                weight: .bold
                            )
                        )
                        .foregroundColor(color)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(
                            .system(
                                size: 12,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(color)
                        .rotationEffect(
                            .degrees(isExpanded ? 0 : -90)
                        )
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(color.opacity(0.08))

            if isExpanded {
                VStack(
                    alignment: .leading,
                    spacing: 10
                ) {
                    content()
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)
                .padding(.bottom, 4)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .transition(.opacity)
            }
        }
        .background(
            Color(uiColor: .secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
            .stroke(color.opacity(0.18), lineWidth: 1)
        }
    }

    private func sectionIcon(for title: String) -> String {
        switch title {
        case "INFO":
            return "info.circle.fill"
        case "REQUEST":
            return "arrow.up.right.circle.fill"
        default:
            return "arrow.down.left.circle.fill"
        }
    }

    // MARK: - Subsection

    private func subsectionTitle(
        _ title: String,
        color: Color
    ) -> some View {
        HStack(spacing: 7) {
            Image(
                systemName: title == "Headers"
                    ? "list.bullet.rectangle"
                    : "doc.text"
            )
            .font(
                .system(
                    size: 14,
                    weight: .semibold
                )
            )
            .foregroundColor(color)

            Text(title)
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.top, 2)
    }

    // MARK: - INFO Row

    private func infoRow(
        title: String,
        value: String,
        copyID: String
    ) -> some View {
        let displayValue = value.isEmpty ? "-" : value

        return HStack(alignment: .center, spacing: 12) {
            VStack(
                alignment: .leading,
                spacing: 7
            ) {
                Text(title.uppercased())
                    .font(
                        .system(
                            size: 11,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(.secondary)

                if title == "Status",
                   let statusCode = Int(value) {
                    Text(displayValue)
                        .font(
                            .system(
                                size: 13,
                                weight: .bold
                            )
                        )
                        .foregroundColor(
                            DebugUIStyle.statusColor(statusCode)
                        )
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            DebugUIStyle.statusColor(statusCode)
                                .opacity(0.12)
                        )
                        .clipShape(Capsule())
                } else {
                    Text(displayValue)
                        .font(
                            .system(
                                size: 12,
                                weight: .medium
                            )
                        )
                        .foregroundColor(.primary)
                        .textSelection(.enabled)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )

            copyButton(
                value: displayValue,
                id: copyID
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
            .fill(
                DebugUIStyle.rowBackground(
                    index: infoRowIndex(title)
                )
            )
        )
    }

    private func infoRowIndex(_ title: String) -> Int {
        switch title.uppercased() {
        case "URL", "BASE URL", "METHOD":
            return 0
        case "ENDPOINT", "STATUS":
            return 1
        default:
            return 2
        }
    }

    // MARK: - Headers

    private func headersView(
        _ headers: [String: String],
        color: Color,
        prefix: String
    ) -> some View {
        let keys = headers.keys.sorted()

        return VStack(spacing: 6) {
            if keys.isEmpty {
                HStack {
                    Text("No headers")
                        .font(DebugUIStyle.body)
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .padding(12)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(DebugUIStyle.cardBackground)
                )
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
    }

    // MARK: - Header Row

    private func headerRow(
        title: String,
        value: String,
        color: Color,
        copyID: String,
        index: Int
    ) -> some View {
        let displayValue = value.isEmpty ? "-" : value

        return HStack(alignment: .center, spacing: 12) {
            VStack(
                alignment: .leading,
                spacing: 7
            ) {
                Text(title)
                    .font(
                        .system(
                            size: 12,
                            weight: .semibold
                        )
                    )
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)

                Text(displayValue)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .textSelection(.enabled)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )

            copyButton(
                value: displayValue,
                id: copyID
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
            .fill(
                DebugUIStyle.rowBackground(index: index)
            )
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
                    .foregroundColor(.secondary)

                Spacer()

                copyButton(
                    value: value,
                    id: copyID
                )
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)

            ScrollView(
                [.vertical, .horizontal],
                showsIndicators: true
            ) {
                Text(value)
                    .font(
                        .system(
                            size: 12,
                            design: .monospaced
                        )
                    )
                    .foregroundColor(.primary)
                    .textSelection(.enabled)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                    .padding(12)
            }
            .frame(maxHeight: 360)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius: DebugUIStyle.cardRadius
            )
            .fill(DebugUIStyle.cardBackground)
        )
    }

    // MARK: - Copy Button

    private func copyButton(
        value: String,
        id: String
    ) -> some View {
        Button {
            copy(value: value, id: id)
        } label: {
            Image(
                systemName: copiedItem == id
                    ? "checkmark"
                    : "doc.on.doc"
            )
            .font(
                .system(
                    size: 12,
                    weight: .medium
                )
            )
            .foregroundColor(DebugUIStyle.success)
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .fill(
                        DebugUIStyle.success.opacity(0.10)
                    )
            )
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            copiedItem == id ? "Copied" : "Copy \(id)"
        )
    }

    // MARK: - Copy Value

    private func copy(
        value: String,
        id: String
    ) {
        guard !value.isEmpty else {
            return
        }

        UIPasteboard.general.string = value
        copiedItem = id
        showCopySuccess()
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
        var output = """
        ** INFO **

        [URL]
        \(log.url)

        [Method]
        \(log.method)

        [Status]
        \(log.statusCode.map { String($0) } ?? "Pending")

        [Time interval]
        \(String(format: "%.8f s (%.0f ms)", log.duration, log.duration * 1000))


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

        UIPasteboard.general.string = output
        copiedItem = "all"

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1.2
        ) {
            if copiedItem == "all" {
                copiedItem = nil
            }
        }
    }

    // MARK: - Copy as cURL

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

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1.2
        ) {
            if copiedItem == "curl" {
                copiedItem = nil
            }
        }
    }

    private func shellEscape(_ value: String) -> String {
        "'" + value.replacingOccurrences(
            of: "'",
            with: "'\\''"
        ) + "'"
    }

    // MARK: - Export JSON

    private var exportJSON: String {
        let statusValue: Any =
            log.statusCode.map { $0 as Any } ?? NSNull()

        let requestBodyValue: Any =
            log.requestBody.map { $0 as Any } ?? NSNull()

        let responseBodyValue: Any =
            log.responseBody.map { $0 as Any } ?? NSNull()

        let data: [String: Any] = [
            "url": log.url,
            "method": log.method,
            "statusCode": statusValue,
            "duration": log.duration,
            "requestHeaders": log.requestHeaders,
            "requestBody": requestBodyValue,
            "responseHeaders": log.responseHeaders,
            "responseBody": responseBodyValue
        ]

        guard
            let jsonData = try? JSONSerialization.data(
                withJSONObject: data,
                options: [.prettyPrinted, .sortedKeys]
            ),
            let json = String(
                data: jsonData,
                encoding: .utf8
            )
        else {
            return "{}"
        }

        return json
    }

    private func shareJSON() {
        let activityVC = UIActivityViewController(
            activityItems: [exportJSON],
            applicationActivities: nil
        )

        guard
            let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: {
                    $0.activationState == .foregroundActive
                }),
            let rootVC = scene.windows
                .first(where: \.isKeyWindow)?
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

    // MARK: - URL Title

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
}

// MARK: - Preview

#if DEBUG
struct NetworkDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                NetworkDetailView(
                    log: DebugPreviewData.networkLogs[0]
                )
            }
            .navigationViewStyle(.stack)
            .preferredColorScheme(.light)
            .previewDisplayName("Network Detail - Light")

            NavigationView {
                NetworkDetailView(
                    log: DebugPreviewData.networkLogs[0]
                )
            }
            .navigationViewStyle(.stack)
            .preferredColorScheme(.dark)
            .previewDisplayName("Network Detail - Dark")
        }
    }
}
#endif
