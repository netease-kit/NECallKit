// TODO: 待修改
/// 设备性能等级
export enum FUDevicePerformanceLevel {
  Low_1 = -1, // iPhone6、iPhone6Plus及以下机型
  Low = 1, // iPhone6Plus以上和iPhone8以下机型
  High = 2, // iPhone8及以上和iPhoneXR以下机型
  VeryHigh = 3, // iPhoneXR
  Excellent = 4 // iPhoneXR以上机型
}

export enum FUBeautyCategory {
  None = -1,
  Skin = 0, //美肤
  Shape = 1, //美型
  Filter = 2 //滤镜
}

export enum FUBeautySkin {
  BlurLevel = 0,
  ColorLevel,
  RedLevel,
  Sharpen,
  FaceThreed,
  EyeBright,
  ToothWhiten,
  RemovePouchStrength,
  RemoveNasolabialFoldsStrength,
  AntiAcneSpot,
  Clarity
}

export enum FUBeautyShape {
  CheekThinning = 0,
  CheekV,
  CheekNarrow,
  CheekShort,
  CheekSmall,
  Cheekbones,
  LowerJaw,
  EyeEnlarging,
  EyeCircle,
  Chin,
  Forehead,
  Nose,
  Mouth,
  LipThick,
  EyeHeight,
  Canthus,
  EyeLid,
  EyeSpace,
  EyeRotate,
  LongNose,
  Philtrum,
  Smile,
  BrowHeight,
  BrowSpace,
  BrowThick
}

export type modelValueType = string | number | boolean;

export const SELECTCOLOR = '#5EC7FE'