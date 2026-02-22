import RealityKit
import UIKit

struct StackFactory {
    static func buildStack(
        from blueprint: StackBlueprint,
        teamName: String,
        position: SIMD3<Float>,
        withPhysics: Bool = false,
        statsLookup: ((BlockType) -> ResolvedBlockStats)? = nil
    ) -> Entity {
        let stackRoot = Entity()
        stackRoot.name = "stack_\(teamName)"
        stackRoot.position = position

        var memberNames: [String] = []
        var yOffset: Float = GameConfiguration.Stack.baseYOffset

        for (index, blockType) in blueprint.blocks.enumerated() {
            let resolved = statsLookup?(blockType)
            let block = buildBlock(
                type: blockType,
                index: index,
                teamName: teamName,
                withPhysics: withPhysics,
                resolvedStats: resolved
            )

            let size = blockType.size
            yOffset += size.y / 2
            block.position = SIMD3<Float>(0, yOffset, 0)
            yOffset += size.y / 2 + GameConfiguration.Stack.blockSpacing

            memberNames.append(block.name)
            stackRoot.addChild(block)
        }

        if withPhysics {
            let team: StackControllerComponent.Team = teamName == "player" ? .player : .opponent

            // Compute movement speed from average speed factor
            let avgSpeedFactor: Float
            if let lookup = statsLookup {
                let factors = blueprint.blocks.map { lookup($0).speedFactor }
                avgSpeedFactor = factors.isEmpty ? 1.0 : factors.reduce(0, +) / Float(factors.count)
            } else {
                avgSpeedFactor = 1.0
            }
            let computedSpeed = GameConfiguration.Movement.forwardSpeed * avgSpeedFactor

            stackRoot.components.set(StackControllerComponent(
                memberEntityNames: memberNames,
                attachedBlockCount: memberNames.count,
                movementSpeed: computedSpeed,
                team: team
            ))

            if team == .opponent {
                stackRoot.components.set(AIControlledComponent())
            }
        }

        return stackRoot
    }

    private static func buildBlock(
        type: BlockType,
        index: Int,
        teamName: String,
        withPhysics: Bool,
        resolvedStats: ResolvedBlockStats? = nil
    ) -> ModelEntity {
        let size = type.size
        let mesh = MeshResource.generateBox(size: size, cornerRadius: 0.03)

        // Try to load face texture, fall back to solid color
        var material = SimpleMaterial()
        if let texture = try? TextureResource.load(named: type.textureName) {
            material.color = .init(tint: .white, texture: .init(texture))
        } else {
            material.color = .init(tint: type.color)
        }
        material.roughness = .float(0.6)
        material.metallic = .float(0.1)

        let block = ModelEntity(mesh: mesh, materials: [material])
        block.name = "\(teamName)_block_\(index)"

        if withPhysics {
            let shape = ShapeResource.generateBox(size: size)
            let mass = resolvedStats?.effectiveMass ?? type.mass
            let restitution = resolvedStats?.restitution ?? GameConfiguration.Physics.blockRestitution

            block.components.set(CollisionComponent(
                shapes: [shape],
                filter: .default
            ))
            block.components.set(PhysicsBodyComponent(
                shapes: [shape],
                mass: mass,
                material: .generate(
                    staticFriction: GameConfiguration.Physics.blockFriction,
                    dynamicFriction: GameConfiguration.Physics.blockFriction * 0.8,
                    restitution: restitution
                ),
                mode: .dynamic
            ))

            let team: TeamComponent.Team = teamName == "player" ? .player : .opponent
            block.components.set(StackMemberComponent(
                stackID: teamName,
                index: index,
                blockType: type
            ))
            block.components.set(HealthComponent(maxHealth: type.health))
            block.components.set(TeamComponent(team: team))
            block.components.set(SwipeableComponent(
                forceMultiplier: GameConfiguration.Physics.swipeForceMultiplier
            ))
            block.components.set(InputTargetComponent())
        }

        return block
    }
}
