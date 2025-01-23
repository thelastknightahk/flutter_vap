package com.example.vap_test

import android.content.Context
import android.os.Environment
import android.util.Log
import android.view.View
import com.tencent.qgame.animplayer.AnimConfig
import com.tencent.qgame.animplayer.AnimView
import com.tencent.qgame.animplayer.inter.IAnimListener
import com.tencent.qgame.animplayer.util.ScaleType
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.File

internal class NativeVapView(
    binaryMessenger: BinaryMessenger,
    context: Context,
    id: Int,
    creationParams: Map<String?, Any?>?
) : MethodChannel.MethodCallHandler, PlatformView {

    private val mContext: Context = context
    private val vapView: AnimView = AnimView(context)
    private val channel: MethodChannel
    private val eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null

    init {
        vapView.setScaleType(ScaleType.FIT_CENTER)
        vapView.setAnimListener(object : IAnimListener {
            override fun onFailed(errorType: Int, errorMsg: String?) {
                GlobalScope.launch(Dispatchers.Main) {
                    eventSink?.success(
                        mapOf(
                            "status" to "failure",
                            "errorMsg" to (errorMsg ?: "unknown error")
                        )
                    )
                }
            }

            override fun onVideoComplete() {
                GlobalScope.launch(Dispatchers.Main) {
                    eventSink?.success(mapOf("status" to "complete"))
                }
            }

            override fun onVideoDestroy() {
                // Handle video destroy if necessary
            }

            override fun onVideoRender(frameIndex: Int, config: AnimConfig?) {
                // Handle video render if necessary
            }

            override fun onVideoStart() {
                // Handle video start if necessary
            }
        })

        channel = MethodChannel(binaryMessenger, "flutter_vap_controller")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(binaryMessenger, "flutter_vap_event_channel")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun getView(): View {
        return vapView
    }

    override fun dispose() {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "playPath" -> {
                val path = call.argument<String>("path")
                if (path != null) {
                    vapView.startPlay(File(path))
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "Path is null", null)
                }
            }
            "playAsset" -> {
                val asset = call.argument<String>("asset")
                if (asset != null) {
                    vapView.startPlay(mContext.assets, "flutter_assets/$asset")
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "Asset is null", null)
                }
            }
            "stop" -> {
                vapView.stopPlay()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}
