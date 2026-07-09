import SwiftUI

enum Level: Int, CaseIterable {
    case l1, l2, l3, l4

    /// Number of cards on the grid at this level.
    var cardCount: Int {
        switch self {
        case .l1: return 2
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }

    /// Number of columns used to lay out the grid.
    /// L2 (2×2), L3 (2×3), L4 (3×3) are true grids, not a single row.
    var columns: Int {
        switch self {
        case .l1: return 2
        case .l2: return 2
        case .l3: return 3
        case .l4: return 3
        }
    }

    /// How long a card stays lit before going dark again.
    var litWindow: Double {
        switch self {
        case .l1: return 1.5
        case .l2: return 1.2
        case .l3: return 1.0
        case .l4: return 0.8
        }
    }

    /// How many cards light up at once (L4 lights two at a time).
    var simultaneousLitCount: Int {
        self == .l4 ? 2 : 1
    }

    var label: String {
        switch self {
        case .l1: return "L1"
        case .l2: return "L2"
        case .l3: return "L3"
        case .l4: return "L4"
        }
    }

    /// Distinct glow colour per level — used for lit-card fill
    /// and the level-up flash overlay.
    var glowColor: Color {
        switch self {
        case .l1: return .green
        case .l2: return .blue
        case .l3: return .orange
        case .l4: return .red
        }
    }

    /// Works out which level a round should be at, given seconds elapsed
    /// since the round started and the total round length. Using a
    /// percentage of the round (rather than fixed second thresholds) means
    /// this keeps working correctly for 30s/60s/90s rounds from Settings.
    static func forElapsed(_ elapsed: Int, roundLength: Int) -> Level {
        guard roundLength > 0 else { return .l1 }
        let progress = Double(elapsed) / Double(roundLength)
        switch progress {
        case ..<0.25: return .l1
        case ..<0.5: return .l2
        case ..<0.75: return .l3
        default: return .l4
        }
    }
}

struct Card: Identifiable {
    let id: Int
    var isLit: Bool = false
}
