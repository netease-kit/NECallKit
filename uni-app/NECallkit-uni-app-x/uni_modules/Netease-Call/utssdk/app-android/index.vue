<template>
  <view class="defaultStyles"> </view>
</template>
<script lang="uts">
import CallLayout from 'com.netease.yunxin.nertc.ui.view.CallLayout';
import { NAME } from './utils/index.uts';

export default {
	name: "call-view",
	created() {
		console.log(`${NAME["PREFIX"]} CallLayout created`);
	},
	NVLoad() : CallLayout {
		let callview = new CallLayout($androidContext!)
		console.log(`${NAME["PREFIX"]} CallLayout NVLoad, ${callview}`);
		return callview;
	},
	NVLoaded() {
		console.log(`${NAME["PREFIX"]} CallLayout NVLoaded, ${UTSAndroid.devicePX2px(1080)}`);
	},
	NVLayouted() {
		console.log(`${NAME["PREFIX"]} CallLayout NVLayouted`);
	},
	NVUpdateStyles(styles : Map<String, any>) {
		console.log(`${NAME["PREFIX"]} CallLayout NVUpdateStyles, ${styles}`);
	},
	NVBeforeUnload() {
		console.log(`${NAME["PREFIX"]} CallLayout NVBeforeUnload`);
	},
	NVUnloaded() {
		console.log(`${NAME["PREFIX"]} CallLayout NVUnloaded`);
	},
	unmounted() {
		console.log(`${NAME["PREFIX"]} CallLayout unmounted`);
	}
}
</script>

<style>
/* 定义默认样式值, 组件使用者没有配置时使用 */
.defaultStyles {
  background-color: white;
}
</style>
