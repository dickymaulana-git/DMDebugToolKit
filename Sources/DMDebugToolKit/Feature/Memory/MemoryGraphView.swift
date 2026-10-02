// MemoryGraphView.swift

import SwiftUI

struct MemoryGraphView: View {

    let snapshots: [MemorySnapshot]

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

                    memoryPath(
                        size: geometry.size
                    )
                }
            }
        }
    }

    private var yAxis: some View {
        let values = snapshots.map(\.usedMB)

        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 1
        let range = max(maxValue - minValue, 1)

        let top = maxValue
        let middle = minValue + range * 0.5
        let bottom = minValue

        return VStack {
            Text(
                String(
                    format: "%.0f",
                    top
                )
            )

            Spacer()

            Text(
                String(
                    format: "%.0f",
                    middle
                )
            )

            Spacer()

            Text(
                String(
                    format: "%.0f",
                    bottom
                )
            )
        }
        .font(.system(size: 9))
        .foregroundStyle(.secondary)
        .frame(width: 34)
    }

    private func memoryPath(
        size: CGSize
    ) -> some View {
        let values = snapshots.map(\.usedMB)

        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 1
        let range = max(maxValue - minValue, 1)

        return Path { path in
            guard !values.isEmpty else {
                return
            }

            for index in values.indices {

                let x =
                    CGFloat(index)
                    / CGFloat(
                        max(values.count - 1, 1)
                    )
                    * size.width

                let normalized =
                    (
                        values[index]
                        - minValue
                    ) / range

                let y =
                    size.height
                    - (
                        normalized
                        * size.height
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

    private func graphGrid(
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        Canvas { context, size in

            for value in [
                0.5
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
struct MemoryGraphView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryGraphView(
            snapshots:
                DebugPreviewData.memorySnapshots
        )
        .frame(height: 180)
        .padding()
    }
}
#endif
