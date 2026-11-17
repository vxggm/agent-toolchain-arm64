# agent-toolchain-arm64

AgentPad 自建 **aarch64 Android 构建工具链**。独立仓库，与 App 云构建仓库
`agent-workspace-ci` 完全分离，互不影响。

## 这是什么

一个可独立运行、无任何项目依赖的 Android APK 编译环境，全部二进制为
**原生 ELF aarch64（e_machine=0xB7）**，不需要 qemu、不需要 binfmt_misc。

| 组件 | 版本 | 说明 |
|---|---|---|
| JDK | Temurin OpenJDK 17.0.21+9 | linux/aarch64，glibc（兼容 Debian 系） |
| Gradle | 9.6.0 | bin 发行版，sha256 校验 |
| build-tools | 36.0.0 | aapt2 / zipalign / aidl / aapt / dexdump / split-select，aarch64 静态 |
| platforms | android-37 | android.jar |
| platform-tools | — | adb / fastboot / sqlite3 等 aarch64 |

## 产物

```
gradle-toolchain-arm64-v<版本>.tar.gz
gradle-toolchain-arm64-v<版本>.tar.gz.sha256
```

约 380MB（压缩后），解压后约 570MB。

## 怎么触发构建

- 手动：Actions → `build-toolchain-arm64` → Run workflow，可填版本号
- 推送：改动 `.github/workflows/toolchain-arm64.yml` 或 `toolchain/**`

## 目录约定

```
toolchain/
├── android.jar          # 43MB，平台 API（不走 Google 直连）
├── d8.jar               # dex 编译器（纯 JVM）
├── apksigner.jar        # 签名（纯 JVM）
└── stamp.sh             # 打 AgentPad 来源标记
```

`android.jar` / `d8.jar` / `apksigner.jar` 三个是**与 CPU 架构无关**的纯 Java 件，
因此随仓库携带，避免 CI 直连 Google（国内不通）。

## 产物内的标记

解压后会看到三处身份标记，用于确认「这是 AgentPad 自建，不是转发的 Google SDK」：

| 位置 | 内容 |
|---|---|
| `AGENTPAD-TOOLCHAIN.txt` | 人读的完整清单与来源声明 |
| `.agentpad/mark.env` | 机器可读的 `AGENTPAD_*` 键值 |
| `*.agentpad.txt` | 关键二进制旁的小标签 |

自检（只读）：

```sh
sh verify.sh
```

输出应显示各二进制的 `0xB7`，并打印 `java -version` 与 `aapt2 version`。

## 与 App 的接线

产物上传官网 `downloads/`，由 App 的「下载环境」卡片下载解压到沙箱 `/opt`，
再通过 `init.d` 注入 `android.aapt2FromMavenOverride` 指向 arm64 原生 aapt2。

⚠️ 关键前提：SDK 里 `build-tools/*/aapt2` 必须是 arm64 原生。官方 SDK 里那个是
x86_64，在手机上 `cannot execute: required file not found`，必须替换。