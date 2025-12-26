import { BeautyFilterModel } from '../models/BeautyFilterModel'
import { modelValueType } from '../BeautyConstants';
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { VideoFuRender } from 'libfaceunity.so';

const TAG: string = '[BeautyFilterViewModel]';

export class BeautyFilterViewModel {
  dataArray: BeautyFilterModel[] = [];
  currentModel: BeautyFilterModel | undefined = undefined;
  fuRender: VideoFuRender|null = null

  constructor() {
    let str: string | null = null;
    const sbPath = getContext().filesDir + "/beauty/beauty_filter.json"
    if (fs.accessSync(sbPath)) {
      str = fs.readTextSync(sbPath)
    } else {
      let input = getContext().resourceManager.getRawFileContentSync("beauty/beauty_filter.json")
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

        let input = getContext().resourceManager.getRawFileContentSync("beauty/beauty_filter.json")
        const decoder = new util.TextDecoder()
        str = decoder.decodeToString(input)
        if (str) {
          maps = JSON.parse(str)
        }
      }

      for (const map of maps) {
        const model = new BeautyFilterModel(map);
        this.dataArray.push(model);
      }
      this.currentModel = this.dataArray[0];
    }
  }

  setFuRender(render: VideoFuRender) {
    this.fuRender = render
  }

  saveFilterDataPersistently() {
    const str = JSON.stringify(this.dataArray)
    const sbPath = getContext().filesDir + "/beauty/beauty_filter.json"
    let file = fs.openSync(sbPath, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE)
    let len = fs.writeSync(file.fd, str)
    console.info('write str into beauty_filter.json sandbox len:' + len)
    fs.closeSync(file)
  }

  /// 设置单项滤镜值
  /// @param value 当前选中单项的值
  setFilterValue(model: BeautyFilterModel, value: number) {
    this.currentModel = model;
    model.filterLevel = value;
    this.setFilter(model.filterLevel, model.filterName);
  }

  /// 设置当前滤镜
  setCurrentFilter() {
    if (this.currentModel) {
      this.setFilter(this.currentModel.filterLevel, this.currentModel.filterName);
    } else {
      console.error('currentModel is empty when BeautyFilterViewModel sets setCurrentFilter')
    }
  }

  private setFilter(level: number, filterName: string): void {
    if (filterName == '') return;
    this.fuRender?.setFilterParam(filterName, level)
  }
}