export class BytedRender {
  setBundlePath(path: string, licbag: string);
  enableBeauty(enable: boolean);
  getNativeHandle(): bigint;
  setComposerNodes(nodePaths: Array<string>);
  updateComposerNode(nodePath: string, nodeTag: string, value: number);
}
