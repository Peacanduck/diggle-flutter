// MainActivity.kt
// Main Android activity with Solana Mobile Wallet Adapter integration.
//
// This file handles the platform channel bridge between Flutter and
// the native Solana Mobile Wallet Adapter SDK.
//
// Dependencies needed in android/app/build.gradle:
// implementation("com.solanamobile:mobile-wallet-adapter-clientlib-ktx:2.0.0")
// implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")

package com.example.diggle

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import android.util.Log

/**
 * Main activity for Diggle game.
 * 
 * Handles the Flutter engine configuration and sets up the platform channel
 * for Solana Mobile Wallet Adapter communication.
 */
class MainActivity : FlutterActivity(), MethodCallHandler {
    
    companion object {
        private const val TAG = "DiggleWallet"
        private const val CHANNEL_NAME = "com.example.diggle/wallet"
    }

    // Method channel for Flutter communication
    private lateinit var methodChannel: MethodChannel
    
    // Coroutine scope for async wallet operations
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    
    // Cached wallet state
    private var connectedPublicKey: String? = null
    private var connectedWalletName: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up the method channel
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        methodChannel.setMethodCallHandler(this)
        
        Log.d(TAG, "Wallet method channel configured")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(TAG, "Method called: ${call.method}")
        
        when (call.method) {
            "connect" -> handleConnect(result)
            "disconnect" -> handleDisconnect(result)
            "getPublicKey" -> handleGetPublicKey(result)
            "isAvailable" -> handleIsAvailable(result)
            "getWalletName" -> handleGetWalletName(result)
            else -> result.notImplemented()
        }
    }

    /**
     * Handle wallet connection request.
     * 
     * This would launch the Solana Mobile Wallet Adapter authorization flow.
     * For MVP, we provide a scaffold that can be completed with the actual SDK.
     */
    private fun handleConnect(result: Result) {
        scope.launch {
            try {
                // ================================================
                // SOLANA MOBILE WALLET ADAPTER INTEGRATION
                // ================================================
                // 
                // To complete this integration, add the following dependency
                // to android/app/build.gradle:
                //
                // implementation("com.solanamobile:mobile-wallet-adapter-clientlib-ktx:2.0.0")
                //
                // Then uncomment and use the following code:
                //
                // val walletAdapter = MobileWalletAdapter()
                // val authResult = walletAdapter.authorize(
                //     this@MainActivity,
                //     identityUri = Uri.parse("https://diggle.app"),
                //     iconUri = Uri.parse("https://diggle.app/icon.png"),
                //     identityName = "Diggle",
                //     cluster = "mainnet-beta"
                // )
                // 
                // connectedPublicKey = Base58.encode(authResult.publicKey)
                // connectedWalletName = authResult.walletUriBase?.host
                // result.success(connectedPublicKey)
                
                // For MVP without SDK, simulate connection error
                // This lets the game run without wallet while scaffolding is in place
                Log.w(TAG, "Wallet SDK not integrated - returning stub response")
                result.error(
                    "NOT_IMPLEMENTED",
                    "Solana Mobile Wallet Adapter SDK not integrated. " +
                    "See MainActivity.kt for integration instructions.",
                    null
                )
                
            } catch (e: Exception) {
                Log.e(TAG, "Connect error: ${e.message}", e)
                result.error("CONNECTION_FAILED", e.message, null)
            }
        }
    }

    /**
     * Handle wallet disconnection.
     */
    private fun handleDisconnect(result: Result) {
        scope.launch {
            try {
                // Clear cached state
                connectedPublicKey = null
                connectedWalletName = null
                
                // With full SDK integration:
                // walletAdapter.deauthorize(authToken)
                
                Log.d(TAG, "Wallet disconnected")
                result.success(true)
                
            } catch (e: Exception) {
                Log.e(TAG, "Disconnect error: ${e.message}", e)
                result.error("DISCONNECT_FAILED", e.message, null)
            }
        }
    }

    /**
     * Get the currently connected public key.
     */
    private fun handleGetPublicKey(result: Result) {
        result.success(connectedPublicKey)
    }

    /**
     * Check if Solana Mobile Wallet Adapter is available.
     * 
     * Returns true if at least one compatible wallet app is installed.
     */
    private fun handleIsAvailable(result: Result) {
        try {
            // Check if any wallet apps are installed that support the protocol
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("solana-wallet://")
            }
            val resolveInfo = packageManager.queryIntentActivities(intent, 0)
            val isAvailable = resolveInfo.isNotEmpty()
            
            Log.d(TAG, "Wallet available: $isAvailable (found ${resolveInfo.size} apps)")
            result.success(isAvailable)
            
        } catch (e: Exception) {
            Log.e(TAG, "isAvailable error: ${e.message}", e)
            result.success(false)
        }
    }

    /**
     * Get the name of the connected wallet app.
     */
    private fun handleGetWalletName(result: Result) {
        result.success(connectedWalletName)
    }

    override fun onDestroy() {
        super.onDestroy()
        scope.cancel()
    }
}