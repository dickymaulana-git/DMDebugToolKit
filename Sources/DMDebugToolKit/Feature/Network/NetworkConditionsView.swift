import SwiftUI

struct NetworkConditionsView: View {

    var onBack: () -> Void = {}

    @AppStorage(NetworkConditionsConfiguration.modeKey)
    private var modeRawValue = NetworkConditionMode.normal.rawValue

    @AppStorage(NetworkConditionsConfiguration.latencyMillisecondsKey)
    private var latencyMilliseconds = 1500.0

    @AppStorage(NetworkConditionsConfiguration.timeoutSecondsKey)
    private var timeoutSeconds = 10.0

    private var selectedMode: NetworkConditionMode {
        NetworkConditionMode(rawValue: modeRawValue) ?? .normal
    }
    
    init(
        onBack: @escaping () -> Void = {}
    ) {
        self.onBack = onBack
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationHeader
            Divider()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    activeStateCard

                    sectionTitle("Simulation Mode")

                    VStack(spacing: 8) {
                        ForEach(NetworkConditionMode.allCases) { mode in
                            modeRow(mode)
                        }
                    }

                    if selectedMode == .latency {
                        latencySettings
                    }

                    if selectedMode == .timeout {
                        timeoutSettings
                    }

                    Text("Conditions apply only to Moya providers configured with DebugNetworkConditionsMoya.requestClosure(). Other networking clients are not affected.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Header

    private var navigationHeader: some View {
        HStack {
            DebugBackButton(action: onBack)
                .buttonStyle(.plain)
                .accessibilityLabel("Back to Debug Toolkit")

            Spacer()

            Button(action: resetSettings) {
                Text("Reset")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DebugUIStyle.accent)
                    .padding(.horizontal, 13)
                    .frame(height: 38)
                    .background(DebugUIStyle.accent.opacity(0.10))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .overlay {
            Text("Network Conditions")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .allowsHitTesting(false)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Active State

    private var activeStateCard: some View {
        HStack(spacing: 12) {
            Image(systemName: selectedMode.systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(selectedMode == .normal ? DebugUIStyle.success : DebugUIStyle.warning)
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(
                        (selectedMode == .normal ? DebugUIStyle.success : DebugUIStyle.warning)
                            .opacity(0.12)
                    )
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(selectedMode == .normal ? "Simulation Disabled" : "Simulation Active")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(statusDescription)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            Text(selectedMode == .normal ? "OFF" : "ON")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(selectedMode == .normal ? DebugUIStyle.success : DebugUIStyle.warning)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(
                    (selectedMode == .normal ? DebugUIStyle.success : DebugUIStyle.warning)
                        .opacity(0.12)
                )
                .clipShape(Capsule())
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }

    private var statusDescription: String {
        switch selectedMode {
        case .normal:
            return "Requests use the normal request mapping."
        case .latency:
            return "Adds \(String(format: "%.2f", latencyMilliseconds / 1000)) seconds before each request."
        case .failure:
            return "Requests fail locally and are not sent to the server."
        case .timeout:
            return "Returns a timeout error after \(Int(timeoutSeconds)) seconds."
        }
    }

    // MARK: - Mode Rows

    private func modeRow(_ mode: NetworkConditionMode) -> some View {
        let isSelected = selectedMode == mode
        let tint = modeColor(mode)

        return HStack(spacing: 12) {
            Image(systemName: mode.systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(Circle().fill(tint.opacity(0.12)))

            VStack(alignment: .leading, spacing: 4) {
                Text(mode.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(mode.subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                .font(.system(size: 18))
                .foregroundStyle(isSelected ? DebugUIStyle.accent : Color.secondary.opacity(0.6))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isSelected ? DebugUIStyle.accent.opacity(0.55) : Color.clear,
                    lineWidth: 1
                )
        }
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            modeRawValue = mode.rawValue
        }
    }

    // MARK: - Latency Settings

    private var latencySettings: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionTitle("Artificial Latency")
                Spacer()
                Text(String(format: "%.2f s", latencyMilliseconds / 1000))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(DebugUIStyle.accent)
            }

            Slider(value: $latencyMilliseconds, in: 250...5000, step: 250)
                .tint(DebugUIStyle.accent)

            HStack {
                Text("250 ms")
                Spacer()
                Text("5 sec")
            }
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }

    // MARK: - Timeout Settings

    private var timeoutSettings: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionTitle("Timeout Delay")
                Spacer()
                Text("\(Int(timeoutSeconds)) sec")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(DebugUIStyle.critical)
            }

            Slider(value: $timeoutSeconds, in: 1...30, step: 1)
                .tint(DebugUIStyle.critical)

            HStack {
                Text("1 sec")
                Spacer()
                Text("30 sec")
            }
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }

    // MARK: - Helpers

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(DebugUIStyle.sectionTitle)
            .foregroundStyle(.secondary)
            .padding(.leading, 2)
    }

    private func modeColor(_ mode: NetworkConditionMode) -> Color {
        switch mode {
        case .normal: return DebugUIStyle.success
        case .latency: return DebugUIStyle.info
        case .failure: return DebugUIStyle.critical
        case .timeout: return DebugUIStyle.warning
        }
    }

    private func resetSettings() {
        modeRawValue = NetworkConditionMode.normal.rawValue
        latencyMilliseconds = 1500
        timeoutSeconds = 10
    }
}

#if DEBUG
struct NetworkConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NetworkConditionsView(onBack: {})
                .preferredColorScheme(.light)
                .previewDisplayName("Network Conditions - Light")

            NetworkConditionsView(onBack: {})
                .preferredColorScheme(.dark)
                .previewDisplayName("Network Conditions - Dark")
        }
    }
}
#endif
