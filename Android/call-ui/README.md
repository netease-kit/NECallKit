# CallKit UI (IM) Library

网易云信音视频呼叫组件 UI 库，提供呼叫界面 UI 组件，依赖 `call` 基础库。

## Maven 坐标

```kotlin
implementation("com.netease.yunxin.kit.call:call-ui:<version>")
```

当前版本见 [libraryversions.toml](../libraryversions.toml) 中的 `CALL`。

## 发布到 Maven Central

### 环境变量

发布前需配置以下环境变量：

| 环境变量 | 用途 |
|---------|------|
| `APP_MAVEN_USER_NAME` | Sonatype OSSRH 用户名 |
| `APP_MAVEN_USER_PWD` | Sonatype OSSRH 密码 |
| `APP_MAVEN_KEY_PWD` | GPG 签名密钥密码 |

同时需要 GPG 签名文件：`development/maven/maven-signing.gpg`（Key ID: `1B67D96E`）

### 发布命令

```bash
# 发布所有库模块（call, call-ui）
./gradlew publishToMaven

# 仅发布本模块
./gradlew :callkit:call-ui:publishReleasePublicationToMavenCentralRepository
```

### 发布类型

- **Release**: 版本号不含 `-SNAPSHOT` 后缀，上传到 Maven Central staging 仓库，并自动触发 Sonatype Manual Upload
- **Snapshot**: 设置环境变量 `SNAPSHOT=true`，上传到 Maven Central snapshot 仓库

### 版本管理

版本号在 `libraryversions.toml` 中统一管理，CallKit 组内所有模块使用相同版本（`atomicGroupVersion`）。

格式：`major.minor.patch`，可带后缀 `-alpha`, `-beta`, `-rc`, `-dev`, `-SNAPSHOT`
