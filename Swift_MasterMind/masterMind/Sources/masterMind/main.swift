import Dispatch
import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking  // needed on Windows/Linux
#endif

// Shared clients
let session = URLSession.shared
let decoder: JSONDecoder = {
    let d = JSONDecoder()
    // tolerate snake_case or camelCase coming back from the server
    d.keyDecodingStrategy = .convertFromSnakeCase
    return d
}()
let encoder = JSONEncoder()  // your request types already use snake_case keys

// MARK: - API functions

func createGame() async throws -> CreateGameResponse {
    let url = URL(string: "https://mastermind.darkube.app/game")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    let (data, response) = try await session.data(for: request)
    try ensureOK(data, response)
    return try decoder.decode(CreateGameResponse.self, from: data)
}

func deleteGame(game_id: String) async throws {
    // DELETE /game/<id>
    let url = URL(string: "https://mastermind.darkube.app/game/\(game_id)")!
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    let (data, response) = try await session.data(for: request)
    try ensureOK(data, response)
}

func makeGuess(guess: Main_GuessRequest) async throws -> Main_GuessResponse {
    let url = URL(string: "https://mastermind.darkube.app/guess")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = try encoder.encode(guess)

    let (data, response) = try await session.data(for: request)
    try ensureOK(data, response)
    return try decoder.decode(Main_GuessResponse.self, from: data)
}

// Decode server error { "error": "..." } and throw user-friendly messages
func ensureOK(_ data: Data, _ response: URLResponse) throws {
    guard let http = response as? HTTPURLResponse else { return }
    guard (200...299).contains(http.statusCode) else {
        if let server = try? decoder.decode(Main_ErrorResponse.self, from: data) {
            throw NSError(
                domain: "HTTPError",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: server.error])
        }
        if let text = String(data: data, encoding: .utf8), !text.isEmpty {
            throw NSError(
                domain: "HTTPError",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Status \(http.statusCode): \(text)"])
        }
        throw NSError(
            domain: "HTTPError",
            code: http.statusCode,
            userInfo: [NSLocalizedDescriptionKey: "Status \(http.statusCode)"])
    }
}

// MARK: - Command handlers

/// Returns the new/current running game id
func handleCreateGameRequest(currentId: String?) async -> String? {
    // if a game is already running, do not create a new one
    if let id = currentId {
        print("Error creating game: a game is already running (id: \(id))")
        return id
    }
    do {
        let res = try await createGame()
        print("Created game: \(res.gameId)")
        return res.gameId
    } catch {
        print("Error creating game:", error.localizedDescription)
        return nil
    }
}

func handleGuessRequest(currentId: String?, guess: String) async -> Bool {
    guard let id = currentId else {
        print("Error guessing: no game is currently running!")
        return false
    }
    do {
        let req = Main_GuessRequest(game_id: id, guess: guess)
        let res = try await makeGuess(guess: req)

        // build UI result using your B/W scheme
        let B_str = String(repeating: "B", count: res.black)
        let W_str = String(repeating: "W", count: res.white)
        let result_string_append = (res.black == 4) ? "Correct guess!" : (B_str + W_str)

        print("Result for your guess on game \(id): \(result_string_append)")
        return res.black == 4
    } catch {
        print("Error making guess:", error.localizedDescription)
        return false
    }
}

func handleAbortGame(currentId: String?) async -> String? {
    guard let id = currentId else {
        print("Error aborting: no game is currently running!")
        return nil
    }
    do {
        try await deleteGame(game_id: id)
        print("Aborted game \(id)")
        return nil  // reset current game id
    } catch {
        print("Error aborting game:", error.localizedDescription)
        return id  // keep it if abort failed
    }
}

// MARK: - UI (your original texts)

func show_guidelines() {
    print("Welcome to the Master Mind Game!")
    print("below is a guideline, so you can use the program easily:")
    print("--GAME RULES: ")
    print("In this game, the api chooses a 4 digit number for you, and you will try to guess it!")
    print("The result of each guess comes in the format of some Ws printed, and some Bs.")
    print("The sequence of Ws represent the Number of correct digits, but in a wrong place.")
    print("The sequence of Bs represent the Number of correct digits, in the correct place.")

    print("\n--COMMANDS: ")
    print("-> you can exit the app at any time with the command: \"exit\".")
    print("-> you can create a new game with the command: \"create game\".")
    print(
        "-> you can send your guess to the api with the command: \"guess <some 4-digit number>\".")
    print(
        "-> you can abort the running game with the command: \"delete game\", so you can play a new game."
    )
    print("Have Fun!")
}

// MARK: - Async entry point (same shape as yours)

func main() async {
    var runningGameId: String? = nil

    show_guidelines()

    while true {
        guard let line = readLine() else { break }
        let command = parseUserCommand(line)

        switch command {
        case .exit:
            print("Exiting the program..")
            if runningGameId != nil {  // abort on exit (best effort)
                print("Aborting the running game..")
                runningGameId = await handleAbortGame(currentId: runningGameId)
            }
            return

        case .createGame:
            print("Creating a new game..")
            runningGameId = await handleCreateGameRequest(currentId: runningGameId)

        case .guess(let value):
            print("Handling your guess..")
            if await handleGuessRequest(currentId: runningGameId, guess: value) {
                runningGameId = await handleAbortGame(currentId: runningGameId)
            }

        case .deleteGame:
            print("Trying to abort the running game..")
            runningGameId = await handleAbortGame(currentId: runningGameId)

        case .error(let message):
            print("Error:", message)
        }
    }
}

await main()

// // ---- Run the async main without @main or top-level `await` ----
// private func runAsyncAndBlock(_ operation: @escaping () async -> Void) {
//     let g = DispatchGroup()
//     g.enter()
//     Task {
//         await operation()
//         g.leave()
//     }
//     g.wait()
// }

// runAsyncAndBlock { await main() }
