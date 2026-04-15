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

# NetEase SDK
-keep class com.netease.** { *; }

# --- Missing optional dependencies (push SDKs, etc.) ---

# Google Firebase / GMS
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**

# Huawei HMS
-dontwarn com.huawei.hmf.**
-dontwarn com.huawei.hms.**
-dontwarn com.huawei.multimedia.**

# Xiaomi Push
-dontwarn com.xiaomi.mipush.**

# OPPO Push
-dontwarn com.heytap.msp.**

# Vivo Push
-dontwarn com.vivo.push.**

# Meizu Push
-dontwarn com.meizu.cloud.**

# Honor Push
-dontwarn com.hihonor.push.**

# SQLCipher
-dontwarn net.zetetic.**

# Aho-Corasick (pinyin helper)
-dontwarn org.ahocorasick.**

# NetEase internal annotations & compiler
-dontwarn com.netease.nimlib.aop.**
-dontwarn com.netease.nimlib.apt.**
-dontwarn com.netease.compiler.**

# GitHub promeg pinyin
-dontwarn com.github.promeg.**
