import UIKit

final class DebugFloatingButton: UIButton {

    private let backgroundView = UIView()
    private let iconView = UIImageView()
    private let environmentLabel = UILabel()

    init(
        image: UIImage?,
        environment: DebugToolkitEnvironment
    ) {
        super.init(frame: .zero)

        setup(
            image: image,
            environment: environment
        )
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup(
            image: nil,
            environment: .dev
        )
    }

    private func setup(
        image: UIImage?,
        environment: DebugToolkitEnvironment
    ) {
        backgroundColor = .clear
        clipsToBounds = false

        // MARK: - AssistiveTouch Background

        backgroundView.backgroundColor =
            UIColor.black.withAlphaComponent(0.1)

        backgroundView.layer.cornerRadius = 26

        backgroundView.layer.borderWidth = 1

        backgroundView.layer.borderColor =
            UIColor.black.withAlphaComponent(0.1).cgColor

        backgroundView.isUserInteractionEnabled = false

        addSubview(backgroundView)

        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            backgroundView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            backgroundView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            backgroundView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            )
        ])

        // MARK: - Logo

        iconView.image = image
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
        iconView.alpha = 0.92
        iconView.isUserInteractionEnabled = false

        addSubview(iconView)

        iconView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 3
            ),
            iconView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 3
            ),
            iconView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -3
            ),
            iconView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -3
            )
        ])

        iconView.layer.cornerRadius = 23

        // MARK: - Environment

        environmentLabel.text =
            environment.displayName

        environmentLabel.font =
            .systemFont(
                ofSize: 18,
                weight: .heavy
            )

        environmentLabel.textColor = .yellow
        environmentLabel.textAlignment = .center
        environmentLabel.isUserInteractionEnabled = false

        // Text langsung menimpa logo.
        environmentLabel.layer.shadowColor =
            UIColor.black.cgColor

        environmentLabel.layer.shadowOpacity = 0.9
        environmentLabel.layer.shadowRadius = 2
        environmentLabel.layer.shadowOffset = CGSize(
            width: 0,
            height: 1
        )

        addSubview(environmentLabel)

        environmentLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            environmentLabel.centerXAnchor.constraint(
                equalTo: centerXAnchor
            ),
            environmentLabel.centerYAnchor.constraint(
                equalTo: centerYAnchor
            )
        ])

        // MARK: - Shadow

        layer.shadowColor =
            UIColor.black.cgColor

        layer.shadowOpacity = 0.28
        layer.shadowRadius = 7

        layer.shadowOffset = CGSize(
            width: 0,
            height: 3
        )

        // Jangan kasih background opaque.
        // Background berasal dari backgroundView.
        layer.cornerRadius = 26
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(
                withDuration: 0.12
            ) {
                self.alpha =
                    self.isHighlighted
                    ? 0.65
                    : 1.0

                self.transform =
                    self.isHighlighted
                    ? CGAffineTransform(
                        scaleX: 0.94,
                        y: 0.94
                    )
                    : .identity
            }
        }
    }
}

#if DEBUG
import SwiftUI

private struct DebugFloatingButtonPreview: UIViewRepresentable {

    let environment: DebugToolkitEnvironment

    func makeUIView(context: Context) -> DebugFloatingButton {
        DebugFloatingButton(
            image: UIImage(
                named: "tring",
                in: Bundle.module,
                compatibleWith: nil
            ),
            environment: environment
        )
    }

    func updateUIView(
        _ uiView: DebugFloatingButton,
        context: Context
    ) {
    }
}

struct DebugFloatingButton_Previews: PreviewProvider {

    static var previews: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Demo")
                        .font(.system(size: 34, weight: .bold))

                    Spacer()
                }

                Spacer()
            }
            .padding()

            VStack {
                Spacer()

                HStack {
                    Spacer()

                    DebugFloatingButtonPreview(
                        environment: .dev
                    )
                    .frame(
                        width: 52,
                        height: 52
                    )
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .previewDisplayName("Floating Button - DEV")
    }
}
#endif
