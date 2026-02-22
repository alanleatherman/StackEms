import SwiftUI
import RealityKit

struct CombatView: View {
    @Environment(\.appContainer) private var container
    @State private var joystickInput: SIMD2<Float> = .zero

    var body: some View {
        ZStack {
            RealityView { content in
                let arena = ArenaBuilder.buildArena()
                content.add(arena)

                let profileState = container.appState.profileState
                let playerStatsLookup: (BlockType) -> ResolvedBlockStats = { blockType in
                    let upgrades = profileState.upgradeLevel(for: blockType)
                    return BlockStatsConfig.resolve(blockType: blockType, upgrades: upgrades)
                }

                let playerStack = StackFactory.buildStack(
                    from: container.appState.matchState.playerBlueprint,
                    teamName: "player",
                    position: [0, 0, GameConfiguration.Arena.playerStartZ],
                    withPhysics: true,
                    statsLookup: playerStatsLookup
                )
                content.add(playerStack)

                let opponentStack = StackFactory.buildStack(
                    from: container.appState.matchState.opponentBlueprint,
                    teamName: "opponent",
                    position: [0, 0, GameConfiguration.Arena.opponentStartZ],
                    withPhysics: true
                )
                content.add(opponentStack)
            } update: { content in
                for entity in content.entities {
                    updatePlayerInput(entity: entity)
                }
            }
            .gesture(
                DragGesture()
                    .targetedToAnyEntity()
                    .onEnded { value in
                        guard container.appState.matchState.phase == .combat else { return }
                        let entity = value.entity
                        guard entity.components.has(SwipeableComponent.self) else { return }

                        let translation = value.translation
                        let impulse = SIMD3<Float>(
                            Float(translation.width) * GameConfiguration.Physics.swipeForceMultiplier * 0.01,
                            0,
                            Float(translation.height) * GameConfiguration.Physics.swipeForceMultiplier * 0.01
                        )

                        var swipeable = entity.components[SwipeableComponent.self]!
                        swipeable.pendingImpulse = impulse
                        entity.components.set(swipeable)
                    }
            )
            .ignoresSafeArea()

            // Touch-anywhere joystick overlay (below HUD so buttons work)
            if container.appState.matchState.phase == .combat {
                TouchJoystickOverlay(input: $joystickInput)
            }

            // HUD overlay (on top so buttons are tappable)
            VStack {
                CombatHUDView()

                Spacer()
            }

            if container.appState.matchState.phase == .countdown {
                countdownOverlay
            }
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .onAppear {
            container.matchCoordinator.startCountdown()
        }
        .onDisappear {
            container.matchCoordinator.stopTimers()
        }
    }

    private func updatePlayerInput(entity: Entity) {
        if var controller = entity.components[StackControllerComponent.self],
           controller.team == .player {
            controller.movementInput = joystickInput
            entity.components.set(controller)
        }
        for child in entity.children {
            updatePlayerInput(entity: child)
        }
    }

    private var countdownOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            if let text = container.matchCoordinator.countdownText {
                Text(text)
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(radius: 10)
            }
        }
    }
}

// MARK: - Touch Joystick Overlay

struct TouchJoystickOverlay: View {
    @Binding var input: SIMD2<Float>
    @State private var touchOrigin: CGPoint?
    @State private var currentOffset: CGSize = .zero

    private let maxRadius: CGFloat = 60

    var body: some View {
        GeometryReader { _ in
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if touchOrigin == nil {
                                touchOrigin = value.startLocation
                            }

                            guard let origin = touchOrigin else { return }

                            let dx = value.location.x - origin.x
                            let dy = value.location.y - origin.y
                            let distance = sqrt(dx * dx + dy * dy)

                            if distance <= maxRadius {
                                currentOffset = CGSize(width: dx, height: dy)
                            } else {
                                let scale = maxRadius / distance
                                currentOffset = CGSize(width: dx * scale, height: dy * scale)
                            }

                            let normalizedX = Float(currentOffset.width / maxRadius)
                            let normalizedY = Float(-currentOffset.height / maxRadius)
                            input = SIMD2<Float>(normalizedX, normalizedY)
                        }
                        .onEnded { _ in
                            touchOrigin = nil
                            currentOffset = .zero
                            input = .zero
                        }
                )
                .overlay {
                    if let origin = touchOrigin {
                        joystickVisual
                            .position(origin)
                    }
                }
        }
        .allowsHitTesting(true)
    }

    private var joystickVisual: some View {
        ZStack {
            // Base
            Circle()
                .fill(Color.white.opacity(0.1))
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: maxRadius * 2, height: maxRadius * 2)

            // Thumb
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 40, height: 40)
                .offset(currentOffset)
        }
    }
}
