// 引入 sha1 库
// const sha1 = require('sha1');

const createConfig = require('uni-config-center')
const shareConfig = createConfig({ // 获取配置实例
    pluginId: 'share-config' // common/uni-config-center下的插件配置目录名
})
'use strict';
const {
	randString,
	generateCheckSum
} = require('utils')

module.exports = {
    _before() {
        // 通用预处理器
    },

    /**
     * method1方法描述
     * @param {string} param1 参数1描述
     * @returns {object} 返回值描述
     */
    method1(param1) {
        // 参数校验，如无参数则不需要
        if (!param1) {
            return {
                errCode: 'PARAM_IS_NULL',
                errMsg: '参数不能为空'
            }
        }
        // 业务逻辑

        // 返回结果
        return {
            param1 //请根据实际需要返回值
        }
    },

    async registerYunxinAccount(accid, token) {
        const url = 'https://api.netease.im/nimserver/user/create.action';
        const appKey = shareConfig.config('appKey'); // 替换为你的AppKey
        const appSecret = shareConfig.config('appSecret'); // 替换为你的appSecret
        const nonce = randString(20); //生成nonce
        const curTime = Math.floor(new Date().getTime() / 1000).toString(); // 获取当前时间
        const checkSum = generateCheckSum(appSecret, nonce, curTime); //计算checkSum

        console.log("registerYunxinAccount appSecret = " + appSecret + ", nonce = " + nonce + ", curTime = " + curTime +
                        ", checkSum = " + checkSum);

        const header = {
            'content-type': 'application/x-www-form-urlencoded',
            'appKey': appKey,
            'nonce': nonce,
            'curTime': curTime,
            'checkSum': checkSum,
        };

        const data = {
            'accid': accid,
            'token': token,
        };

		const response = await uniCloud.httpclient.request(url, {
			method: 'POST',
			headers: header,
			data: data,
			dataType: 'json'
		});
		console.log("register result = " + JSON.stringify(response.data)); // 处理返回的数据
		return response.data
    },
	
	async refreshYunxinToken(accid, token) {
	    const url = 'https://api.netease.im/nimserver/user/update.action';
	    const appKey = shareConfig.config('appKey'); // 替换为你的AppKey
	    const appSecret = shareConfig.config('appSecret'); // 替换为你的appSecret
	    const nonce = randString(20); //生成nonce
	    const curTime = Math.floor(new Date().getTime() / 1000).toString(); // 获取当前时间
	    const checkSum = generateCheckSum(appSecret, nonce, curTime); //计算checkSum
	
	    console.log("refreshYunxinToken appSecret = " + appSecret + ", nonce = " + nonce + ", curTime = " + curTime +
	                    ", checkSum = " + checkSum);
	
	    const header = {
	        'content-type': 'application/x-www-form-urlencoded',
	        'appKey': appKey,
	        'nonce': nonce,
	        'curTime': curTime,
	        'checkSum': checkSum,
	    };
	
	    const data = {
	        'accid': accid,
	        'token': token,
	    };
	
		const response = await uniCloud.httpclient.request(url, {
			method: 'POST',
			headers: header,
			data: data,
			dataType: 'json'
		});
		console.log("register result = " + JSON.stringify(response.data)); // 处理返回的数据
		return response.data
	},
};
