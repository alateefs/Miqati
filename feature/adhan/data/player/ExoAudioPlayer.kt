package com.abdlateef.miqati.feature.adhan.data.player

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import androidx.annotation.RawRes
import com.abdlateef.miqati.R
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import javax.inject.Inject
import javax.inject.Singleton

interface AudioPlayer {
    fun play(@RawRes soundResId: Int): Flow<PlayerState>
    fun stop()
    fun release()
    val isPlaying: Boolean
}

sealed class PlayerState {
    object Idle : PlayerState()
    object Buffering : PlayerState()
    object Playing : PlayerState()
    object Completed : PlayerState()
    data class Error(val message: String) : PlayerState()
}

@Singleton
class ExoAudioPlayer @Inject constructor(
    private val context: Context
) : AudioPlayer {

    private var exoPlayer: androidx.media3.exoplayer.ExoPlayer? = null
    private var audioFocusRequest: AudioFocusRequest? = null
    private var hasAudioFocus = false
    override val isPlaying: Boolean
        get() = exoPlayer?.isPlaying == true

    override fun play(@RawRes soundResId: Int): Flow<PlayerState> = callbackFlow {
        try {
            // Request audio focus
            if (!requestAudioFocus()) {
                trySend(PlayerState.Error("Failed to gain audio focus"))
                close()
                return@callbackFlow
            }

            // Create player
            val player = androidx.media3.exoplayer.ExoPlayer.Builder(context).build().apply {
                setMediaItem(
                    androidx.media3.common.MediaItem.fromUri(
                        android.net.Uri.parse("android.resource://${context.packageName}/raw/$soundResId")
                    )
                )
                prepare()
                addListener(object : androidx.media3.common.Player.Listener {
                    override fun onPlaybackStateChanged(state: Int) {
                        when (state) {
                            androidx.media3.common.Player.STATE_BUFFERING -> {
                                trySend(PlayerState.Buffering)
                            }
                            androidx.media3.common.Player.STATE_READY -> {
                                start()
                                trySend(PlayerState.Playing)
                            }
                            androidx.media3.common.Player.STATE_ENDED -> {
                                trySend(PlayerState.Completed)
                                close()
                            }
                            androidx.media3.common.Player.STATE_IDLE -> {
                                trySend(PlayerState.Idle)
                            }
                        }
                    }

                    override fun onPlayerError(error: androidx.media3.common.PlaybackException) {
                        trySend(PlayerState.Error(error.message ?: "Playback error"))
                        close()
                    }
                })
            }

            exoPlayer = player

        } catch (e: Exception) {
            trySend(PlayerState.Error(e.message ?: "Unknown error"))
            close()
        }

        awaitClose {
            stop()
        }
    }

    override fun stop() {
        exoPlayer?.let { player ->
            if (player.isPlaying) {
                player.stop()
            }
        }
        abandonAudioFocus()
    }

    override fun release() {
        stop()
        exoPlayer?.release()
        exoPlayer = null
        abandonAudioFocus()
    }

    private fun requestAudioFocus(): Boolean {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                .setOnAudioFocusChangeListener { focusChange ->
                    when (focusChange) {
                        AudioManager.AUDIOFOCUS_GAIN -> hasAudioFocus = true
                        AudioManager.AUDIOFOCUS_LOSS,
                        AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> hasAudioFocus = false
                    }
                }
                .build()

            audioManager.requestAudioFocus(audioFocusRequest!!) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        } else {
            @Suppress("DEPRECATION")
            audioManager.requestAudioFocus(
                { focusChange ->
                    when (focusChange) {
                        AudioManager.AUDIOFOCUS_GAIN -> hasAudioFocus = true
                        AudioManager.AUDIOFOCUS_LOSS,
                        AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> hasAudioFocus = false
                    }
                },
                AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK
            ) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        }
    }

    private fun abandonAudioFocus() {
        val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest?.let {
                audioManager.abandonAudioFocusRequest(it)
            }
        } else {
            @Suppress("DEPRECATION")
            audioManager.abandonAudioFocus { }
        }
        
        hasAudioFocus = false
    }
}
