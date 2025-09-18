import DataBase.DataInteractor
import retrofitt.AgentAPI

fun main() {
  while (true) {
    println("\n--- GitHub User Info Menu ---")
    println("1 Get user info by username")
    println("2 Show cached users")
    println("3 Search user in cache")
    println("4 Search repository in cache")
    println("5 Exit")

    when (readlnOrNull()?.toIntOrNull()) {
      1 -> {
        println("Enter GitHub username:")
        val username = readlnOrNull()?.trim()
        if (username.isNullOrEmpty()) {
          println("Invalid username.")
          continue
        }

        AgentAPI.getUserInfo(username) { user ->
          if (user != null) {
            println("\n ${user.login} - Created: ${user.createdAt} - Followers: ${user.followersCount}, Following: ${user.followingCount}")

            AgentAPI.getUserRepositories(username) { repos ->
              repos?.forEach { repo ->
                println(" ${repo.name} -  ${repo.html_url}")
              }
            }
          } else {
            println("User not found.")
          }
        }
      }

      2 -> {
        val users = DataInteractor.getAllUsers()
        if (users.isEmpty()) {
          println("No users in cache.")
        } else {
          users.forEach { user -> println("👤 ${user.login}") }
        }
      }

      3 -> {
        println("Enter username to search:")
        val username = readlnOrNull()?.trim()
        if (username.isNullOrEmpty()) {
          println("Invalid username.")
          continue
        }

        val foundUser = DataInteractor.getAllUsers().find { user -> user.login.equals(username, ignoreCase = true) }
        if (foundUser != null) {
          println("${foundUser.login} - Followers: ${foundUser.followersCount}")
        } else {
          println("User not in cache.")
        }
      }

      4 -> {
        println("Enter repository name:")
        val repoName = readlnOrNull()?.trim()
        if (repoName.isNullOrEmpty()) {
          println("Invalid repository name.")
          continue
        }

        val repos = DataInteractor.getAllUsers().flatMap { user ->
          DataInteractor.getRepos(user.login.lowercase()) ?: emptyList()
        }

        val foundRepo = repos.find { repo -> repo.name == repoName }
        if (foundRepo != null) {
          println("${foundRepo.name} - ${foundRepo.html_url}")
        } else {
          println("Repository not found.")
        }
      }

      5 -> return
      else -> println("Invalid option! Try again.")
    }
  }
}
