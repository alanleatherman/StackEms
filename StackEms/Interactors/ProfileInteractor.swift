import Foundation

@Observable
final class ProfileInteractor {
    private let profileState: ProfileState
    private let settingsState: SettingsState
    var onProfileChanged: (() -> Void)?

    init(profileState: ProfileState, settingsState: SettingsState) {
        self.profileState = profileState
        self.settingsState = settingsState
    }

    func updatePlayerName(_ name: String) {
        profileState.playerName = name
        onProfileChanged?()
    }

    func setSoundEnabled(_ enabled: Bool) {
        settingsState.soundEnabled = enabled
        onProfileChanged?()
    }

    func setMusicEnabled(_ enabled: Bool) {
        settingsState.musicEnabled = enabled
        onProfileChanged?()
    }

    func setHapticsEnabled(_ enabled: Bool) {
        settingsState.hapticsEnabled = enabled
        onProfileChanged?()
    }

    func setDifficulty(_ difficulty: DifficultyLevel) {
        settingsState.difficulty = difficulty
        onProfileChanged?()
    }

    func spendCoins(_ amount: Int) -> Bool {
        guard profileState.coins >= amount else { return false }
        profileState.coins -= amount
        onProfileChanged?()
        return true
    }
}
