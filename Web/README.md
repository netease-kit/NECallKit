# 网易云信 呼叫组件 demo
> 本文将介绍如何快速体验音视频通话功能，您将在10分钟内完成以下关键步骤，并最终获得一个具有1V1通话界面的视频通话功能。

# 功能开通

**1. 申请 AppKey**

用户在使用本插件之前需要获取AppKey，AppKey 申请的具体流程请参见 [创建应用并获取AppKey](https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console)。

**2. 获取账号**

本插件使用中需要 account 和 token，具体请参见 [注册云信IM账号](https://doc.yunxin.163.com/messaging-uikit/docs/Dc0NjI1MTA?platform=android#4-%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7)。


**3. 开通服务**

使用音视频呼叫（呼叫组件）之前，需要开通部分能力，开通的具体流程请参见 [开通服务](https://doc.yunxin.163.com/nertccallkit/docs/DIzMzA0Nzk?platform=iOS)。

# 环境准备

- 安装nodejs、npm

# 如何使用

## 1. 替换appKey

在src/pages/index.tsx文件中替换appKey:

```javascript
const appKey = "your appkey";
```

## 2. 安装依赖

```bash
npm install 
```

## 3. 运行

```bash
npm run dev
```