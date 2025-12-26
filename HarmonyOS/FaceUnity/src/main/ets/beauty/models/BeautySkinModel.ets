import { FUDevicePerformanceLevel, FUBeautySkin, modelValueType } from '../BeautyConstants'

export class BeautySkinModel {
  name: string = '';
  imeName: string = '';
  type: FUBeautySkin = FUBeautySkin.BlurLevel;
  currentValue: number = 0.0;
  defaultValue: number = 0.0;
  defaultValueInMiddle: boolean = false;
  ratio: number = 0.0;
  performanceLevel: FUDevicePerformanceLevel = FUDevicePerformanceLevel.Low_1;

  constructor(data: Record<string, modelValueType>) {
    this.name = data['name'] as string;
    this.imeName = data['imeName'] as string;
    this.type = data['type'] as FUBeautySkin;
    this.currentValue = data['currentValue'] as number;
    this.defaultValue = data['defaultValue'] as number;
    this.defaultValueInMiddle = data['defaultValueInMiddle'] as boolean;
    this.ratio = data['ratio'] as number;
    this.performanceLevel = data['performanceLevel'] as FUDevicePerformanceLevel;
  }
}