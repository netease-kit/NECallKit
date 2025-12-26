import { modelValueType } from '../BeautyConstants'

export class BeautyFilterModel {
  filterName: string = '';
  filterIndex: number = 0;
  filterLevel: number = 0.0;

  constructor(data: Record<string, modelValueType>) {
    this.filterName = data['filterName'] as string;
    this.filterIndex = data['filterIndex'] as number;
    this.filterLevel = data['filterLevel'] as number;
  }
}