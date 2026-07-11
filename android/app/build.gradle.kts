plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "studio.leonidas.hexcalc"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "studio.leonidas.hexcalc"
        // minSdk 26 per the product plan (deterministic native deps, modern APIs).
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Three flavors on a single "app" dimension. The Dart side selects its typed
    // FlavorConfig via the matching main_<flavor>.dart entrypoint; here we only
    // vary the application id and display name so builds can coexist on a device.
    flavorDimensions += "app"
    productFlavors {
        create("development") {
            dimension = "app"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "HEX CALC Dev")
        }
        create("staging") {
            dimension = "app"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "HEX CALC Staging")
        }
        create("production") {
            dimension = "app"
            resValue("string", "app_name", "HEX CALC")
        }
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
