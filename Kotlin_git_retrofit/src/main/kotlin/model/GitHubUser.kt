package model

import com.google.gson.annotations.SerializedName

data class GitHubUser(
  val login: String,
  @SerializedName("followers") val followersCount: Int,
  @SerializedName("following") val followingCount: Int,
  @SerializedName("created_at") val createdAt: String
)
