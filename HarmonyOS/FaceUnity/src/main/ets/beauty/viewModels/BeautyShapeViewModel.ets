import { FUBeautyShape, modelValueType } from '../BeautyConstants';
import { BeautyShapeModel } from '../models/BeautyShapeModel'
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { VideoFuRender } from '../../../../../Index';

const TAG: string = '[BeautyShapeViewModel]';

export class BeautyShapeViewModel {
  dataArray: BeautyShapeModel[] = [];
  fuRender: VideoFuRender|null = null

  constructor() {
    let str: string | null = null;
    const sbPath = getContext().filesDir + "/beauty/beauty_shape.json"

    if (fs.accessSync(sbPath)) {
      str = fs.readTextSync(sbPath)
    } else {
      let input = getContext().resourceManager.getRawFileContentSync("beauty/beauty_shape.json")
      const decoder = new util.TextDecoder()
      str = decoder.decodeToString(input)
    }

    if (str) {
      let maps: Record<string, modelValueType>[] = [];
      try {
        maps = JSON.parse(str);
      } catch (err) {
        console.error(TAG, `Json.parse fail, ${JSON.stringify(err)}`)
        fs.unlinkSync(sbPath)

        let input = getContext().resourceManager.getRawFileContentSync("beauty/beauty_shape.json")
        const decoder = new util.TextDecoder()
        str = decoder.decodeToString(input)
        if (str) {
          maps = JSON.parse(str)
        }
      }

      for (const map of maps) {
        const model = new BeautyShapeModel(map);
        this.dataArray.push(model);
      }
    }
  }

  setFuRender(render: VideoFuRender) {
    this.fuRender = render
  }

  saveShapeDataPersistently() {
    const str = JSON.stringify(this.dataArray);
    const sbPath = getContext().filesDir + "/beauty/beauty_shape.json"
    let file = fs.openSync(sbPath, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE)
    let len = fs.writeSync(file.fd, str)
    console.info('write str into beauty_filter.json sandbox len:' + len)
    fs.closeSync(file)
  }

  /// 设置单项美型值
  /// @param value 当前选中单项的值
  setShapeValue(model: BeautyShapeModel, value: number) {
    model.currentValue = value;
    this.setValue(model.currentValue, model.type);
  }

  /// 设置当前所有美型值
  setAllShapeValues() {
    for (const model of this.dataArray) {
      this.setValue(model.currentValue, model.type);
    }
  }

  /// 恢复所有美型值为默认
  recoverAllShapeValuesToDefault() {
    for (const model of this.dataArray) {
      model.currentValue = model.defaultValue;
      this.setValue(model.currentValue, model.type);
    }
  }

  private setValue(value: number, type: FUBeautyShape): void {
    let key: string = '';
    switch (type) {
      case FUBeautyShape.CheekThinning: key = 'cheek_thinning'; break; //瘦脸 取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
      case FUBeautyShape.CheekV: key = 'cheek_v'; break; //V脸 取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.5
      case FUBeautyShape.CheekNarrow: key = 'cheek_narrow'; break; //窄脸 取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
      case FUBeautyShape.CheekShort: key = 'cheek_short'; break; //短脸  取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
      case FUBeautyShape.CheekSmall: key = 'cheek_small'; break;  //小脸  取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
      case FUBeautyShape.Cheekbones: key = 'intensity_cheekbones'; break; //瘦颧骨 取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
      case FUBeautyShape.LowerJaw: key = 'intensity_lower_jaw'; break; //瘦下颌骨 取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
      case FUBeautyShape.EyeEnlarging: key = 'eye_enlarging'; break; //大眼 取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
      case FUBeautyShape.EyeCircle: key = 'intensity_eye_circle'; break; //圆眼 取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
      case FUBeautyShape.Chin: key = 'intensity_chin'; break; //下巴  取值范围 0.0-1.0，0.5-0.0是变小，0.5-1.0是变大 默认0.3
      case FUBeautyShape.Forehead: key = 'intensity_forehead'; break; //额头 取值范围 0.0-1.0，0.5-0.0是变小，0.5-1.0是变大 默认0.3
      case FUBeautyShape.Nose: key = 'intensity_nose'; break; //瘦鼻 取值范围  0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.5
      case FUBeautyShape.Mouth: key = 'intensity_mouth'; break; //嘴型 取值范围 0.0-1.0，0.5-0.0是变大，0.5-1.0是变小 默认0.4
      case FUBeautyShape.LipThick: key = 'intensity_lip_thick'; break; //嘴型厚度 取值范围 0.0-1.0，0.5-0.0是变大，0.5-1.0是变小 默认0.5
      case FUBeautyShape.EyeHeight: key = 'intensity_eye_height'; break; //眼睛位置 取值范围 0.0-1.0，0.5-0.0是变小，0.5-1.0是变大 默认0.5
      case FUBeautyShape.Canthus: key = 'intensity_canthus'; break; //开眼角 取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
      case FUBeautyShape.EyeLid: key = 'intensity_eye_lid'; break; //眼睑下至 取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
      case FUBeautyShape.EyeSpace: key = 'intensity_eye_space'; break; //眼距 取值范围 0.0-1.0，0.5-0.0是变大，0.5-1.0是变小 默认0.5
      case FUBeautyShape.EyeRotate: key = 'intensity_eye_rotate'; break; //眼睛角度 取值范围 0.0-1.0，0.5-0.0是变大，0.5-1.0是变小 默认0.5
      case FUBeautyShape.LongNose: key = 'intensity_long_nose'; break; //长鼻 取值范围 0.0-1.0，0.5-0.0是变大，0.5-1.0是变小 默认0.5
      case FUBeautyShape.Philtrum: key = 'intensity_philtrum'; break; //缩人中  取值范围 0.0-1.0，0.5-0.0是变大，0.5-1.0是变小 默认0.5
      case FUBeautyShape.Smile: key = 'intensity_smile'; break; //微笑嘴角 取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
      case FUBeautyShape.BrowHeight: key = 'intensity_brow_height'; break; //眉毛上下 取值范围 0.0-1.0，0.5-0.0是变大，0.5-1.0是变小 默认0.5
      case FUBeautyShape.BrowSpace: key = 'intensity_brow_space'; break; //眉间距 取值范围 0.0-1.0，0.5-0.0是变大，0.5-1.0是变小 默认0.5
      case FUBeautyShape.BrowThick: key = 'intensity_brow_thick'; break; //眉毛粗细 取值范围 0.0-1.0，0.5-0.0是变大，0.5-1.0是变小 默认0.5
    }
    if (key == '') return;
    this.fuRender?.setBeautyParam(key,value)
  }
}