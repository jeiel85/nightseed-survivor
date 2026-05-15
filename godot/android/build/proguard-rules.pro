# ============================================================================
# Nightseed Survivor — ProGuard / R8 rules
# Goal: enable R8 (mapping.txt for Play Console) without breaking Godot's
# native ↔ Java bridge or the Play Game Services plugin.
# ============================================================================

# --- Godot Engine (4.2 stable) ---------------------------------------------
# The engine's JNI layer reaches into Java classes by fully-qualified name and
# uses reflection for plugin discovery. Keep the whole namespace.
-keep class org.godotengine.** { *; }
-dontwarn org.godotengine.**

# Native method bindings — required for any class that exposes JNI methods.
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve metadata that Godot reads at runtime.
-keepattributes Signature, InnerClasses, EnclosingMethod
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keepattributes SourceFile, LineNumberTable

# --- Godot plugins (PGS + future user plugins) -----------------------------
# Plugins are discovered via AndroidManifest meta-data and instantiated via
# reflection by the engine.
-keep class com.godot.plugin.** { *; }
-keep class org.godotengine.plugin.** { *; }

# --- Application module ----------------------------------------------------
-keep public class * extends android.app.Application
-keep public class * extends android.app.Activity
-keep class com.godot.game.** { *; }

# --- Google Play Services / Play Games SDK / AdMob ------------------------
# Most rules ship as consumer rules inside the AARs, but keep the public
# surface as belt-and-suspenders. The `com.google.android.gms.**` rule below
# also covers the AdMob SDK (com.google.android.gms.ads.**), which is pulled
# in by the Poing Studios plugin under addons/admob/.
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.ads.** { *; }
-dontwarn com.google.ads.**

# --- AndroidX --------------------------------------------------------------
-keep class androidx.fragment.app.** { *; }
-dontwarn androidx.**
-dontwarn kotlin.**
-dontwarn kotlinx.**

# --- Parcelable / Serializable contracts -----------------------------------
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# --- Misc ------------------------------------------------------------------
# Optional deps that may be referenced but not present at runtime.
-dontwarn java.lang.invoke.**
-dontwarn javax.annotation.**
-dontwarn sun.misc.**
