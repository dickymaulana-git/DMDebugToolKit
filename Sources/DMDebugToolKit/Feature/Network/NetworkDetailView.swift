import SwiftUI
import UIKit

struct NetworkDetailView: View {

    let log: NetworkLog

    @Environment(\.presentationMode)
    private var presentationMode

    @State private var copiedItem: String?

    var body: some View {
        VStack(spacing: 0) {

            navigationHeader

            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: 22
                ) {

                    // MARK: - INFO

                    sectionContainer(
                        title: "INFO",
                        color: DebugUIStyle.accent
                    ) {
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
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
        }
        .background(
            Color(.systemBackground)
        )
        .navigationBarHidden(true)
    }

    // MARK: - Navigation Header

    private var navigationHeader: some View {

        HStack {

            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {

                HStack(spacing: 5) {

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

            Text(urlTitle)
                .font(
                    .system(
                        size: 17,
                        weight: .semibold
                    )
                )

            Spacer()

            Button {
                copyAll()
            } label: {

                Text(
                    copiedItem == "all"
                    ? "Copied"
                    : "Copy All"
                )
                .font(
                    .system(
                        size: 15,
                        weight: .regular
                    )
                )
                .foregroundStyle(
                    DebugUIStyle.accent
                )
            }
            .frame(minWidth: 62, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(
            Color(.systemBackground)
        )
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

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            HStack(spacing: 8) {

                Circle()
                    .fill(color)
                    .frame(
                        width: 8,
                        height: 8
                    )

                Text(title)
                    .font(
                        .system(
                            size: 14,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(color)

                Rectangle()
                    .fill(
                        color.opacity(0.18)
                    )
                    .frame(height: 1)
            }

            VStack(
                alignment: .leading,
                spacing: 12
            ) {
                content()
            }
        }
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

        VStack(
            alignment: .leading,
            spacing: 4
        ) {

            HStack(alignment: .top) {

                Text("[\(title)]")
                    .font(
                        .system(
                            size: 12,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.secondary)

                Spacer()

                copyButton(
                    value: value.isEmpty ? "-" : value,
                    id: copyID
                )
            }

            Text(value)
                .font(DebugUIStyle.body)
                .foregroundStyle(.primary)
                .textSelection(.enabled)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
        .padding(12)
        .background(
            RoundedRectangle(
                cornerRadius: DebugUIStyle.cardRadius
            )
            .fill(
                DebugUIStyle.cardBackground
            )
        )
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

        VStack(
            alignment: .leading,
            spacing: 3
        ) {

            HStack(alignment: .top) {

                Text("[\(title)]")
                    .font(DebugUIStyle.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                copyButton(
                    value: value,
                    id: copyID
                )
            }

            Text(
                value.isEmpty
                ? "-"
                : value
            )
            .font(DebugUIStyle.body)
            .foregroundStyle(.primary)
            .textSelection(.enabled)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            DebugUIStyle.rowBackground(
                index: index
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
                    .font(
                        .system(
                            size: 11,
                            design: .monospaced
                        )
                    )
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
