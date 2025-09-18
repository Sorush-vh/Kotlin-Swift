package DataBase

import model.GitHubRepo
import model.GitHubUser

data class UsersData(
  val users: Map<String, GitHubUser>,
  val repos: Map<String, List<GitHubRepo>>
)
