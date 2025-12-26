import { FUDevicePerformanceLevel, FUBeautyShape, modelValueType } from '../BeautyConstants'

export class BeautyShapeModel {
  name: string = '';
  imeName: string = '';
  type: FUBeautyShape = FUBeautyShape.CheekThinning;
  currentValue: number = 0.0;
  defaultValue: number = 0.0;
  defaultValueInMiddle: boolean = false;
  performanceLevel: FUDevicePerformanceLevel = FUDevicePerformanceLevel.Low_1;

  constructor(data: Record<string, modelValueType>) {
    this.name = data['name'] as string;
    this.imeName = data['imeName'] as string;
    this.type = data['type'] as FUBeautyShape;
    this.currentValue = data['currentValue'] as number;
    this.defaultValue = data['defaultValue'] as number;
    this.defaultValueInMiddle = data['defaultValueInMiddle'] as boolean;
    this.performanceLevel = data['performanceLevel'] as FUDevicePerformanceLevel;
  }
}