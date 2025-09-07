# Keep Flutter/Dart entry points
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.gson.** { *; }

# Google Play Core splitinstall (deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Drift (Moor) generated classes and sqlite
-keep class com.squareup.sqldelight.** { *; }
-keep class androidx.sqlite.** { *; }

# Kotlin metadata
-keepclassmembers class ** {
    @kotlin.Metadata *;
}

# Prevent stripping of classes with reflection usage
-keepattributes *Annotation*

# Suppress optional XML stream/Tika classes warnings (not used at runtime on Android)
-dontwarn javax.xml.stream.**
-dontwarn org.apache.tika.**

# Keep SQLCipher
-keep class net.sqlcipher.** { *; }

# Keep Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep annotations
-keep @interface javax.annotation.Nullable
-keep @interface javax.annotation.concurrent.GuardedBy
-keep @interface javax.annotation.concurrent.ThreadSafe

# Keep Tink crypto classes
-keep class com.google.crypto.tink.** { *; }
-keep class com.google.crypto.tink.proto.** { *; }

# Keep OLM
-keep class org.matrix.olm.** { *; }

# Keep WebView
-keep class android.webkit.** { *; }

# Keep media
-keep class android.media.** { *; }

# Keep notifications
-keep class android.app.** { *; }

# Keep permissions
-keep class android.content.pm.** { *; }

# Keep file operations
-keep class android.os.** { *; }

# Keep network
-keep class java.net.** { *; }
-keep class javax.net.** { *; }

# Keep JSON
-keep class com.google.gson.** { *; }
-keep class org.json.** { *; }

# Keep HTTP
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }

# Keep database
-keep class org.sqlite.** { *; }
-keep class com.simolus3.** { *; }

# Keep image processing
-keep class android.graphics.** { *; }
-keep class android.renderscript.** { *; }

# Keep encryption
-keep class javax.crypto.** { *; }
-keep class java.security.** { *; }

# Keep serialization
-keep class com.google.protobuf.** { *; }

# Keep reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep native libraries
-keep class * {
    native <methods>;
}

# Keep JNI
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep inner classes
-keep class *$* {
    <fields>;
    <methods>;
}

# Keep synthetic methods
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep WebView JavaScript interface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep all classes in the app package
-keep class com.katya.wtf.** { *; }

# Keep all classes in the lib package
-keep class lib.** { *; }

# Keep all classes in the olm package
-keep class olm.** { *; }

# Keep all classes in the matrix package
-keep class matrix.** { *; }

# Keep all classes in the crypto package
-keep class crypto.** { *; }

# Keep all classes in the network package
-keep class network.** { *; }

# Keep all classes in the storage package
-keep class storage.** { *; }

# Keep all classes in the ui package
-keep class ui.** { *; }

# Keep all classes in the utils package
-keep class utils.** { *; }

# Keep all classes in the models package
-keep class models.** { *; }

# Keep all classes in the services package
-keep class services.** { *; }

# Keep all classes in the widgets package
-keep class widgets.** { *; }

# Keep all classes in the views package
-keep class views.** { *; }

# Keep all classes in the store package
-keep class store.** { *; }

# Keep all classes in the global package
-keep class global.** { *; }

# Keep all classes in the katya package
-keep class katya.** { *; }