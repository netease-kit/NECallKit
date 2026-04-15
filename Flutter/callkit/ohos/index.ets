import CallkitPlugin from './src/main/ets/components/plugin/CallkitPlugin';

/**
 * NECallKit Flutter Plugin for HarmonyOS
 * 
 * 使用方式：
 * 1. 在 EntryAbility 的 onCreate 中调用 CallkitPlugin.setUIAbilityContext(this.context)
 * 2. Flutter 端先调用 NimCore.instance.initialize() 初始化 IM
 * 3. 然后调用 NECallEngine.instance.setup() 初始化 CallKit
 * 4. CallKit 会自动从 NIMSdk 获取 NIM 实例
 * 
 * 注意：必须在 Flutter 引擎初始化前设置 UIAbilityContext，否则 RTC SDK 初始化会失败。
 * 
 * 示例代码：
 * ```typescript
 * import CallkitPlugin from 'netease_callkit';
 * 
 * export default class EntryAbility extends FlutterAbility {
 *   onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
 *     CallkitPlugin.setUIAbilityContext(this.context);
 *     super.onCreate(want, launchParam);
 *   }
 * }
 * ```
 */
export default CallkitPlugin;
