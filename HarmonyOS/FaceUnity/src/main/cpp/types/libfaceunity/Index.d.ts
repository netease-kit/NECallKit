export class VideoFuRender {
  enableBeauty(enable: boolean);
  setBundlePath(path: string);
  getNativeHandle(): bigint;
  setBeautyParam(key: string, value: number);
  setFilterParam(filter_name: string, filter_level: number);
}