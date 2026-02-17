import RealityKit

struct HealthComponent: Component {
    var maxHealth: Int
    var currentHealth: Int

    init(maxHealth: Int) {
        self.maxHealth = maxHealth
        self.currentHealth = maxHealth
    }

    var healthPercent: Float {
        guard maxHealth > 0 else { return 0 }
        return Float(currentHealth) / Float(maxHealth)
    }

    var isDead: Bool { currentHealth <= 0 }
}
