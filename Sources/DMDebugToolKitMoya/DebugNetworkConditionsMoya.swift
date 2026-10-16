import Foundation
import Moya
import DMDebugToolKit

/// Supplies a request closure that applies the currently selected Network Conditions mode.
/// Pass the returned closure into the MoyaProvider initializer.
public enum DebugNetworkConditionsMoya {

    public static func requestClosure<Target: TargetType>(
        for targetType: Target.Type,
        mapping: MoyaProvider<Target>.RequestClosure? = nil
    ) -> MoyaProvider<Target>.RequestClosure {
        // `Target.Type` makes the generic type inferable at the call site.
        _ = targetType
        let requestMapping = mapping ?? MoyaProvider<Target>.defaultRequestMapping

        return { endpoint, completion in
            let configuration = NetworkConditionsConfiguration.current

            switch configuration.mode {
            case .normal:
                requestMapping(endpoint, completion)

            case .latency:
                let delay = configuration.latencyMilliseconds / 1000
                DispatchQueue.global(qos: .userInitiated).asyncAfter(
                    deadline: .now() + delay
                ) {
                    requestMapping(endpoint, completion)
                }

            case .failure:
                completion(
                    .failure(
                        .underlying(
                            SimulatedNetworkFailure(),
                            nil
                        )
                    )
                )

            case .timeout:
                DispatchQueue.global(qos: .userInitiated).asyncAfter(
                    deadline: .now() + configuration.timeoutSeconds
                ) {
                    completion(
                        .failure(
                            .underlying(
                                URLError(.timedOut),
                                nil
                            )
                        )
                    )
                }
            }
        }
    }
}

private struct SimulatedNetworkFailure: LocalizedError {
    var errorDescription: String? {
        "Network failure simulated by DM Debug Toolkit."
    }
}
