package com.abdlateef.miqati.core.common

/**
 * Represents the result of an operation that can fail.
 * Sealed class for exhaustive when expressions.
 */
sealed class Result<out T> {
    data class Success<out T>(val data: T) : Result<T>()
    data class Error(val exception: Throwable) : Result<Nothing>()

    val isSuccess: Boolean get() = this is Success
    val isError: Boolean get() = this is Error

    fun getOrNull(): T? = when (this) {
        is Success -> data
        is Error -> null
    }

    fun exceptionOrNull(): Throwable? = when (this) {
        is Success -> null
        is Error -> exception
    }

    inline fun <R> map(transform: (T) -> R): Result<R> = when (this) {
        is Success -> Success(transform(data))
        is Error -> Error(exception)
    }

    inline fun <R> flatMap(transform: (T) -> Result<R>): Result<R> = when (this) {
        is Success -> transform(data)
        is Error -> Error(exception)
    }

    inline fun fold(
        onSuccess: (T) -> Unit,
        onError: (Throwable) -> Unit
    ) {
        when (this) {
            is Success -> onSuccess(data)
            is Error -> onError(exception)
        }
    }
}

/**
 * Helper function to create a success result.
 */
fun <T> successOf(data: T): Result<T> = Result.Success(data)

/**
 * Helper function to create an error result.
 */
fun <T> errorOf(exception: Throwable): Result<T> = Result.Error(exception)

/**
 * Helper function to create an error result from a message.
 */
fun <T> errorOf(message: String): Result<T> = Result.Error(Exception(message))
