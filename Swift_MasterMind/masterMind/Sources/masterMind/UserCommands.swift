import Foundation

enum UserCommand: Equatable {
    case exit
    case guess(String)  // 4-digit guess
    case createGame
    case deleteGame  // also used for "abort game"
    case error(String)
}
func parseUserCommand(_ input: String?) -> UserCommand {
    // validate + normalize
    guard var raw = input?.trimmingCharacters(in: .whitespacesAndNewlines),
        !raw.isEmpty
    else { return .error("Empty input") }

    raw = raw.replacingOccurrences(of: "_", with: " ")
        .replacingOccurrences(of: "-", with: " ")
        .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)

    let lower = raw.lowercased()
    if lower == "exit" { return .exit }

    let tokens = raw.split(separator: " ", omittingEmptySubsequences: true)
    guard !tokens.isEmpty else { return .error("Empty input") }

    // guess <4 digits>
    if tokens.first?.lowercased() == "guess" {
        guard tokens.count == 2 else {
            return .error("Usage: guess <4 digits> format not conformed")
        }
        let value = String(tokens[1])
        guard value.range(of: #"^\d{4}$"#, options: .regularExpression) != nil
        else { return .error("Guess must be 4 digits") }
        return .guess(value)
    }

    // create game
    if tokens.count >= 2,
        tokens[0].lowercased() == "create",
        tokens[1].lowercased() == "game"
    {
        return .createGame
    }

    // delete game  (alias: abort game)
    if tokens.count >= 2,
        tokens[0].lowercased() == "delete" || tokens[0].lowercased() == "abort",
        tokens[1].lowercased() == "game"
    {
        return .deleteGame
    }

    return .error("Unknown command")
}
