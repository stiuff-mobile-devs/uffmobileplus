import java.util.Properties
import java.io.FileInputStream

// Carrega as propriedades do arquivo key.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "br.uff.uffmobileplus"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Configuração das chaves de assinatura
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            // Support both absolute and relative paths in key.properties:
            // - If storeFile is absolute (starts with '/' or a Windows drive like C:\), use it directly
            // - Otherwise treat it as relative to the android/ directory (original behavior)
            val storeFileProp = keystoreProperties.getProperty("storeFile")
            storeFile = storeFileProp?.let { prop ->
                val trimmed = prop.trim()
                // detect absolute unix path or Windows drive letter
                val isAbsoluteUnix = trimmed.startsWith("/")
                val isWindowsDrive = trimmed.length >= 2 && trimmed[1] == ':'
                if (isAbsoluteUnix || isWindowsDrive) {
                    file(trimmed)
                } else {
                    // original behavior expected the keystore in android/
                    file("../$trimmed")
                }
            }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "br.uff.uffmobileplus"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appAuthRedirectScheme"] = "br.uff.uffmobileplus"
    }

    buildTypes {
        release {
            // Usa as chaves de assinatura configuradas para release
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
  // Import the Firebase BoM
  implementation(platform("com.google.firebase:firebase-bom:34.2.0"))


  // TODO: Add the dependencies for Firebase products you want to use
  // When using the BoM, don't specify versions in Firebase dependencies
  implementation("com.google.firebase:firebase-analytics")


  // Add the dependencies for any other desired Firebase products
  // https://firebase.google.com/docs/android/setup#available-libraries
  coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
