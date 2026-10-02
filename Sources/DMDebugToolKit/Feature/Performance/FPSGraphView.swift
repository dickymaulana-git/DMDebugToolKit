// FPSGraphView.swift

import SwiftUI

struct FPSGraphView: View {

    let snapshots: [PerformanceSnapshot]

    private let maxFPS: Double = 60

    var body: some View {
        HStack(
            alignment: .top,
            spacing: 6
        ) {

            yAxis

            GeometryReader { geometry in
                ZStack {

                    graphGrid(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )

                    Path { path in
                        let values = snapshots.map(\.fps)

                        guard !values.isEmpty else {
                            return
                        }

                        for index in values.indices {

                            let x =
                                CGFloat(index)
                                / CGFloat(
                                    max(values.count - 1, 1)
                                )
                                * geometry.size.width

                            let normalized =
                                min(
                                    max(values[index], 0),
                                    maxFPS
                                ) / maxFPS

                            let y =
                                geometry.size.height
                                - (
                                    normalized
                                    * geometry.size.height
                                )

                            let point = CGPoint(
                                x: x,
                                y: y
                            )

                            if index == values.startIndex {
                                path.move(to: point)
                            } else {
                                path.addLine(to: point)
                            }
                        }
                    }
                    .stroke(
                        DebugUIStyle.graph,
                        lineWidth: 1.5
                    )
                }
            }
        }
    }

    private var yAxis: some View {
        VStack {
            Text("60")
            Spacer()
            Text("45")
            Spacer()
            Text("30")
            Spacer()
            Text("15")
            Spacer()
            Text("0")
        }
        .font(.system(size: 9))
        .foregroundStyle(.secondary)
        .frame(width: 18)
    }

    private func graphGrid(
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        Canvas { context, size in

            for value in [
                0.25,
                0.5,
                0.75
            ] {

                let y =
                    size.height
                    * (1 - value)

                var path = Path()

                path.move(
                    to: CGPoint(
                        x: 0,
                        y: y
                    )
                )

                path.addLine(
                    to: CGPoint(
                        x: size.width,
                        y: y
                    )
                )

                context.stroke(
                    path,
                    with: .color(
                        .secondary.opacity(0.12)
                    ),
                    lineWidth: 0.5
                )
            }
        }
    }
}

#if DEBUG
struct FPSGraphView_Previews: PreviewProvider {
    static var previews: some View {
        FPSGraphView(
            snapshots:
                DebugPreviewData.performanceSnapshots
        )
        .frame(height: 180)
        .padding()
    }
}
#endif
