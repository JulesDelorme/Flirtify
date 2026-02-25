import SwiftUI

struct RootView: View {
    @ObservedObject var container: AppContainer

    var body: some View {
        Group {
            if container.hasCreatedAccount {
                TabRootView(container: container)
            } else {
                CreateAccountView(initialProfile: container.currentUserProfile()) { payload in
                    container.createAccount(
                        firstName: payload.firstName,
                        ageText: payload.ageText,
                        city: payload.city,
                        bio: payload.bio,
                        interestsText: payload.interestsText,
                        photoSymbol: payload.photoSymbol
                    )
                }
            }
        }
    }
}
