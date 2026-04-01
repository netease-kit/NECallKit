# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

-keep class com.netease.** { *; }# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.android.gms.common.GoogleApiAvailability
-dontwarn com.google.android.gms.tasks.OnCompleteListener
-dontwarn com.google.android.gms.tasks.Task
-dontwarn com.google.firebase.messaging.FirebaseMessaging
-dontwarn com.google.firebase.messaging.FirebaseMessagingService
-dontwarn com.heytap.msp.push.HeytapPushManager
-dontwarn com.heytap.msp.push.callback.ICallBackResultService
-dontwarn com.heytap.msp.push.mode.DataMessage
-dontwarn com.heytap.msp.push.service.CompatibleDataMessageCallbackService
-dontwarn com.heytap.msp.push.service.DataMessageCallbackService
-dontwarn com.hihonor.push.sdk.HonorMessageService
-dontwarn com.hihonor.push.sdk.HonorPushCallback
-dontwarn com.hihonor.push.sdk.HonorPushClient
-dontwarn com.hihonor.push.sdk.HonorPushDataMsg
-dontwarn com.huawei.hmf.tasks.OnCompleteListener
-dontwarn com.huawei.hmf.tasks.Task
-dontwarn com.huawei.hms.aaid.HmsInstanceId
-dontwarn com.huawei.hms.api.HuaweiApiAvailability
-dontwarn com.huawei.hms.push.HmsMessageService
-dontwarn com.huawei.hms.push.HmsMessaging
-dontwarn com.huawei.hms.push.RemoteMessage
-dontwarn com.huawei.multimedia.audiokit.interfaces.AudioFeaturesKit
-dontwarn com.huawei.multimedia.audiokit.interfaces.HwAudioKaraokeFeatureKit$ParameName
-dontwarn com.huawei.multimedia.audiokit.interfaces.HwAudioKaraokeFeatureKit
-dontwarn com.huawei.multimedia.audiokit.interfaces.HwAudioKit$FeatureType
-dontwarn com.huawei.multimedia.audiokit.interfaces.HwAudioKit
-dontwarn com.huawei.multimedia.audiokit.interfaces.IAudioKitCallback
-dontwarn com.meizu.cloud.pushsdk.MzPushMessageReceiver
-dontwarn com.meizu.cloud.pushsdk.PushManager
-dontwarn com.meizu.cloud.pushsdk.handler.MzPushMessage
-dontwarn com.meizu.cloud.pushsdk.notification.PushNotificationBuilder
-dontwarn com.meizu.cloud.pushsdk.platform.message.PushSwitchStatus
-dontwarn com.meizu.cloud.pushsdk.platform.message.RegisterStatus
-dontwarn com.meizu.cloud.pushsdk.platform.message.SubAliasStatus
-dontwarn com.meizu.cloud.pushsdk.platform.message.SubTagsStatus
-dontwarn com.meizu.cloud.pushsdk.platform.message.UnRegisterStatus
-dontwarn com.netease.compiler.CheckCallback
-dontwarn com.netease.nimlib.aop.annotation.CostTime
-dontwarn com.netease.nimlib.apt.annotation.NIMService
-dontwarn com.vivo.push.IPushActionListener
-dontwarn com.vivo.push.PushClient
-dontwarn com.vivo.push.PushConfig$Builder
-dontwarn com.vivo.push.PushConfig
-dontwarn com.vivo.push.listener.IPushQueryActionListener
-dontwarn com.vivo.push.model.UPSNotificationMessage
-dontwarn com.vivo.push.model.UnvarnishedMessage
-dontwarn com.vivo.push.sdk.OpenClientPushMessageReceiver
-dontwarn com.xiaomi.mipush.sdk.MiPushClient
-dontwarn com.xiaomi.mipush.sdk.MiPushCommandMessage
-dontwarn com.xiaomi.mipush.sdk.MiPushMessage
-dontwarn com.xiaomi.mipush.sdk.PushMessageReceiver
-dontwarn net.zetetic.database.DatabaseErrorHandler
-dontwarn net.zetetic.database.DefaultDatabaseErrorHandler
-dontwarn net.zetetic.database.sqlcipher.SQLiteConnection
-dontwarn net.zetetic.database.sqlcipher.SQLiteDatabase$CursorFactory
-dontwarn net.zetetic.database.sqlcipher.SQLiteDatabase
-dontwarn net.zetetic.database.sqlcipher.SQLiteDatabaseHook
-dontwarn org.ahocorasick.trie.Trie
