import Foundation

@Observable
final class ProfileInteractor {
    private let profileState: ProfileState

    init(profileState: ProfileState) {
        self.profileState = profileState
    }

    func updatePlayerName(_ name: String) {
        profileState.playerName = name
    }
}
