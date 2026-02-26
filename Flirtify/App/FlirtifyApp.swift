import SwiftUI

@main
struct FlirtifyApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .environment(\.locale, Locale(identifier: "fr_FR"))
        }
    }
}
