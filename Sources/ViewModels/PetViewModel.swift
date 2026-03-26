import Foundation
import Combine

@MainActor
final class PetViewModel: ObservableObject {
    @Published var pet: Pet
    @Published var isAlive: Bool = true
    @Published var showDeathAlert = false

    private var decayTimer: Timer?

    init() {
        self.pet = Self.load() ?? .defaultPet
        startDecay()
        updateMood()
    }

    deinit {
        decayTimer?.invalidate()
    }

    // MARK: - Actions

    func feed() {
        guard isAlive else { return }
        pet.lastFedAt = Date()
        pet.stats.hunger = min(1.0, pet.stats.hunger + 0.4)
        updateMood()
        save()
    }

    func play() {
        guard isAlive else { return }
        pet.lastPlayedAt = Date()
        pet.stats.happiness = min(1.0, pet.stats.happiness + 0.3)
        pet.stats.energy = max(0, pet.stats.energy - 0.15)
        pet.stats.hunger = max(0, pet.stats.hunger - 0.1)
        updateMood()
        save()
    }

    func sleep() {
        guard isAlive else { return }
        pet.lastSleptAt = Date()
        pet.stats.energy = min(1.0, pet.stats.energy + 0.5)
        updateMood()
        save()
    }

    func revive() {
        pet = .defaultPet
        isAlive = true
        showDeathAlert = false
        save()
    }

    // MARK: - State Machine

    private func startDecay() {
        // Decay every 60 seconds
        decayTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.applyDecay()
            }
        }
    }

    private func applyDecay() {
        guard isAlive else { return }

        pet.stats.hunger = max(0, pet.stats.hunger - 0.05)
        pet.stats.happiness = max(0, pet.stats.happiness - 0.03)
        pet.stats.energy = max(0, pet.stats.energy - 0.02)

        updateMood()
        checkDeath()
        save()
    }

    private func updateMood() {
        pet.mood = Pet.Mood.from(
            health: pet.overallHealth,
            hunger: pet.stats.hunger,
            energy: pet.stats.energy
        )
    }

    private func checkDeath() {
        if pet.overallHealth <= 0 {
            isAlive = false
            showDeathAlert = true
        }
    }

    // MARK: - Persistence

    private static let key = "pet_data"

    private func save() {
        if let encoded = try? JSONEncoder().encode(pet) {
            UserDefaults.standard.set(encoded, forKey: Self.key)
        }
    }

    private static func load() -> Pet? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let pet = try? JSONDecoder().decode(Pet.self, from: data) else {
            return nil
        }
        return pet
    }

    // MARK: - Helpers

    var statText: String {
        "饱腹感: \(Int(pet.stats.hunger * 100))% | 快乐: \(Int(pet.stats.happiness * 100))% | 精力: \(Int(pet.stats.energy * 100))%"
    }

    var healthColor: String {
        switch pet.overallHealth {
        case 0.6...: return "#34c759"
        case 0.3..<0.6: return "#ff9500"
        default: return "#ff3b30"
        }
    }
}
