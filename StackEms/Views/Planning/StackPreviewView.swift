import SwiftUI
import RealityKit

struct StackPreviewView: View {
    let blueprint: StackBlueprint

    var body: some View {
        RealityView { content in
            let anchor = Entity()
            buildPreviewStack(on: anchor, blueprint: blueprint)
            content.add(anchor)
        } update: { content in
            if let anchor = content.entities.first {
                anchor.children.removeAll()
                buildPreviewStack(on: anchor, blueprint: blueprint)
            }
        }
        .realityViewCameraControls(.orbit)
    }

    private func buildPreviewStack(on parent: Entity, blueprint: StackBlueprint) {
        // Calculate total height first to center the stack at origin
        var totalHeight: Float = 0
        for blockType in blueprint.blocks {
            totalHeight += blockType.size.y + GameConfiguration.Stack.blockSpacing
        }
        if !blueprint.blocks.isEmpty {
            totalHeight -= GameConfiguration.Stack.blockSpacing // no spacing after last block
        }

        var yOffset: Float = -totalHeight / 2

        for (index, blockType) in blueprint.blocks.enumerated() {
            let size = blockType.size
            let mesh = MeshResource.generateBox(
                size: size,
                cornerRadius: 0.03
            )
            var material = SimpleMaterial()
            if let texture = try? TextureResource.load(named: blockType.textureName) {
                material.color = .init(tint: .white, texture: .init(texture))
            } else {
                material.color = .init(tint: blockType.color)
            }
            let entity = ModelEntity(mesh: mesh, materials: [material])

            yOffset += size.y / 2
            entity.position = SIMD3<Float>(0, yOffset, 0)
            yOffset += size.y / 2 + GameConfiguration.Stack.blockSpacing

            entity.name = "preview_block_\(index)"
            parent.addChild(entity)
        }
    }
}
