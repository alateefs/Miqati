package com.abdlateef.miqati.feature.adhan.data.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import com.abdlateef.miqati.MainActivity
import com.abdlateef.miqati.R
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class AdhanPlaybackService : Service() {

    companion object {
        const val NOTIFICATION_CHANNEL_ID = "adhan_channel"
        const val NOTIFICATION_ID = 1001
        const val ACTION_STOP = "com.abdlateef.miqati.STOP_ADHAN"
        
        fun createNotificationChannel(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    NOTIFICATION_CHANNEL_ID,
                    "Adhan Notifications",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Notifications for prayer call (Adhan)"
                    enableVibration(false)
                    setShowBadge(false)
                }
                
                val notificationManager = context.getSystemService(NotificationManager::class.java)
                notificationManager?.createNotificationChannel(channel)
            }
        }
    }

    private var player: ExoPlayer? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel(this)
        initPlayer()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopAdhan()
                stopSelf()
            }
        }
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        player?.release()
        player = null
        super.onDestroy()
    }

    private fun initPlayer() {
        player = ExoPlayer.Builder(this).build().apply {
            addListener(object : Player.Listener {
                override fun onPlaybackStateChanged(state: Int) {
                    if (state == Player.STATE_ENDED) {
                        stopSelf()
                    }
                }
            })
        }
    }

    fun playAdhan(soundResId: Int) {
        val mediaItem = androidx.media3.common.MediaItem.fromUri(
            android.net.Uri.parse("android.resource://${packageName}/raw/$soundResId")
        )
        
        player?.apply {
            setMediaItem(mediaItem)
            prepare()
            play()
        }

        startForeground(NOTIFICATION_ID, createNotification())
    }

    private fun stopAdhan() {
        player?.stop()
        stopForeground(STOP_FOREGROUND_REMOVE)
    }

    private fun createNotification() = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
        .setContentTitle("Adhan Playing")
        .setContentText("Prayer call is playing")
        .setSmallIcon(R.drawable.ic_notification)
        .setOngoing(true)
        .addAction(
            R.drawable.ic_stop,
            "Stop",
            PendingIntent.getService(
                this,
                0,
                Intent(this, AdhanPlaybackService::class.java).apply {
                    action = ACTION_STOP
                },
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        )
        .setContentIntent(
            PendingIntent.getActivity(
                this,
                0,
                Intent(this, MainActivity::class.java),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        )
        .build()
}
