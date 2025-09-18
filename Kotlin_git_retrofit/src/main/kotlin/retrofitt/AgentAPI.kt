package retrofitt

import DataBase.DataInteractor
import model.GitHubRepo
import model.GitHubUser
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

object AgentAPI {
  private val api = RetrofitClient.instance

  fun getUserInfo(username: String, callback: (GitHubUser?) -> Unit) {
    val cachedUser = DataInteractor.getUser(username)  //search cache data first
    if (cachedUser != null) { //if already found, we are done
      println("user already found at local data")
      callback(cachedUser)
      return
    }
    //if not found in cache:
    api.getUserInfo(username).enqueue(object : Callback<GitHubUser> {
      override fun onResponse(call: Call<GitHubUser>, response: Response<GitHubUser>) {
        if (response.isSuccessful) {
          response.body()?.let {
            DataInteractor.storeUserToCache(username, it)
            callback(it)
          }
        } else {
          callback(null)
        }
      }

      override fun onFailure(call: Call<GitHubUser>, t: Throwable) {
        callback(null)
      }
    })
  }

  fun getUserRepositories(username: String, callback: (List<GitHubRepo>?) -> Unit) {
    val cachedRepos = DataInteractor.getRepos(username)
    if (cachedRepos != null) {
      println("repository already found at local data")
      callback(cachedRepos)
      return
    }

    api.getUserRepositories(username).enqueue(object : Callback<List<GitHubRepo>> {
      override fun onResponse(call: Call<List<GitHubRepo>>, response: Response<List<GitHubRepo>>) {
        if (response.isSuccessful) {
          response.body()?.let {
            DataInteractor.storeUserRepos(username, it)
            callback(it)
          }
        } else {
          callback(null)
        }
      }

      override fun onFailure(call: Call<List<GitHubRepo>>, t: Throwable) {
        callback(null)
      }
    })
  }
}

