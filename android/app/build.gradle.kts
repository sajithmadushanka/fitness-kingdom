import java.util.Properties
import java.io.FileInputStream

// Load the local.properties file
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.fitness_kingdom"
    
    // Dynamically assign these properties
    compileSdk = flutter.compileSdkVersion
    ndkVersion = localProperties.getProperty("flutter.ndkVersion")?.takeIf { it.isNotBlank() } ?: flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.fitness_kingdom"
        
        // Dynamically assign minSdk and targetSdk
        minSdk = localProperties.getProperty("flutter.minSdkVersion")?.toInt() ?: flutter.minSdkVersion
        targetSdk = localProperties.getProperty("flutter.targetSdkVersion")?.toInt() ?: flutter.targetSdkVersion

        // These values are already managed by the Flutter plugin from pubspec.yaml
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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