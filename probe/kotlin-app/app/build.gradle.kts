plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "probe.kotlin"
    compileSdk = 37

    defaultConfig {
        applicationId = "probe.kotlin"
        minSdk = 26
        targetSdk = 30
        versionCode = 1
        versionName = "1.0"
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    buildFeatures { compose = true }
    buildTypes {
        debug { isMinifyEnabled = false }
    }
    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }
}

// 依赖集的选取原则：覆盖「一个标准 Compose 工程最常引用的那几个」，
// 目的不是穷举，而是让 Gradle 把 AGP + Kotlin + Compose 三条链的
// 传递依赖全部解析一遍并落进缓存。
dependencies {
    implementation(platform("androidx.compose:compose-bom:2026.09.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.compose.material3:material3:1.5.0-beta02")
    implementation("androidx.compose.material:material-icons-core:1.7.3")
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.activity:activity-compose:1.9.2")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.8.3")
}