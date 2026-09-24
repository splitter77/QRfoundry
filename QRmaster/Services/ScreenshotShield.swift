import SwiftUI
import UIKit

/// Remettre à `true` après les captures App Store.
enum ScreenProtection {
    static let isEnabled = true
}

/// Surveille l’enregistrement d’écran et affiche un voile (sans casser le layout).
@Observable
final class ScreenCaptureGuard {
    private(set) var isCaptured = UIScreen.main.isCaptured
    private var observer: NSObjectProtocol?

    init() {
        guard ScreenProtection.isEnabled else { return }
        observer = NotificationCenter.default.addObserver(
            forName: UIScreen.capturedDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.isCaptured = UIScreen.main.isCaptured
            }
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

struct ScreenCaptureBlocker: View {
    @State private var guardState = ScreenCaptureGuard()

    var body: some View {
        Group {
            if ScreenProtection.isEnabled, guardState.isCaptured {
                ZStack {
                    Color.black.opacity(0.94).ignoresSafeArea()
                    VStack(spacing: 14) {
                        Image(systemName: "eye.slash.fill")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.28))
                        Text(L10n.t("security.capture.title"))
                            .font(.headline)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        Text(L10n.t("security.capture.subtitle"))
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: guardState.isCaptured)
        .allowsHitTesting(ScreenProtection.isEnabled && guardState.isCaptured)
    }
}

/// Protège uniquement une zone (aperçu QR) : noire dans les captures, sans toucher à la fenêtre.
struct ScreenshotShield<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        if ScreenProtection.isEnabled {
            ScreenshotShieldRepresentable(content: content)
        } else {
            content()
        }
    }
}

private struct ScreenshotShieldRepresentable<Content: View>: UIViewControllerRepresentable {
    @ViewBuilder var content: () -> Content

    func makeUIViewController(context: Context) -> SecureHostingController<Content> {
        SecureHostingController(rootView: content())
    }

    func updateUIViewController(_ controller: SecureHostingController<Content>, context: Context) {
        controller.rootView = content()
    }
}

final class SecureHostingController<Content: View>: UIViewController {
    private var hostingController: UIHostingController<Content>
    private let secureField = UITextField()

    var rootView: Content {
        didSet { hostingController.rootView = rootView }
    }

    init(rootView: Content) {
        self.rootView = rootView
        self.hostingController = UIHostingController(rootView: rootView)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        secureField.isSecureTextEntry = true
        secureField.isUserInteractionEnabled = false
        secureField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(secureField)

        NSLayoutConstraint.activate([
            secureField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            secureField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            secureField.topAnchor.constraint(equalTo: view.topAnchor),
            secureField.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(hostingController)
        guard let rootView = view else { return }
        let container: UIView = secureField.subviews.first ?? rootView
        container.isUserInteractionEnabled = true
        container.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: container.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
}
