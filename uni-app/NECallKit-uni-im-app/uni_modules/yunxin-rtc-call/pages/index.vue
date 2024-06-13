<template>
	<div>
		<div>
			<div class="form-grid">
				<label for="appkey">云信AppKey：</label>
				<input type="text" id="appkey" v-model="appkey" class="input-field">
				<label for="account">账号(uni-id)：</label>
				<input type="text" id="account" v-model="currentAccount" class="input-field">
				<label for="token">token(uni-token)：</label>
				<input type="text" id="token" v-model="currentToken" class="input-field">
				<label for="calledAccount">被呼账号(uni-id)：</label>
				<input type="text" id="calledAccount" v-model="calledAccount" class="input-field">
				
			</div>
			<!-- 按钮和其他元素 -->
		</div>

		<button type="primary" @click="initConfig">初始化</button>
		<button type="primary" @click="registerAndLogin">登录</button>
		<button type="primary" @click="toAudioCall">语音呼叫</button>
		<button type="primary" @click="toVideoCall">视频呼叫</button>
		<button type="primary" @click="logout">登出</button>
	</div>
</template>

<style scoped>
.form-grid {
    display: grid;
    grid-template-columns: auto 1fr; /* 标签宽度自适应，输入框占据剩余空间 */
    grid-gap: 10px; /* 标签和输入框之间的间距 */
    align-items: center; /* 垂直居中对齐 */
}

.input-field {
    background-color: #f0f0f0;
    padding: 5px;
    border: none;
    border-radius: 4px;
}
</style>

<script>
	import { loginCall,initCall,toCallPage,logoutCall } from "@/uni_modules/netease-callkitx";
	export default {
		data() {
			return {
				appkey: "", // Add data property for App Key
				currentAccount: "", // Initialize with empty values
				currentToken: "" ,// Initialize with empty values
				calledAccount: "",
			};
		},
		onLoad() {
	
		},
		methods: {
			initConfig() {
				console.log('initConfig appkey = ', this.appkey)
				initCall({appKey:this.appkey,}, (result) =>  {
					console.log('callKit init method result: ' + result['code'])
					if(result['code'] == 200){
						uni.showToast({
							title: 'init success',
							icon: "none"
						})
					} else {
						uni.showToast({
							title: 'init failed code = ' + result['code'] + ', msg = ' + result['message'],
							icon: "none"
						})
					}
	
				})
			},
	
			registerAndLogin: function(){
				console.log('registerAndLogin account = ' + this.currentAccount + ", token = " + this.currentToken)
	
				let co1 = uniCloud.importObject("co1")
				co1.registerYunxinAccount(this.currentAccount, this.currentToken).then( res => {
					console.log('registYunxin res = ' , res);
					if (res['code'] == 200) {
					    loginCall({ account: this.currentAccount, token: this.currentToken }, (result) => {
							console.log('loginCall method result: ' + result['code']);
					        if (result['code'] == 200) {
					            uni.showToast({
					                title: 'login success',
					                icon: "none"
					            });
					        } else {
					            uni.showToast({
					                title: 'login failed code = ' + result['code'],
					                icon: "none"
					            });
					        }
					    });
					} else {
						co1.refreshYunxinToken(this.currentAccount, this.currentToken).then( res => {
							console.log('refreshYunxinToken res = ' , res);
							if (res['code'] == 200) {
							    loginCall({ account: this.currentAccount, token: this.currentToken }, (result) => {
							        console.log('loginCall method result: ' + result['code']);
							        if (result['code'] == 200) {
							            uni.showToast({
							                title: 'login success',
							                icon: "none"
							            });
							        } else {
							            uni.showToast({
							                title: 'login failed code = ' + result['code'],
							                icon: "none"
							            });
							        }
							    });
							}
						});
					}
	
				})
			},
	
			toAudioCall: function(){
				console.log('toAudioCall method  ')
				toCallPage({calledAccount: this.calledAccount, type:1}, (result) =>  {
					console.log('callKit toAudioCall method result: ' + result['code'])
					if(result['code'] == 200){
						uni.showToast({
							title: 'toAudioCall success',
							icon: "none"
						})
					} else {
						uni.showToast({
							title: 'toAudioCall failed code = ' + result['code'] + ', message = ' + result['message'],
							icon: "none"
						})
					}
	
				})
				console.log('toCallPage end')
			},
	
			toVideoCall: function(){
				console.log('toVideoCall method')
				toCallPage({calledAccount: this.calledAccount, type:2}, (result) =>  {
					console.log('toVideoCall result: ' + result['code'])
					if(result['code'] == 200){
						uni.showToast({
							title: 'toVideoCall success',
							icon: "none"
						})
					} else {
						uni.showToast({
							title: 'toVideoCall failed code = ' + result['code'] + ', message = ' + result['message'],
							icon: "none"
						})
					}
				})
				console.log('toCallPage end')
			},
	
			logout: function(){
				console.log('logoutCall method  ')
				logoutCall((result) =>  {
					console.log('logout method result: ' + result['code'])
					if(result['code'] == 200){
						uni.showToast({
							title: 'logout success',
							icon: "none"
						})
					} else {
						uni.showToast({
							title: 'logout failed code = ' + result['code'] + ', message = ' + result['message'],
							icon: "none"
						})
					}
				})
				console.log('logoutCall end')
			}
	
		}
	}

</script>
