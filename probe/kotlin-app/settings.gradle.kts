// 探针工程 B —— 真实 Kotlin + Compose Android 工程
//
// 目的：在 CI 里真跑一次 assembleDebug，让 Gradle 把「编译一个真实 KT/Compose
// 工程所需的全部依赖」拉到 GRADLE_USER_HOME，然后打包成 gradle-m2-offline。
//
// 为什么必须是真工程而不是空壳：Gradle 只会下载「真正被解析到」的依赖。
// 空壳工程跑出来的缓存里没有 AGP 内部链路、没有 Compose 编译器插件的传递依赖、
// 没有 aapt2/d8/apksig 那一坨 —— 用户拿到还是编不了。
//
// 版本严格对齐主人项目的 build.gradle.kts：
//   AGP 9.4.0（自带 Kotlin 支持，所以不额外 apply kotlin-android）
//   org.jetbrains.kotlin.plugin.compose 2.4.21
//   compose-bom 2026.09.00 / material3 1.5.0-beta02
//   compileSdk 37 / minSdk 26 / Java 17
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "probe-kotlin"
include(":app")