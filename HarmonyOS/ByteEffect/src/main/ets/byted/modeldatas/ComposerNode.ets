
@Observed
export  class ComposerNode {
  public path : string = ""
  public keyArray : string[] = [];
  public tag : string = ""
  public intensityArray : number[] = [];

  constructor(path:string, key?:string | string[], intensity?: number | number[], tag?: string) {
    this.path = path;
    if (key) {
      if (typeof key === 'string') {
        this.keyArray = [key]
      } else {
        this.keyArray = key
      }
    }

    if (intensity != null && intensity != undefined) {
      if (typeof intensity === 'number') {
        this.intensityArray = [intensity]
      } else {
        this.intensityArray = intensity
      }
    }

    if (tag) {
      this.tag = tag
    }
  }
}