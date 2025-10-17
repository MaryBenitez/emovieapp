plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")      // <- en vez de "kotlin-android"
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.emovieapp"

    // Fuerza lo que pide fluttertoast
    compileSdk = 36                          // <- antes: flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"             // <- antes: flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.emovieapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // AGP 8+ => Java 17
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
