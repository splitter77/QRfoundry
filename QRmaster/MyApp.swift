import SwiftUI

@main
struct MyApp: App {
    @State private var history = QRHistoryStore()
    @State private var subscriptions = SubscriptionManager()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environment(history)
                    .environment(subscriptions)
                    .opacity(showSplash ? 0 : 1)

                ScreenCaptureBlocker()
                    .zIndex(2)

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(3)
                }
            }
            .animation(.easeInOut(duration: 0.45), value: showSplash)
            .task {
                await subscriptions.start()
                try? await Task.sleep(for: .seconds(2.0))
                showSplash = false
            }
        }
    }
}
