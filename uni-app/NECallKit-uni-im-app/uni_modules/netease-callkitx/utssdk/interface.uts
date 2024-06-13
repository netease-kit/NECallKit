/**
 * interface.uts
 * uts插件接口定义文件，按规范定义接口文件可以在HBuilderX中更好的做到语法提示
 */

/**
 * myApi 异步函数的参数，在type里定义函数需要的参数以及api成功、失败的相关回调函数。
 */
export type MyApiOptions = {
  paramA : boolean
  success ?: (res : MyApiResult) => void
  fail ?: (res : MyApiFail) => void
  complete ?: (res : any) => void
}

/**
 * 函数返回结果
 * 可以是void, 基本数据类型，自定义type, 或者其他类型。
 * [可选实现]
 */
export type MyApiResult = {
  fieldA : number,
  fieldB : boolean,
  fieldC : string
}

/**
 * 错误码
 * 根据uni错误码规范要求，建议错误码以90开头，以下是错误码示例：
 * - 9010001 错误信息1
 * - 9010002 错误信息2
 */
export type MyApiErrorCode = 9010001 | 9010002;
/**
 * myApi 的错误回调参数
 */
export interface MyApiFail extends IUniError {
  errCode : MyApiErrorCode
};

/* 异步函数定义 */
export type MyApi = (options : MyApiOptions) => void

/* 同步函数定义 */
export type MyApiSync = (paramA : boolean) => MyApiResult