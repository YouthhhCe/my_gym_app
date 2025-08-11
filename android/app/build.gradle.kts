import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(localPropertiesFile.reader())
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode")?.toInt() ?: 1
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

android {
    namespace = "com.example.my_gym_app"
    compileSdk = flutter.compileSdkVersion
    
    // 【修复一：NDK 版本问题】
    // 根据日志提示，明确指定所有插件都需要的 NDK 版本
    ndkVersion = "27.0.12077973" 

    // 【修复二：核心库脱糖问题 - 第 1 步】
    // 开启核心库脱糖功能
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.example.my_gym_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

kotlin {
    jvmToolchain(17)
}

dependencies {
    // 【修复二：核心库脱糖问题 - 第 2 步】
    // 添加脱糖库本身作为依赖
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // 使用一个稳定版本
    
    // 您其他的依赖项可以放在这里
}
