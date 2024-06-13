// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NEReportConstans_h
#define NEReportConstans_h

#define URL_REPORT @"https://statistic.live.126.net/statics/report/xkit/action"
#define URL_REPORT_V2 @"https://statistic.live.126.net/statics/report/common/form"

// ----------- report key start ----------

#define KEY_APP_KEY @"appKey"

#define KEY_COMPONENT @"component"

#define KEY_VERSION @"version"

#define KEY_PLATFORM @"platform"

#define KEY_TIMESTAMP @"timeStamp"

#define KEY_NERTC_VERSION @"nertcVersion"

#define KEY_IM_VERSION @"imVersion"

#define KEY_REPORT_TYPE @"reportType"

#define KEY_DATA @"data"

#define KEY_EXTRA @"extra"

#define KEY_PV_EVENT_NAME @"eventName"
#define KEY_PV_PAGE @"page"
#define KEY_PV_PRE_PAGE @"prePage"
#define KEY_PV_ACCID @"accid"
#define KEY_PV_USER @"user"

#define KEY_UV_PAGE @"page"
#define KEY_UV_USER @"user"

#define KEY_CODE @"code"
#define KEY_MSG @"message"
#define KEY_COST_TIME @"costTime"
#define KEY_RESPONSE @"response"

#define KEY_API @"api"
#define KEY_API_NAME @"methodName"
#define KEY_API_EXTENSION @"extension"
#define KEY_API_ID_1 @"id1"
#define KEY_API_ID_2 @"id2"

#define KEY_API_CALLBACK @"apiCallback"

#define KEY_CALL_BACK @"callback"

#define KEY_EVENT_USER @"user"

#define KEY_EVENT_RESULT @"result"

#define KEY_EVENT_PARAM @"params"

#define KEY_EVENT_TAG @"tag"

#define KEY_EVENT_REQUEST_ID @"requestId"

#define KEY_EVENT_START_TIME @"startTime"
#define KEY_EVENT_END_TIME @"endTime"
#define KEY_EVENT_DURATION @"duration"

#define KEY_DEVICE_ID @"deviceId"
#define KEY_DEVICE_MODEL @"model"
#define KEY_DEVICE_MANUFACTURER @"manufacturer"
#define KEY_OS_VERSION @"osVer"
#define KEY_APP_NAME @"appName"
#define KEY_APP_VERSION @"appVer"
#define KEY_PACKAGE_ID @"packageId"
#define KEY_FRAMEWORK @"framework"
#define KEY_CHANNEL @"channel"
#define KEY_USER_ID @"userId"
#define KEY_NETWORK_TYPE @"networkType"
// ----------- report key end ----------

// ----------- report type start -------

#define REPORT_TYPE_INIT @"init"

#define REPORT_TYPE_PV @"pv"

#define REPORT_TYPE_UV @"uv"

#define REPORT_TYPE_EVENT_API @"apiEvent"

#define REPORT_TYPE_EVENT_CALLBACK @"callbackEvent"

#define REPORT_TYPE_EVENT_COMMON @"commonEvent"
// ----------- report type end ---------

// --------- platform type start -------

#define PLATFORM_iOS @"iOS"

// --------- platform type end ---------

#endif /* NEReportConstans_h */
