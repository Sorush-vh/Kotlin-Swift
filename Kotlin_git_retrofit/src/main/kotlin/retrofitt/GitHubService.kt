package retrofitt

import model.GitHubRepo
import model.GitHubUser
import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Path

interface GitHubService {
    @GET("users/{username}")
    fun getUserInfo(@Path("username") username: String): Call<GitHubUser>

    @GET("users/{username}/repos")
    fun getUserRepositories(@Path("username") username: String): Call<List<GitHubRepo>>
}
