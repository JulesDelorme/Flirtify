import SwiftUI

struct RootView: View {
    let container: AppContainer

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
                        sex: payload.sex,
                        orientation: payload.orientation,
                        interests: payload.interests,
                        photoData: payload.photoData,
                        photoGalleryData: payload.photoGalleryData
                    )
                }
            }
        }
    }
}
