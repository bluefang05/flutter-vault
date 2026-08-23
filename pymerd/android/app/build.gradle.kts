plugins {
    id("com.android.application")
    // AGP 9 incorpora Kotlin directamente. No se debe aplicar kotlin-android.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.enmanuelapp.pymerd"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
        }
    }

    defaultConfig {
        applicationId = "com.enmanuelapp.pymerd"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Firma temporal de depuraciÃ³n para poder ejecutar flutter run --release.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
