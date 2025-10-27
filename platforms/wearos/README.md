# Wear OS Platform Configuration

## Target Platforms
- Wear OS 3.0+ (Google's smartwatch platform)
- Samsung Galaxy Watch series
- Google Pixel Watch
- Fossil, TicWatch, and other Wear OS devices
- Standalone and companion modes

## Development Requirements
- Wear OS SDK
- Android Studio with Wear OS tools
- Wear OS emulator
- Google Play Services for Wear OS
- Android SDK 30+ (API level 30+)

## Build Settings
- **Wear OS Version**: 3.0+
- **Target Architecture**: ARM64, ARMv7
- **Minimum SDK**: API 30 (Wear OS 3.0)
- **Target SDK**: API 33+ (latest)
- **Build Type**: Release, Debug

## Project Structure
```
wearos/
├── src/
│   ├── main/
│   │   ├── AndroidManifest.xml
│   │   ├── java/
│   │   └── res/
│   └── wear/
│       ├── AndroidManifest.xml
│       ├── java/
│       ├── res/
│       └── assets/
├── build.gradle
└── wear.gradle
```

## Wear OS Manifest

### Main App Manifest
```xml
<!-- wearos/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.katya.wearos">

    <uses-feature android:name="android.hardware.type.watch" />

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:theme="@style/AppTheme">

        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- Wear OS specific components -->
        <service
            android:name=".wear.MessagingWearService"
            android:exported="true">
            <intent-filter>
                <action android:name="com.google.android.gms.wearable.MESSAGE_RECEIVED" />
                <data android:scheme="wear" android:host="*" android:path="/messaging" />
            </intent-filter>
        </service>

    </application>

</manifest>
```

### Wear Module Manifest
```xml
<!-- wearos/src/wear/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.katya.wear">

    <uses-feature android:name="android.hardware.type.watch" />

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher_round"
        android:label="@string/app_name"
        android:theme="@style/AppTheme">

        <meta-data
            android:name="com.google.android.wearable.standalone"
            android:value="true" />

        <activity
            android:name=".WearMainActivity"
            android:exported="true"
            android:taskAffinity="com.katya.wear.main">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- Wear OS complications -->
        <service
            android:name=".complications.MessagingComplicationProviderService"
            android:exported="true"
            android:permission="com.google.android.wearable.permission.BIND_COMPLICATION_PROVIDER">
            <intent-filter>
                <action android:name="android.support.wearable.complications.ACTION_COMPLICATION_UPDATE_REQUEST" />
            </intent-filter>
        </service>

        <!-- Wear OS tiles -->
        <service
            android:name=".tiles.MessagingTileService"
            android:exported="true"
            android:permission="com.google.android.wearable.permission.BIND_TILE_PROVIDER">
            <intent-filter>
                <action android:name="androidx.wear.tiles.action.BIND_TILE_PROVIDER" />
            </intent-filter>
        </service>

    </application>

</manifest>
```

## Wear OS Integration

### Wearable Data Layer
```kotlin
// wearos/src/wear/java/com/katya/wear/WearDataLayer.kt
class WearDataLayer(private val context: Context) : DataClient.OnDataChangedListener {

    private val dataClient: DataClient by lazy {
        Wearable.getDataClient(context)
    }

    private val messageClient: MessageClient by lazy {
        Wearable.getMessageClient(context)
    }

    fun initialize() {
        dataClient.addListener(this)
    }

    fun sendMessage(path: String, data: ByteArray) {
        val nodeId = getConnectedNodeId()
        if (nodeId != null) {
            messageClient.sendMessage(nodeId, path, data)
        }
    }

    fun putDataItem(path: String, data: Map<String, String>) {
        val putDataReq = PutDataRequest.create(path).apply {
            dataMap.putAll(data)
        }
        dataClient.putDataItem(putDataReq)
    }

    override fun onDataChanged(dataEvents: DataEventBuffer) {
        dataEvents.forEach { event ->
            when (event.type) {
                DataEvent.TYPE_CHANGED -> {
                    val dataItem = event.dataItem
                    handleDataChanged(dataItem)
                }
                DataEvent.TYPE_DELETED -> {
                    val dataItem = event.dataItem
                    handleDataDeleted(dataItem)
                }
            }
        }
    }

    private fun getConnectedNodeId(): String? {
        // Get connected phone node ID
        return null // Implementation needed
    }
}
```

### Wear OS Complications
```kotlin
// wearos/src/wear/java/com/katya/wear/complications/MessagingComplication.kt
class MessagingComplicationProviderService : ComplicationProviderService() {

    override fun onComplicationUpdate(
        complicationId: Int,
        type: ComplicationType,
        complicationManager: ComplicationManager
    ) {
        val complicationData = when (type) {
            ComplicationType.SHORT_TEXT -> {
                // Show unread message count
                val unreadCount = getUnreadMessageCount()
                ShortTextComplicationData.Builder(
                    text = PlainComplicationText.Builder(unreadCount.toString()).build(),
                    contentDescription = PlainComplicationText.Builder("Unread messages").build()
                )
                    .setTitle(PlainComplicationText.Builder("Katya").build())
                    .build()
            }
            ComplicationType.LONG_TEXT -> {
                // Show latest message preview
                val latestMessage = getLatestMessage()
                LongTextComplicationData.Builder(
                    text = PlainComplicationText.Builder(latestMessage.content).build(),
                    contentDescription = PlainComplicationText.Builder("Latest message").build()
                )
                    .setTitle(PlainComplicationText.Builder("Katya").build())
                    .build()
            }
            else -> null
        }

        if (complicationData != null) {
            complicationManager.updateComplicationData(complicationId, complicationData)
        }
    }

    private fun getUnreadMessageCount(): Int {
        // Get unread message count from messaging service
        return 5 // Placeholder
    }

    private fun getLatestMessage(): Message {
        // Get latest message from messaging service
        return Message("Hello from Katya!", "Contact") // Placeholder
    }
}
```

### Wear OS Tiles
```kotlin
// wearos/src/wear/java/com/katya/wear/tiles/MessagingTileService.kt
class MessagingTileService : TileService() {

    override fun onTileRequest(requestParams: TileRequest): Tile {
        return Tile.Builder()
            .setResourcesVersion("1")
            .setTileTimeline(
                Timeline.Builder()
                    .addTimelineEntry(
                        TimelineEntry.Builder()
                            .setLayout(
                                Layout.Builder()
                                    .setRoot(
                                        layoutForTile()
                                    )
                                    .build()
                            )
                            .build()
                    )
                    .build()
            )
            .build()
    }

    private fun layoutForTile(): LayoutElement {
        return Column.Builder()
            .addContent(
                Text.Builder()
                    .setText("Katya")
                    .setFontStyle(FontStyle.title3())
                    .build()
            )
            .addContent(
                Text.Builder()
                    .setText("5 unread")
                    .setFontStyle(FontStyle.body2())
                    .build()
            )
            .addContent(
                Button.Builder()
                    .setContent(
                        Text.Builder()
                            .setText("Open")
                            .build()
                    )
                    .setAction(
                        Action.Builder()
                            .setAndroidActivity(
                                Action.AndroidActivity.Builder()
                                    .setClassName("com.katya.wear.WearMainActivity")
                                    .setPackageName("com.katya.wear")
                                    .build()
                            )
                            .build()
                    )
                    .build()
            )
            .build()
    }
}
```

## Platform-Specific Features

### Always-On Display
```kotlin
// wearos/src/wear/java/com/katya/wear/AlwaysOnDisplay.kt
class AlwaysOnDisplayManager(private val context: Context) {

    fun initialize() {
        // Set up always-on display mode
        setAmbientMode()
        configureBurnInProtection()
    }

    private fun setAmbientMode() {
        // Configure ambient mode for low power
        val ambientDetails = AmbientModeSupport.AmbientCallback() {
            // Update UI for ambient mode
            updateAmbientUI()
        }
    }

    private fun configureBurnInProtection() {
        // Configure burn-in protection for OLED screens
        Wearable.getDataClient(context).putDataItem(
            PutDataRequest.create("/burnin_protection")
                .setData("enabled".toByteArray())
        )
    }
}
```

### Health Integration
```kotlin
// wearos/src/wear/java/com/katya/wear/HealthIntegration.kt
class HealthIntegration(private val context: Context) {

    private val healthServicesClient: HealthServicesClient by lazy {
        HealthServices.getClient(context)
    }

    suspend fun initializeHealthTracking() {
        try {
            val capabilities = healthServicesClient.capabilities
            if (capabilities.supportsExerciseTracking()) {
                startExerciseTracking()
            }
            if (capabilities.supportsHeartRateTracking()) {
                startHeartRateTracking()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize health tracking", e)
        }
    }

    private suspend fun startExerciseTracking() {
        // Start exercise tracking for activity recognition
        val exerciseClient = healthServicesClient.exerciseClient
        exerciseClient.prepareExercise(ExerciseType.WORKOUT)
    }

    private suspend fun startHeartRateTracking() {
        // Start heart rate tracking
        val heartRateClient = healthServicesClient.heartRateClient
        heartRateClient.registerHeartRateDataCallback { heartRate ->
            // Handle heart rate data
            Log.d(TAG, "Heart rate: ${heartRate.value}")
        }
    }
}
```

## Build Configuration

### Wear OS Dependencies
```gradle
// wearos/build.gradle
dependencies {
    implementation 'androidx.wear:wear:1.2.0'
    implementation 'androidx.wear:wear-phone-interactions:1.0.1'
    implementation 'androidx.wear:wear-remote-interactions:1.0.0'
    implementation 'androidx.wear:wear-watchface:1.1.1'
    implementation 'androidx.wear:wear-watchface-client:1.0.1'
    implementation 'androidx.wear:wear-watchface-editor:1.0.1'
    implementation 'androidx.wear.tiles:tiles:1.2.0'
    implementation 'androidx.wear.tiles:tiles-renderer:1.2.0'

    // Health Services
    implementation 'androidx.health:health-services-client:1.0.0-beta03'

    // Wear OS specific
    implementation 'com.google.android.gms:play-services-wearable:18.0.0'
    implementation 'com.google.android.support:wearable:2.9.0'
    implementation 'com.google.android.wearable:wearable:2.9.0'
}
```

## Build Commands

### Wear OS Standalone App
```bash
# Build standalone Wear OS app
flutter build apk --target-platform android-arm64 --flavor wearos

# Build with specific Wear OS optimizations
flutter build apk --target-platform android-arm64 --flavor wearos --dart-define=WEAR_OS=true
```

### Wear OS with Phone Companion
```bash
# Build wear module
flutter build apk --target-platform android-arm64 --flavor wearos --module

# Build phone module
flutter build apk --target-platform android-arm64 --flavor phone

# Create wear bundle
flutter build wear-app --target-platform android-arm64
```

## Distribution

### Google Play Store (Wear OS)
```bash
# Build for Play Store
flutter build appbundle --target-platform android-arm64 --flavor wearos

# Submit to Wear OS section of Play Store
fastlane deploy_wearos
```

### Galaxy Store (Samsung Watches)
```bash
# Build for Galaxy Store
flutter build appbundle --target-platform android-arm64 --flavor galaxy-watch

# Submit to Samsung Galaxy Store
fastlane deploy_galaxy_watch
```

## Testing

### Wear OS Testing Framework
```kotlin
// wearos/src/test/java/com/katya/wear/WearOSTests.kt
class WearOSIntegrationTests {

    @Test
    fun testDataLayerConnection() {
        // Test data layer connection between phone and watch
        val wearDataLayer = WearDataLayer(mockContext)
        wearDataLayer.initialize()

        // Verify connection
        assertTrue(wearDataLayer.isConnected())
    }

    @Test
    fun testComplicationProvider() {
        // Test complication provider
        val complicationService = MessagingComplicationProviderService()
        // Test complication data generation
    }

    @Test
    fun testTileService() {
        // Test tile service
        val tileService = MessagingTileService()
        // Test tile layout generation
    }
}
```

## Performance Optimization

### Wear OS Performance
```kotlin
// wearos/src/wear/java/com/katya/wear/PerformanceOptimizer.kt
class WearOSPerformanceOptimizer {

    fun initializeOptimizations() {
        // Enable battery optimization
        enableBatteryOptimization()

        // Configure memory management
        configureMemoryManagement()

        // Set up ambient mode
        setupAmbientMode()

        // Configure networking
        configureNetworking()
    }

    private fun enableBatteryOptimization() {
        // Enable battery optimization for Wear OS
        // Reduce network polling frequency
        // Optimize sensor usage
    }

    private fun configureMemoryManagement() {
        // Configure memory management for small RAM
        // Implement efficient caching
        // Manage background tasks
    }

    private fun setupAmbientMode() {
        // Set up ambient mode for always-on display
        // Configure low-power rendering
        // Handle screen off scenarios
    }
}
```

## Wear OS Specific UI

### Watch Face Complications
```kotlin
// wearos/src/wear/java/com/katya/wear/watchface/MessagingWatchFace.kt
class MessagingWatchFaceService : WatchFaceService() {

    override fun createWatchFace(): WatchFace {
        return object : WatchFace(this) {
            override fun onCreateEngine(): Engine {
                return MessagingWatchFaceEngine()
            }
        }
    }

    inner class MessagingWatchFaceEngine : Engine() {
        override fun onCreate(holder: SurfaceHolder) {
            super.onCreate(holder)
            // Initialize watch face
        }

        override fun onTimeTick() {
            super.onTimeTick()
            // Update time display
            invalidate()
        }

        override fun onDraw(canvas: Canvas, bounds: Rect) {
            super.onDraw(canvas, bounds)
            // Draw watch face with messaging info
            drawTime(canvas, bounds)
            drawMessageIndicator(canvas, bounds)
        }
    }
}
```

## Security

### Wear OS Security
```kotlin
// wearos/src/wear/java/com/katya/wear/SecurityManager.kt
class WearOSSecurityManager {

    fun initializeSecurity() {
        // Initialize Wear OS security features
        enableEncryption()
        setupSecureStorage()
        configureAuthentication()
    }

    private fun enableEncryption() {
        // Enable encryption for data at rest
        // Use Android Keystore for key management
    }

    private fun setupSecureStorage() {
        // Set up secure storage for sensitive data
        // Use EncryptedSharedPreferences
    }

    private fun configureAuthentication() {
        // Configure authentication for Wear OS
        // Integrate with phone's authentication
    }
}
```

## Support

### Wear OS Developer Support
- **Wear OS Developer Documentation**: https://developer.android.com/wear
- **Wear OS Community**: https://developers.google.com/community/wearos
- **Samsung Galaxy Watch**: https://developer.samsung.com/galaxy-watch
- **Google Play Console**: Wear OS publishing guidelines

## Resources

- [Wear OS Developer Documentation](https://developer.android.com/wear)
- [Wear OS Design Guidelines](https://developer.android.com/design/ui/wear)
- [Health Services API](https://developer.android.com/health-and-fitness)
- [Tiles API Documentation](https://developer.android.com/training/wearables/tiles)
- [Complications API](https://developer.android.com/training/wearables/complications)
