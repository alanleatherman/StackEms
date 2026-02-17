import SwiftUI
import UIKit
import RealityKit

enum BlockType: String, CaseIterable, Identifiable, Codable, Sendable {
    case capyblocka
    case tortodome
    case jellypop
    case cubeuin
    case triacera

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .capyblocka: "Capy-Blocka"
        case .tortodome: "Torto-Dome"
        case .jellypop: "Jelly-Pop"
        case .cubeuin: "Cube-uin"
        case .triacera: "Tria-Cera"
        }
    }

    var shortName: String {
        switch self {
        case .capyblocka: "Capy"
        case .tortodome: "Torto"
        case .jellypop: "Jelly"
        case .cubeuin: "Cube"
        case .triacera: "Tria"
        }
    }

    var subtitle: String {
        switch self {
        case .capyblocka: "Heavy Base"
        case .tortodome: "Stable"
        case .jellypop: "Bouncy"
        case .cubeuin: "Slippery"
        case .triacera: "Disrupter"
        }
    }

    var textureName: String {
        rawValue
    }

    var mass: Float {
        switch self {
        case .capyblocka: 4.0
        case .tortodome: 2.5
        case .jellypop: 1.5
        case .cubeuin: 1.0
        case .triacera: 2.0
        }
    }

    var health: Int {
        switch self {
        case .capyblocka: 150
        case .tortodome: 120
        case .jellypop: 80
        case .cubeuin: 60
        case .triacera: 100
        }
    }

    var size: SIMD3<Float> {
        switch self {
        case .capyblocka: [0.45, 0.45, 0.45]
        case .tortodome: [0.6, 0.3, 0.6]
        case .jellypop: [0.35, 0.35, 0.35]
        case .cubeuin: [0.35, 0.35, 0.35]
        case .triacera: [0.3, 0.6, 0.3]
        }
    }

    var color: UIColor {
        switch self {
        case .capyblocka: UIColor(red: 0.87, green: 0.76, blue: 0.63, alpha: 1)
        case .tortodome: UIColor(red: 0.55, green: 0.78, blue: 0.25, alpha: 1)
        case .jellypop: UIColor(red: 0.96, green: 0.65, blue: 0.76, alpha: 1)
        case .cubeuin: UIColor(red: 0.68, green: 0.85, blue: 0.95, alpha: 1)
        case .triacera: UIColor(red: 0.56, green: 0.35, blue: 0.70, alpha: 1)
        }
    }
}
