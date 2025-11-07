<template>
	<div>
		<div class="call-container">
			<div class="form-section">
				<div class="form-grid">
					<label for="rtcChannelName">rtcChannelName：</label>
					<input type="text" id="rtcChannelName" v-model="rtcChannelName" class="input-field" placeholder="可选">

                    <label for="ainsMode">AI降噪：</label>
                    <picker mode="selector" :range="ainsOptions" range-key="label" :value="ainsIndex" @change="onAINSPickerChange">
                        <view class="input-field">{{ ainsOptions[ainsIndex] && ainsOptions[ainsIndex].label }}</view>
                    </picker>

					<label for="needPush">是否需要离线推送：</label>
					<switch :checked="needPush" @change="onToggleNeedPush" />

					<label for="pushContent">推送内容：</label>
					<input type="text" id="pushContent" v-model="pushContent" class="input-field" placeholder="可选">

					<label for="pushPayload">推送扩展：</label>
					<input type="text" id="pushPayload" v-model="pushPayload" class="input-field" placeholder="可选">
				</div>
			</div>

			<div class="button-container">
				<button type="primary" class="settings-btn" @click="saveSettings">保存</button>
			</div>
		</div>
	</div>
</template>

<style scoped>
	.call-container {
		padding: 20px;
		background-color: #f5f5f5;
		min-height: 100vh;
	}

	.form-section {
		background-color: white;
		border-radius: 8px;
		padding: 20px;
		margin-bottom: 20px;
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
	}

	.form-grid {
		display: grid;
		grid-template-columns: auto 1fr;
		grid-gap: 15px;
		align-items: center;
	}

	.input-field {
		background-color: #f8f8f8;
		padding: 10px;
		border: 1px solid #ddd;
		border-radius: 4px;
		font-size: 14px;
	}

	.button-container {
		display: flex;
		flex-direction: column;
		gap: 15px;
		margin-top: 20px;
	}

	.settings-btn {
		height: 50px;
		font-size: 16px;
		border-radius: 8px;
		border: none;
		color: white;
		font-weight: 500;
		background-color: #17a2b8;
	}
</style>

<script>
var NECallKit = uni.requireNativePlugin("netease-CallKit")

export default {
	data() {
		return {
			rtcChannelName: "",
            ainsMode: -1,
            ainsOptions: [
                { label: '不设置', value: -1 },
                { label: '关闭', value: 0 },
                { label: '开启（正常模式）', value: 1 },
                { label: '开启（加强模式）', value: 2 }
            ],
            ainsIndex: 0,
			needPush: false,
			pushContent: "",
			pushPayload: ""
		};
	},
	onShow() {
		const app = getApp();
		const saved = (app && app.globalData && app.globalData.multiCallSettings) || {};
        this.rtcChannelName = saved.rtcChannelName || "";
        this.ainsMode = Number((saved.ainsMode !== undefined ? saved.ainsMode : -1));
        // 同步 picker 索引
        const idx = this.ainsOptions.findIndex(o => o.value === this.ainsMode);
        this.ainsIndex = idx >= 0 ? idx : 1;
		this.needPush = typeof saved.needPush === 'boolean' ? saved.needPush : false;
		this.pushContent = saved.pushContent || "";
		this.pushPayload = saved.pushPayload || "";
	},
	methods: {
		saveSettings() {
			const app = getApp();
			if (!app.globalData) app.globalData = {};
            app.globalData.multiCallSettings = {
				rtcChannelName: this.rtcChannelName,
                ainsMode: Number(this.ainsMode),
				needPush: this.needPush,
				pushContent: this.pushContent,
				pushPayload: this.pushPayload
			};
			uni.showToast({ title: '已保存', icon: 'success' });
		},
        onAINSPickerChange(e) {
            const index = Number(e && e.detail && e.detail.value);
            this.ainsIndex = isNaN(index) ? this.ainsIndex : index;
            const val = this.ainsOptions[this.ainsIndex]?.value ?? -1;
            this.ainsMode = Number(val);
            console.log('AINS picker -> index:', this.ainsIndex, 'val:', this.ainsMode);
			const app = getApp();
			if (!app.globalData) app.globalData = {};
			if (!app.globalData.multiCallSettings) app.globalData.multiCallSettings = {};
			app.globalData.multiCallSettings.ainsMode = val;
            // 仅保存，不触发原生设置
		},
		onToggleNeedPush(e) {
			const checked = !!(e && e.detail && e.detail.value);
			this.needPush = checked;
			const app = getApp();
			if (!app.globalData) app.globalData = {};
			if (!app.globalData.multiCallSettings) app.globalData.multiCallSettings = {};
			app.globalData.multiCallSettings.needPush = checked;
		}
	}
}
</script>


