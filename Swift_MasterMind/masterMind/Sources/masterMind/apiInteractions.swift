// Response bodies
import Foundation

// Request & response for /guess

struct CreateGameResponse: Codable {
    let gameId: String
}
struct Main_ErrorResponse: Codable {
    let error: String
}
struct Main_GuessRequest: Codable {
    let game_id: String
    let guess: String
}
struct Main_GuessResponse: Codable {
    let black: Int
    let white: Int
}
