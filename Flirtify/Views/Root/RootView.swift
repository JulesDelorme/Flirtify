import SwiftUI

struct RootView: View {
    @ObservedObject var container: AppContainer

    var body: some View {
        TabRootView(container: container)
    }
}
