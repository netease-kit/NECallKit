import { FUBeautySkin, modelValueType } from '../BeautyConstants';
import { BeautySkinModel } from '../models/BeautySkinModel'
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { VideoFuRender } from '../../../../../Index';

const TAG: string = '[BeautySkinViewModel]';

export class BeautySkinViewModel {
  dataArray: BeautySkinModel[] = [];
  fuRender: VideoFuRender|null = null

  constructor() {
    let str: string | null = null;
    const sbPath = getContext().filesDir + "/beauty/beauty_skin.json"
    if (fs.accessSync(sbPath)) {
      str = fs.readTextSync(sbPath)
    } else {
      let input = getContext().resourceManager.getRawFileContentSync("beauty/beauty_skin.json")
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

        let input = getContext().resourceManager.getRawFileContentSync("beauty/beauty_skin.json")
        const decoder = new util.TextDecoder()
        str = decoder.decodeToString(input)
        if (str) {
          maps = JSON.parse(str)
        }
      }

      for (const map of maps) {
        const model = new BeautySkinModel(map);
        this.dataArray.push(model);
      }
    }
  }

  setFuRender(render: VideoFuRender) {
    this.fuRender = render
  }

  saveSkinDataPersistently() {
    const str = JSON.stringify(this.dataArray);
    const sbPath = getContext().filesDir + "/beauty/beauty_skin.json"
    let file = fs.openSync(sbPath, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE)
    let len = fs.writeSync(file.fd, str)
    console.info('write str into beauty_filter.json sandbox len:' + len)
    fs.closeSync(file)
  }

  /// 设置单项美肤值
  /// @param value 当前选中单项的值
  setSkinValue(model: BeautySkinModel, value: number) {
    model.currentValue = value * model.ratio;
    this.setValue(model.currentValue, model.type);
  }

  /// 设置当前所有美肤值
  setAllSkinValues() {
    for (const model of this.dataArray) {
      this.setValue(model.currentValue, model.type);
    }
  }

  /// 恢复所有美肤值为默认
  recoverAllSkinValuesToDefault() {
    for (const model of this.dataArray) {
      model.currentValue = model.defaultValue;
      this.setValue(model.currentValue, model.type);
    }
  }

  private setValue(value: number, type: FUBeautySkin): void {
    let key: string = ''
    switch (type) {
      case FUBeautySkin.BlurLevel:  key = 'blur_level'; break; //磨皮程度 取值范围0.0-6.0，默认6.0
      case FUBeautySkin.ColorLevel: key = 'color_level'; break; //美白 取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.3
      case FUBeautySkin.RedLevel: key = 'red_level'; break; //红润  取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.3
      case FUBeautySkin.Sharpen: key = 'sharpen'; break; //锐化程度 取值范围0.0-1.0，默认0.2
      case FUBeautySkin.FaceThreed: key = 'face_threed'; break; //五官立体功能 取值范围0.0-1.0，默认0
      case FUBeautySkin.EyeBright: key = 'eye_bright'; break; //亮眼 取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
      case FUBeautySkin.ToothWhiten: key = 'tooth_whiten'; break; //美牙 取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
      case FUBeautySkin.RemovePouchStrength: key = 'remove_pouch_strength'; break; //去黑眼圈 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
      case FUBeautySkin.RemoveNasolabialFoldsStrength: key = 'remove_nasolabial_folds_strength'; break; //去法令纹 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
      case FUBeautySkin.AntiAcneSpot: break; // Don't know.
      case FUBeautySkin.Clarity: key = 'clarity'; break; //清晰 取值范围 0.0-1.0,0.0为无效果，1.0为最大效果，默认值0.0
    }
    if (key == '') return;
    this.fuRender?.setBeautyParam(key, value)
  }
}
