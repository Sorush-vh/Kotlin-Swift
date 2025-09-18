package DataBase

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import model.GitHubRepo
import model.GitHubUser
import java.io.File

object DataInteractor {
  private val gson = Gson()
  private const val CACHE_FILE = "cache.json"
  private val userCache= mutableMapOf<String, GitHubUser>()
  private val repoCache= mutableMapOf<String, List<GitHubRepo>>()


  init {
    loadCache()
    Runtime.getRuntime().addShutdownHook(Thread {
      saveCache()
    })
  }

  fun getUser(username: String): GitHubUser? = userCache[username.lowercase()]
  fun getRepos(username: String): List<GitHubRepo>? = repoCache[username.lowercase()]

  fun storeUserToCache(username: String, user: GitHubUser){
    userCache[username.lowercase()]=user
  }
  fun storeUserRepos(username: String, repos: List<GitHubRepo>){
    repoCache[username.lowercase()]=repos
  }

  fun getAllUsers(): List<GitHubUser> = userCache.values.toList()

  private fun loadCache() {
    val file = File(CACHE_FILE)
    if (!file.exists()) return

    val type = object : TypeToken<UsersData>() {}.type
    val cacheData: UsersData = gson.fromJson(file.readText(), type)

    userCache.putAll(cacheData.users)
    repoCache.putAll(cacheData.repos)
  }

  private fun saveCache(){
    val cacheData= UsersData(userCache, repoCache)
    File(CACHE_FILE).writeText(gson.toJson(cacheData))
  }
}
