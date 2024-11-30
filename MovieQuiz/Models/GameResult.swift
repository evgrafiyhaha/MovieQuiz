import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThen(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
