package model

import com.google.gson.annotations.SerializedName

data class ApiError(
    @SerializedName("message") val message: String,
    @SerializedName("documentation_url") val url: String,
)
