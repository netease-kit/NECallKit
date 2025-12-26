import { BeautySkinViewModel } from '../viewModels/BeautySkinViewModel';
import { BeautyShapeViewModel } from '../viewModels/BeautyShapeViewModel'
import { BeautyFilterViewModel } from '../viewModels/BeautyFilterViewModel'
import { VideoFuRender } from 'libfaceunity.so';

export class BeautyDataService {
  skinViewModel = new BeautySkinViewModel();
  shapeViewModel = new BeautyShapeViewModel();
  filterViewModel = new BeautyFilterViewModel();

  private static instance: BeautyDataService | undefined = undefined;

  private constructor() {
  }

  registerFuRender(fuRender: VideoFuRender) {
    if (fuRender) {
      this.skinViewModel.setFuRender(fuRender)
      this.shapeViewModel.setFuRender(fuRender)
      this.filterViewModel.setFuRender(fuRender)
    }
  }

  static sharedInstance(): BeautyDataService {
    if (!BeautyDataService.instance) {
      BeautyDataService.instance = new BeautyDataService();
    }
    return BeautyDataService.instance;
  }

  static destroy() {
    BeautyDataService.instance = undefined;
  }
}