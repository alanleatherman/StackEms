import Foundation
import RealityKit

struct WinConditionSystem: System {
    static let query = EntityQuery(where: .has(StackControllerComponent.self))
    static var matchEndedFired = false
    static var combatActive = false

    init(scene: RealityKit.Scene) {
        WinConditionSystem.matchEndedFired = false
        WinConditionSystem.combatActive = false
    }

    func update(context: SceneUpdateContext) {
        guard WinConditionSystem.combatActive else { return }

        var playerAttached = 0
        var opponentAttached = 0
        var playerToppled = false
        var opponentToppled = false

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let controller = entity.components[StackControllerComponent.self] else { continue }

            switch controller.team {
            case .player:
                playerAttached = controller.attachedBlockCount
                playerToppled = controller.hasToppled
            case .opponent:
                opponentAttached = controller.attachedBlockCount
                opponentToppled = controller.hasToppled
            }
        }

        // Post block count updates for HUD
        NotificationCenter.default.post(
            name: .blockCountUpdate,
            object: nil,
            userInfo: [
                "playerBlocks": playerAttached,
                "opponentBlocks": opponentAttached
            ]
        )

        // Check win/loss — only fire once
        if !WinConditionSystem.matchEndedFired && (playerToppled || opponentToppled) {
            WinConditionSystem.matchEndedFired = true
            NotificationCenter.default.post(
                name: .matchEnded,
                object: nil,
                userInfo: ["playerWon": opponentToppled && !playerToppled]
            )
        }
    }
}

extension Notification.Name {
    static let matchEnded = Notification.Name("StackEms.matchEnded")
    static let blockCountUpdate = Notification.Name("StackEms.blockCountUpdate")
}
