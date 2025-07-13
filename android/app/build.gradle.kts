plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.shka.tubemate"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8 // <--- CHANGE BACK TO 1.8
        targetCompatibility = JavaVersion.VERSION_1_8 // <--- CHANGE BACK TO 1.8
        // For desugaring, Android specifically wants Java 8 (1.8) source/target compatibility.
        // Even if you develop with Java 11, the desugaring process works on the Java 8 bytecode output.
    }

    kotlinOptions {
        jvmTarget = '1.8' // <--- CHANGE BACK TO 1.8. Desugaring implies a Java 8 target.
    }

    // NEW: Add this buildFeatures block
    buildFeatures {
        // Enables core library desugaring for Java 8 APIs on older Android versions.
        // This is usually implied by adding the desugaring dependency, but explicitly setting it
        // helps ensure it's enabled.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.shka.tubemate"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // This is where you need to add the desugaring library.
    // Ensure you add it inside the `dependencies {}` block.
    // Check for the latest stable version: https://developer.android.com/studio/write/java8-support.html#library-desugaring
    // As of recent times, 2.0.4 is a common stable version.
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'
    // Other dependencies like implementation flutter.framework etc. will be here automatically
}