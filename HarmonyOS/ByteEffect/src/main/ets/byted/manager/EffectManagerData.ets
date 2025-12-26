import { EffectButtonItem, Material, ColorItem, FilterButtonItem,
  StickerButtonItem } from '../modeldatas/EffectButtonItem'
import { ArrayList } from '@kit.ArkTS'
import { ComposerNode } from '../modeldatas/ComposerNode'

enum EffectType {
  STANDARD_ASIA = 0,
  LITE_ASIA = 1,
  STANDARD_NOT_ASIA = 2,
  LITE_NOT_ASIA = 3
}

export class EffectManagerData {
  static readonly OFFSET: number                              = 16
  static readonly SUB_OFFSET: number                          = 8
  static readonly MASK: number                                = ~0xFFFF
  static readonly SUB_MASK: number                            = ~0xFF

  static readonly TYPE_CLOSE: number                          = -1
  static readonly TYPE_BEAUTY_SUIT: number                    = 1 << this.OFFSET
  static readonly TYPE_BEAUTY_FACE: number                    = 2 << this.OFFSET
  static readonly TYPE_BEAUTY_RESHAPE: number                 = 3 << this.OFFSET
  static readonly TYPE_BEAUTY_BODY: number                    = 4 << this.OFFSET
  static readonly TYPE_MAKEUP: number                         = 5 << this.OFFSET
  static readonly TYPE_FILTER: number                         = 6 << this.OFFSET
  static readonly TYPE_PALETTE: number                        = 7 << this.OFFSET
  static readonly TYPE_BLACK_TECHNOLOGY: number               = 8 << this.OFFSET
  static readonly TYPE_LIPSTICK: number                       = 9 << this.OFFSET
  static readonly TYPE_HAIR_DYE: number                       = 10 << this.OFFSET
  static readonly TYPE_STYLE_MAKEUP: number                   = 11 << this.OFFSET
  static readonly TYPE_BACK_GROUND: number                    = 12 << this.OFFSET
  static readonly TYPE_STICKER: number                        = 13 << this.OFFSET
  static readonly TYPE_AIGC: number                           = 14 << this.OFFSET

  static readonly TYPE_BEAUTY_SUIT_FACE_DEFAUT: number        = this.TYPE_BEAUTY_SUIT + (1 << this.SUB_OFFSET)
  static readonly TYPE_BEAUTY_SUIT_FACE_JUVENILE: number      = this.TYPE_BEAUTY_SUIT + (2 << this.SUB_OFFSET)
  static readonly TYPE_BEAUTY_SUIT_FACE_ROUND: number         = this.TYPE_BEAUTY_SUIT + (3 << this.SUB_OFFSET)
  static readonly TYPE_BEAUTY_SUIT_FACE_SQUARE: number        = this.TYPE_BEAUTY_SUIT + (4 << this.SUB_OFFSET)
  static readonly TYPE_BEAUTY_SUIT_FACE_LONG: number          = this.TYPE_BEAUTY_SUIT + (5 << this.SUB_OFFSET)

  //TYPE_BEAUTY_FACE
  static readonly TYPE_BEAUTY_FACE_SMOOTH: number             = this.TYPE_BEAUTY_FACE + (1 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_FACE_WHITEN: number             = this.TYPE_BEAUTY_FACE + (2 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_FACE_SHARPEN: number            = this.TYPE_BEAUTY_FACE + (3 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_FACE_CLARITY: number            = this.TYPE_BEAUTY_FACE + (4 << this.SUB_OFFSET);

    //美白
  static readonly TYPE_BEAUTY_FACE_WHITEN_DEFAULT: number     = this.TYPE_BEAUTY_FACE_WHITEN + (11 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_FACE_WHITEN_LENGBAI: number     = this.TYPE_BEAUTY_FACE_WHITEN + (12 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_FACE_WHITEN_FENBAI: number      = this.TYPE_BEAUTY_FACE_WHITEN + (13 << this.SUB_OFFSET);

  //面部
  static readonly TYPE_BEAUTY_RESHAPE_FACE: number            = this.TYPE_BEAUTY_RESHAPE + (1 << this.SUB_OFFSET);// {zh} 面部 {en} Facial
  static readonly TYPE_BEAUTY_RESHAPE_FACE_OVERALL: number    = this.TYPE_BEAUTY_RESHAPE + (2 << this.SUB_OFFSET);// {zh} 瘦脸 {en} Skinny face
  static readonly TYPE_BEAUTY_RESHAPE_FACE_SMALL: number      = this.TYPE_BEAUTY_RESHAPE + (3 << this.SUB_OFFSET);// {zh} 小脸 {en} Little face
  static readonly TYPE_BEAUTY_RESHAPE_FACE_CUT: number        = this.TYPE_BEAUTY_RESHAPE + (4 << this.SUB_OFFSET);// {zh} 窄脸 {en} Narrow face
  static readonly TYPE_BEAUTY_RESHAPE_FACE_V: number          = this.TYPE_BEAUTY_RESHAPE + (5 << this.SUB_OFFSET);// {zh} V脸 {en} V face
  static readonly TYPE_BEAUTY_RESHAPE_FOREHEAD: number        = this.TYPE_BEAUTY_RESHAPE + (6 << this.SUB_OFFSET);// {zh} 额头/发际线 {en} Forehead/hairline
  static readonly TYPE_BEAUTY_RESHAPE_CHEEK: number           = this.TYPE_BEAUTY_RESHAPE + (7 << this.SUB_OFFSET);// {zh} 颧骨 {en} Cheekbones
  static readonly TYPE_BEAUTY_RESHAPE_JAW: number             = this.TYPE_BEAUTY_RESHAPE + (8 << this.SUB_OFFSET);// {zh} 下颌骨 {en} Mandible
  static readonly TYPE_BEAUTY_RESHAPE_CHIN: number            = this.TYPE_BEAUTY_RESHAPE + (9 << this.SUB_OFFSET);// {zh} 下巴 {en} Chin

  static readonly TYPE_BEAUTY_RESHAPE_FACE_OVERALL1: number   = this.TYPE_BEAUTY_RESHAPE + (10 << this.SUB_OFFSET);// {zh} 瘦脸 {en} Skinny face
  static readonly TYPE_BEAUTY_RESHAPE_FACE_OVERALL2: number   = this.TYPE_BEAUTY_RESHAPE + (11 << this.SUB_OFFSET);// {zh} 瘦脸 {en} Skinny face
  static readonly TYPE_BEAUTY_RESHAPE_FACE_OVERALL3: number   = this.TYPE_BEAUTY_RESHAPE + (12 << this.SUB_OFFSET);// {zh} 瘦脸 {en} Skinny face
  static readonly TYPE_BEAUTY_RESHAPE_FACE_OVERALL4: number   = this.TYPE_BEAUTY_RESHAPE + (13 << this.SUB_OFFSET);// {zh} 瘦脸 {en} Skinny face

  //  {zh} 眼睛  {en} Eyes
  static readonly TYPE_BEAUTY_RESHAPE_EYE: number                       = this.TYPE_BEAUTY_RESHAPE + (20 << this.SUB_OFFSET);// {zh} 眼睛 {en} Eyes
  static readonly TYPE_BEAUTY_RESHAPE_EYE_SIZE: number                  = this.TYPE_BEAUTY_RESHAPE + (21 << this.SUB_OFFSET);// {zh} 大眼 {en} Big eyes
  static readonly TYPE_BEAUTY_RESHAPE_EYE_HEIGHT: number                = this.TYPE_BEAUTY_RESHAPE + (22 << this.SUB_OFFSET);// {zh} 眼高度 {en} Eye height
  static readonly TYPE_BEAUTY_RESHAPE_EYE_WIDTH: number                 = this.TYPE_BEAUTY_RESHAPE + (23 << this.SUB_OFFSET);// {zh} 眼宽度 {en} Eye width
  static readonly TYPE_BEAUTY_RESHAPE_EYE_MOVE: number                  = this.TYPE_BEAUTY_RESHAPE + (24 << this.SUB_OFFSET); // {zh} 眼移动/眼位置 {en} Eye movement/eye position
  static readonly TYPE_BEAUTY_RESHAPE_EYE_SPACING: number               = this.TYPE_BEAUTY_RESHAPE + (25 << this.SUB_OFFSET);// {zh} 眼间距 {en} Eye spacing
  static readonly TYPE_BEAUTY_RESHAPE_EYE_LOWER_EYELID: number          = this.TYPE_BEAUTY_RESHAPE + (26 << this.SUB_OFFSET);// {zh} 眼睑下至 {en} Eyelid down to
  static readonly TYPE_BEAUTY_RESHAPE_EYE_PUPIL: number                 = this.TYPE_BEAUTY_RESHAPE + (27 << this.SUB_OFFSET);// {zh} 瞳孔大小 {en} Pupil size
  static readonly TYPE_BEAUTY_RESHAPE_EYE_INNER_CORNER: number          = this.TYPE_BEAUTY_RESHAPE + (28 << this.SUB_OFFSET);// {zh} 内眼角 {en} Inner canthus
  static readonly TYPE_BEAUTY_RESHAPE_EYE_OUTER_CORNER: number          = this.TYPE_BEAUTY_RESHAPE + (28 << this.SUB_OFFSET);// {zh} 外眼角 {en} Outer corner of eye
  static readonly TYPE_BEAUTY_RESHAPE_EYE_ROTATE: number                = this.TYPE_BEAUTY_RESHAPE + (29 << this.SUB_OFFSET);// {zh} 眼角度、眼角上扬 {en} Eye angle, canthus rise

  // {zh} 妆 {en} Makeup
  static readonly TYPE_BEAUTY_RESHAPE_BRIGHTEN_EYE: number              = this.TYPE_BEAUTY_RESHAPE + (35 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_RESHAPE_REMOVE_POUCH: number              = this.TYPE_BEAUTY_RESHAPE + (36 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_RESHAPE_SMILE_FOLDS: number               = this.TYPE_BEAUTY_RESHAPE + (37 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_RESHAPE_WHITEN_TEETH: number              = this.TYPE_BEAUTY_RESHAPE + (38 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_RESHAPE_SINGLE_TO_DOUBLE_EYELID: number   = this.TYPE_BEAUTY_RESHAPE + (39 << this.SUB_OFFSET);

  // {zh} 鼻子 {en} Nose
  static readonly TYPE_BEAUTY_RESHAPE_NOSE: number                      = this.TYPE_BEAUTY_RESHAPE + (40 << this.SUB_OFFSET);// {zh} 鼻子 {en} Nose
  static readonly TYPE_BEAUTY_RESHAPE_NOSE_SIZE: number                 = this.TYPE_BEAUTY_RESHAPE + (41 << this.SUB_OFFSET);// {zh} 鼻子大小/瘦鼻 {en} Nose size/thin nose
  static readonly TYPE_BEAUTY_RESHAPE_NOSE_SWING: number                = this.TYPE_BEAUTY_RESHAPE + (42 << this.SUB_OFFSET);// {zh} 鼻翼 {en} Nose
  static readonly TYPE_BEAUTY_RESHAPE_NOSE_BRIDGE: number               = this.TYPE_BEAUTY_RESHAPE + (43 << this.SUB_OFFSET);// {zh} 鼻梁 {en} Bridge of nose
  static readonly TYPE_BEAUTY_RESHAPE_NOSE_MOVE: number                 = this.TYPE_BEAUTY_RESHAPE + (44 << this.SUB_OFFSET);// {zh} 鼻子提升/长鼻 {en} Nose lift/long nose
  static readonly TYPE_BEAUTY_RESHAPE_NOSE_TIP: number                  = this.TYPE_BEAUTY_RESHAPE + (45 << this.SUB_OFFSET);// {zh} 鼻尖 {en} Nose tip
  static readonly TYPE_BEAUTY_RESHAPE_NOSE_ROOT: number                 = this.TYPE_BEAUTY_RESHAPE + (46 << this.SUB_OFFSET);// {zh} 山根 {en} Yamagata

  //  {zh} 眉毛  {en} Eyebrows
  static readonly TYPE_BEAUTY_RESHAPE_BROW: number             = this.TYPE_BEAUTY_RESHAPE    + (60 << this.SUB_OFFSET); //  {zh} 眉毛  {en} Eyebrows
  static readonly TYPE_BEAUTY_RESHAPE_BROW_SIZE: number         = this.TYPE_BEAUTY_RESHAPE    + (61 << this.SUB_OFFSET);//  {zh} 眉毛粗细  {en} Eyebrow thickness
  static readonly TTYPE_BEAUTY_RESHAPE_BROW_POSITION: number     = this.TYPE_BEAUTY_RESHAPE    + (62 << this.SUB_OFFSET); //  {zh} 眉毛位置  {en} Eyebrow position
  static readonly TYPE_BEAUTY_RESHAPE_BROW_TILT: number         = this.TYPE_BEAUTY_RESHAPE    + (63 << this.SUB_OFFSET); //  {zh} 眉毛倾斜  {en} Tilted eyebrows
  static readonly TYPE_BEAUTY_RESHAPE_BROW_RIDGE: number       = this.TYPE_BEAUTY_RESHAPE    + (64 << this.SUB_OFFSET); //  {zh} 眉峰  {en} Meifeng
  static readonly TYPE_BEAUTY_RESHAPE_BROW_DISTANCE: number     = this.TYPE_BEAUTY_RESHAPE    + (65 << this.SUB_OFFSET);//  {zh} 眉毛间距  {en} Eyebrow spacing
  static readonly TYPE_BEAUTY_RESHAPE_BROW_WIDTH: number        = this.TYPE_BEAUTY_RESHAPE    + (66 << this.SUB_OFFSET);//  {zh} 眉毛宽度  {en} Eyebrow width

  // {zh} 嘴巴 {en} Mouth
  static readonly TYPE_BEAUTY_RESHAPE_MOUTH: number            = this.TYPE_BEAUTY_RESHAPE    + (80 << this.SUB_OFFSET); //  {zh} 嘴巴  {en} Mouth
  static readonly TYPE_BEAUTY_RESHAPE_MOUTH_ZOOM: number        = this.TYPE_BEAUTY_RESHAPE    + (81 << this.SUB_OFFSET);//  {zh} 嘴巴大小/嘴形  {en} Mouth size/shape
  static readonly TYPE_BEAUTY_RESHAPE_MOUTH_WIDTH: number       = this.TYPE_BEAUTY_RESHAPE    + (82 << this.SUB_OFFSET);//  {zh} 嘴巴宽度  {en} Mouth width
  static readonly TYPE_BEAUTY_RESHAPE_MOUTH_MOVE: number        = this.TYPE_BEAUTY_RESHAPE    + (83 << this.SUB_OFFSET);//  {zh} 嘴巴位置/人中  {en} Mouth position/person
  static readonly TYPE_BEAUTY_RESHAPE_MOUTH_SMILE: number       = this.TYPE_BEAUTY_RESHAPE    + (84 << this.SUB_OFFSET);//  {zh} 微笑  {en} Smile

  //   {zh} Beautify body 美体       {en} Beautify the body
  static readonly TYPE_BEAUTY_BODY_THIN: number               = this.TYPE_BEAUTY_BODY + (1 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_BODY_LONG_LEG: number           = this.TYPE_BEAUTY_BODY + (2 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_BODY_SLIM_LEG: number           = this.TYPE_BEAUTY_BODY  + (3 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_BODY_SLIM_WAIST: number         = this.TYPE_BEAUTY_BODY  + (4 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_BODY_ENLARGE_BREAST: number     = this.TYPE_BEAUTY_BODY  + (5 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_BODY_ENHANCE_HIP: number        = this.TYPE_BEAUTY_BODY  + (6 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_BODY_ENHANCE_NECK: number       = this.TYPE_BEAUTY_BODY  + (7 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_BODY_SLIM_ARM: number           = this.TYPE_BEAUTY_BODY  + (8 << this.SUB_OFFSET);
  static readonly TYPE_BEAUTY_BODY_SHRINK_HEAD: number        = this.TYPE_BEAUTY_BODY  + (9 << this.SUB_OFFSET);

  //   {zh} Makeup 美妆       {en} Makeup beauty
  static readonly TYPE_MAKEUP_LIP: number                     = this.TYPE_MAKEUP + (1 << this.SUB_OFFSET);
  static readonly TYPE_MAKEUP_BLUSHER: number                 = this.TYPE_MAKEUP + (2 << this.SUB_OFFSET);
  static readonly TYPE_MAKEUP_EYELASH: number                 = this.TYPE_MAKEUP + (3 << this.SUB_OFFSET);
  static readonly TYPE_MAKEUP_PUPIL: number                   = this.TYPE_MAKEUP + (4 << this.SUB_OFFSET);
  static readonly TYPE_MAKEUP_HAIR: number                    = this.TYPE_MAKEUP + (5 << this.SUB_OFFSET);
  static readonly TYPE_MAKEUP_EYESHADOW: number               = this.TYPE_MAKEUP + (6 << this.SUB_OFFSET);
  static readonly TYPE_MAKEUP_EYEBROW: number                 = this.TYPE_MAKEUP + (7 << this.SUB_OFFSET);
  static readonly TYPE_MAKEUP_FACIAL: number                  = this.TYPE_MAKEUP + (8 << this.SUB_OFFSET);
  static readonly TYPE_MAKEUP_WOCAN: number                   = this.TYPE_MAKEUP + (9 << this.SUB_OFFSET);
  static readonly TYPE_MAKEUP_EYELIGHT: number                = this.TYPE_MAKEUP + (10 << this.SUB_OFFSET);

  //   {zh} 染发       {en} Hair dye
  static readonly TYPE_HAIR_DYE_FULL: number                  = this.TYPE_HAIR_DYE + (1 << this.SUB_OFFSET);
  static readonly TYPE_HAIR_DYE_HIGHLIGHT: number             = this.TYPE_HAIR_DYE + (2 << this.SUB_OFFSET);

  //   {zh} 画质       {en} Palette
  static readonly TYPE_PALETTE_TEMPERATURE: number            = this.TYPE_PALETTE + (1 << this.SUB_OFFSET);
  static readonly TYPE_PALETTE_TONE: number                   = this.TYPE_PALETTE + (2 << this.SUB_OFFSET);
  static readonly TYPE_PALETTE_SATURATION: number             = this.TYPE_PALETTE + (3 << this.SUB_OFFSET);
  static readonly TYPE_PALETTE_BRIGHTNESS: number             = this.TYPE_PALETTE + (4 << this.SUB_OFFSET);
  static readonly TYPE_PALETTE_CONTRAST: number               = this.TYPE_PALETTE + (5 << this.SUB_OFFSET);
  static readonly TYPE_PALETTE_HIGHLIGHT: number              = this.TYPE_PALETTE + (6 << this.SUB_OFFSET);
  static readonly TYPE_PALETTE_SHADOW: number                 = this.TYPE_PALETTE + (7 << this.SUB_OFFSET);
  static readonly TYPE_PALETTE_LIGHT_SENSATION: number        = this.TYPE_PALETTE + (8 << this.SUB_OFFSET);
  static readonly TYPE_PALETTE_PARTICLE: number               = this.TYPE_PALETTE + (9 << this.SUB_OFFSET);
  static readonly TYPE_PALETTE_FADE: number                   = this.TYPE_PALETTE + (10 << this.SUB_OFFSET);
  static readonly TYPE_PALETTE_VIGNETTING: number             = this.TYPE_PALETTE + (11 << this.SUB_OFFSET);

  //   {zh} 黑科技       {en} Technology
  static readonly TYPE_BLACK_TECHNOLOGY_ANTI_ACNE_SPOT_TOB: number = this.TYPE_BLACK_TECHNOLOGY + (1 << this.SUB_OFFSET);
  static readonly TYPE_BLACK_TECHNOLOGY_ANTI_ACNE_SPOT_LOW: number = this.TYPE_BLACK_TECHNOLOGY + (2 << this.SUB_OFFSET);
  static readonly TYPE_BLACK_TECHNOLOGY_YUNFU: number              = this.TYPE_BLACK_TECHNOLOGY + (3 << this.SUB_OFFSET);
  static readonly TYPE_BLACK_TECHNOLOGY_FULING: number             = this.TYPE_BLACK_TECHNOLOGY + (4 << this.SUB_OFFSET);
  static readonly TYPE_BLACK_TECHNOLOGY_LUNKUOPINGHUA: number      = this.TYPE_BLACK_TECHNOLOGY + (5 << this.SUB_OFFSET);

  // static readonly NODE_RESHAPE_LITE_V4: string                = "reshape_lite_eye_size";
  static readonly NODE_BEAUTY_4ITEMS: string                  = "beauty_4Items";
  static readonly NODE_ALL_SLIM: string                       = "body/allslim";
  static readonly NODE_ALL_SLIM_BREAST: string                = "body/allslim_breast";

  private mBeautySuitItems: EffectButtonItem | null = null

  private mBeautyFaceItems: EffectButtonItem | null = null

  private mBeautyReshapeItems: EffectButtonItem | null = null

  private mBeautyBodyItems: EffectButtonItem | null = null

  private mBeautyMakeupItems: EffectButtonItem | null = null

  private mFilterItems: EffectButtonItem | null = null

  private mPaletteItems: EffectButtonItem | null = null

  private mBlackTechnologyItems: EffectButtonItem | null = null

  private mStickerItems: EffectButtonItem | null = null

  private mAIGCStickerItems: EffectButtonItem | null = null

  private mStyleMakeupItems: EffectButtonItem | null = null

  static readonly DEFAULT_STANDARD_VALUE: Map<number, number[]> = new Map([
    [EffectManagerData.TYPE_BEAUTY_FACE_SMOOTH, [0.65]],
    [EffectManagerData.TYPE_BEAUTY_FACE_WHITEN_DEFAULT, [0.35]],
    [EffectManagerData.TYPE_BEAUTY_FACE_SHARPEN, [0.25]],
    [EffectManagerData.TYPE_BEAUTY_FACE_CLARITY, [0.2]],
    [EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_OVERALL, [0.75]],
    [EffectManagerData.TYPE_BEAUTY_RESHAPE_CHEEK, [0.65]],
    [EffectManagerData.TYPE_BEAUTY_RESHAPE_FOREHEAD, [0.7]],
    [EffectManagerData.TYPE_BEAUTY_RESHAPE_SMILE_FOLDS, [0.5]],
    [EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_SIZE, [0.65]],
    [EffectManagerData.TYPE_BEAUTY_RESHAPE_BRIGHTEN_EYE, [0.4]],
    [EffectManagerData.TYPE_BEAUTY_RESHAPE_REMOVE_POUCH, [0.5]],
    [EffectManagerData.TYPE_BEAUTY_RESHAPE_NOSE_SIZE, [0.65]],
    [EffectManagerData.TYPE_BEAUTY_RESHAPE_NOSE_MOVE, [0.6]],
    [EffectManagerData.TYPE_BEAUTY_RESHAPE_MOUTH_ZOOM, [0.6]],
    [EffectManagerData.TYPE_BEAUTY_RESHAPE_MOUTH_MOVE, [0.65]],
    [EffectManagerData.TYPE_BEAUTY_RESHAPE_WHITEN_TEETH, [0.3]],
    [EffectManagerData.TYPE_BEAUTY_BODY_ENHANCE_HIP, [0.5]],
    [EffectManagerData.TYPE_MAKEUP_LIP, [0.5, 0, 0, 0]],
    [EffectManagerData.TYPE_MAKEUP_HAIR, [0.5, 0, 0, 0]],
    [EffectManagerData.TYPE_MAKEUP_BLUSHER, [0.5, 0, 0, 0]],
    [EffectManagerData.TYPE_MAKEUP_FACIAL, [0.5]],
    [EffectManagerData.TYPE_MAKEUP_EYEBROW, [0.3, 0, 0, 0]],
    [EffectManagerData.TYPE_MAKEUP_EYESHADOW, [0.5]],
    [EffectManagerData.TYPE_MAKEUP_PUPIL, [0.5]],
    [EffectManagerData.TYPE_MAKEUP_EYELASH, [0.5, 0, 0, 0]],
    [EffectManagerData.TYPE_MAKEUP_EYELIGHT, [0.5]],
    [EffectManagerData.TYPE_MAKEUP_WOCAN, [0.5]],
    [EffectManagerData.TYPE_STYLE_MAKEUP, [0.8, 0.8]],
    // [EffectManagerData.TYPE_STYLE_MAKEUP_2D, [0.8, 0.8]],
    // [EffectManagerData.TYPE_STYLE_MAKEUP_3D, [0.8, 0.8]],
    [EffectManagerData.TYPE_FILTER, [0.8]],
  ])

  getItemsByType(type: number): EffectButtonItem {
    switch (type)
    {
      case EffectManagerData.TYPE_BEAUTY_SUIT:{
        return this._getBeautySuitItems()
      }
      case EffectManagerData.TYPE_BEAUTY_FACE: {
        return this._getBeautyFaceItems();
      }
      case EffectManagerData.TYPE_BEAUTY_RESHAPE: {
        return this._getBeautyReshapeItems()
      }
      case EffectManagerData.TYPE_BEAUTY_BODY: {
        return this._getBeautyBodyItems()
      }
      case EffectManagerData.TYPE_MAKEUP: {
        return this._getMakeupItems()
      }
      case EffectManagerData.TYPE_FILTER: {
        return this._getFilterItems()
      }
      case EffectManagerData.TYPE_PALETTE: {
        return this._getPaletteItems()
      }
      case EffectManagerData.TYPE_BLACK_TECHNOLOGY: {
        return this._getBlackTechnologyItems()
      }
      case EffectManagerData.TYPE_STICKER: {
        return this._getStickerItems()
      }
      case EffectManagerData.TYPE_AIGC: {
        return this._getAIGCStickerItems()
      }
      case EffectManagerData.TYPE_STYLE_MAKEUP: {
        return this._getStyleMakeupItems()
      }

    }
    return this._getBeautyFaceItems();
  }

  private _getStickerItems(): EffectButtonItem {
    if (this.mStickerItems == null) {
      this.mStickerItems = new EffectButtonItem(EffectManagerData.TYPE_STICKER, new Material('', ''), undefined, false)
      this.mStickerItems.setChildren([
        new StickerButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_luoyesuifeng', '落叶随风'), new ComposerNode("FallLeaves")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_pixelbaby', '像素娃娃'), new ComposerNode("PixelBaby")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_yaoyehuaduo', '摇曳花朵'), new ComposerNode("Swayingflowers")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_chaodatou', '超大头'), new ComposerNode("chaodatou")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_zuanshiyanjing', '钻石眼镜'), new ComposerNode("BaroqueDiamondGlasses")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_huoyanyanjing', '火焰眼镜'), new ComposerNode("FlameSunglasses")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_xingkongranfa', '星空染发'), new ComposerNode("sticker_xingkongranfa")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_jichetoukui', '机车头盔'), new ComposerNode("sticker_jichetoukui")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_fugudv', '复古DV'), new ComposerNode("sticker_fugudv")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_maorongtuer', '毛绒兔耳'), new ComposerNode("RabbitFairy")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_fadaimianmo', '发带面膜'), new ComposerNode("sticker_fadaimianmo")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_heimaoyanjing', '黑猫眼镜'), new ComposerNode("sticker_heimaoyanjing")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_masaikexiaochu', '马赛克消除'), new ComposerNode("MosaictoClear")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_nihongyaobai', '霓虹摇摆'), new ComposerNode("NeonBurst")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_yingguangmiaobian', '荧光描边'), new ComposerNode("lvsemiaobian")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_caoyuanzhuizhu', '草原追逐'), new ComposerNode("EnBykG")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_wennuandengguang', '温暖灯光'), new ComposerNode("DesfoquecomLuzes")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_elongbianshen', '恶龙变身', '张张嘴巴变身恶龙'), new ComposerNode("DragonHead_7116843794607980545")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_shuangamwei', '双马尾'), new ComposerNode("TwinPonytail")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_niuqushijie', '扭曲世界'), new ComposerNode("WarpedWorld")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_linghunchuqiao', '灵魂出窍'), new ComposerNode("linghunchuqiao")),
        new StickerButtonItem(EffectManagerData.TYPE_STICKER, new Material('app.media.ic_sticker_shiguangpubu', '时光瀑布'), new ComposerNode("TimeWarpWaterfall")),
      ])
    }
    return this.mStickerItems;
  }

  private _getAIGCStickerItems(): EffectButtonItem {
    if (this.mAIGCStickerItems == null) {
      this.mAIGCStickerItems = new EffectButtonItem(EffectManagerData.TYPE_STICKER, new Material('', ''), undefined, false)
      this.mAIGCStickerItems.setChildren([
        new StickerButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
        new StickerButtonItem(EffectManagerData.TYPE_AIGC, new Material('app.media.ic_aigc_pingxingyuzhou', '瞬息全宇宙'), new ComposerNode("AI_Universe_labcv_test")),
        new StickerButtonItem(EffectManagerData.TYPE_AIGC, new Material('app.media.ic_aigc_bohemanbo', '薄荷曼波'), new ComposerNode("ai_bohemanbo")),
        new StickerButtonItem(EffectManagerData.TYPE_AIGC, new Material('app.media.ic_aigc_gongqijun', '宫崎骏'), new ComposerNode("ai_gongqijun")),
        new StickerButtonItem(EffectManagerData.TYPE_AIGC, new Material('app.media.ic_aigc_gufenghuajuan', '古风画卷'), new ComposerNode("ai_gufenghuajuan")),
        new StickerButtonItem(EffectManagerData.TYPE_AIGC, new Material('app.media.ic_aigc_monaihuayuan', '莫奈花园'), new ComposerNode("ai_monaihuayuan")),
        new StickerButtonItem(EffectManagerData.TYPE_AIGC, new Material('app.media.ic_aigc_nidemingzi', '你的名字'), new ComposerNode("ai_nidemingzi")),
        // new StickerButtonItem(EffectManagerData.TYPE_AIGC, new Material('app.media.ic_aigc_xianxia', 'AI 仙侠', '点击屏幕触发 AIGC 特效'), new ComposerNode("aiXianxia_labcv_test")),
        new StickerButtonItem(EffectManagerData.TYPE_AIGC, new Material('app.media.ic_aigc_manhua', 'AI 漫画', '点击屏幕触发 AIGC 特效'), new ComposerNode("aiManhua_labcv_test")),
      ])
    }
    return this.mAIGCStickerItems;
  }

  private _getBeautySuitItems(): EffectButtonItem {
    if (this.mBeautySuitItems == null) {
      this.mBeautySuitItems = new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_SUIT, new Material('', ''), undefined, false)
      this.mBeautySuitItems.setChildren([
        new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_SUIT_FACE_DEFAUT, new Material('app.media.ic_beauty_suit_default', '默认'), new ComposerNode("test", "123", 0)),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_SUIT_FACE_JUVENILE, new Material('app.media.ic_beauty_suit_juvenile', '幼态'), new ComposerNode("test", "123", 0)),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_SUIT_FACE_ROUND, new Material('app.media.ic_beauty_suit_round', '圆脸专用'), new ComposerNode("test", "123", 0)),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_SUIT_FACE_LONG, new Material('app.media.ic_beauty_suit_long', '长脸专用'), new ComposerNode("test", "123", 0)),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_SUIT_FACE_SQUARE, new Material('app.media.ic_beauty_suit_square', '方脸专用'), new ComposerNode("test", "123", 0)),
      ])
    }
    return this.mBeautySuitItems;
  }

  private _getBeautyFaceItems(): EffectButtonItem {
    if (this.mBeautyFaceItems == null) {
      let mEffectType = 0
      this.mBeautyFaceItems = new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_FACE, new Material('', ''))
      this.mBeautyFaceItems.setChildren([
        new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_FACE_SMOOTH, new Material('app.media.ic_beauty_smooth', '磨皮'), new ComposerNode("beauty_lite_new", "smooth", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_FACE_SMOOTH, mEffectType))),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_FACE_WHITEN, new Material('app.media.ic_beauty_whiten', '美白'), undefined, false).setChildren(this._getMakeupOptionItems(EffectManagerData.TYPE_BEAUTY_FACE_WHITEN)),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_FACE_SHARPEN, new Material('app.media.ic_beauty_sharpen', '锐化'), new ComposerNode("beauty_lite_new", "sharp", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_FACE_SHARPEN, mEffectType))),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_FACE_CLARITY, new Material('app.media.ic_beauty_clarity', '清晰'), new ComposerNode("beauty_lite_new", "clear", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_FACE_CLARITY, mEffectType)))
      ])
    }
    return this.mBeautyFaceItems
  }

  private  _getBeautyReshapeItems(): EffectButtonItem {
    if (this.mBeautyReshapeItems == null) {
      this.mBeautyReshapeItems = this._getBeautyReshapeItemsStandard()
    }
    return this.mBeautyReshapeItems
  }

  private _getBeautyBodyItems(): EffectButtonItem {
    let mEffectType = 0

    if (this.mBeautyBodyItems == null) {
      this.mBeautyBodyItems = new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_BODY, new Material('', ""))
      this.mBeautyBodyItems.setChildren([
        new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', "关闭")),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_BODY_THIN, new Material('app.media.ic_beauty_body_thin', '瘦身'), new ComposerNode(EffectManagerData.NODE_ALL_SLIM, "BEF_BEAUTY_BODY_THIN", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_BODY_THIN, mEffectType)[0])),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_BODY_LONG_LEG, new Material('app.media.ic_beauty_body_long_leg', '长腿'), new ComposerNode(EffectManagerData.NODE_ALL_SLIM, "BEF_BEAUTY_BODY_LONG_LEG", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_BODY_LONG_LEG, mEffectType)[0])),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_BODY_SLIM_LEG, new Material('app.media.ic_beauty_body_slim_leg', '瘦腿'), new ComposerNode(EffectManagerData.NODE_ALL_SLIM, "BEF_BEAUTY_BODY_SLIM_LEG", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_BODY_SLIM_LEG, mEffectType)[0])),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_BODY_SLIM_WAIST, new Material('app.media.ic_beauty_body_thin', '瘦腰'), new ComposerNode(EffectManagerData.NODE_ALL_SLIM, "BEF_BEAUTY_BODY_SLIM_WAIST", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_BODY_SLIM_WAIST, mEffectType)[0])),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_BODY_ENLARGE_BREAST, new Material('app.media.ic_beauty_body_enlarge_breast', '丰胸'), new ComposerNode(EffectManagerData.NODE_ALL_SLIM_BREAST, "BEF_BEAUTY_BODY_ENLARGR_BREAST", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_BODY_ENLARGE_BREAST, mEffectType)[0])),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_BODY_ENHANCE_HIP, new Material('app.media.ic_beauty_body_enhance_hip', '美胯'), new ComposerNode(EffectManagerData.NODE_ALL_SLIM_BREAST, "BEF_BEAUTY_BODY_ENHANCE_HIP", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_BODY_ENHANCE_HIP, mEffectType, true)[0]), true, true),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_BODY_ENHANCE_NECK, new Material('app.media.ic_beauty_body_enhance_neck', '天鹅颈'), new ComposerNode(EffectManagerData.NODE_ALL_SLIM_BREAST, "BEF_BEAUTY_BODY_ENHANCE_NECK", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_BODY_ENHANCE_NECK, mEffectType)[0])),
        new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_BODY_SLIM_ARM, new Material('app.media.ic_beauty_body_slim_arm', '瘦手臂'), new ComposerNode(EffectManagerData.NODE_ALL_SLIM_BREAST, "BEF_BEAUTY_BODY_SLIM_ARM", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_BODY_SLIM_ARM, mEffectType)[0])),
      ])
    }
    return this.mBeautyBodyItems
  }

  private _getMakeupItems(): EffectButtonItem {
    let mEffectType = 0
    if (this.mBeautyMakeupItems == null) {
      this.mBeautyMakeupItems = new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_BODY, new Material('', ""))
      this.mBeautyMakeupItems.setChildren([
        new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', "关闭")),
        new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_LIP, new Material('app.media.ic_makeup_lip', '口红'), undefined, false).setChildren(this._getMakeupOptionItems(EffectManagerData.TYPE_MAKEUP_LIP)),
        new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_BLUSHER, new Material('app.media.ic_makeup_blusher', '腮红'), undefined, false).setChildren(this._getMakeupOptionItems(EffectManagerData.TYPE_MAKEUP_BLUSHER)),
        new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_FACIAL, new Material('app.media.ic_makeup_facial', '修容'), undefined, false).setChildren(this._getMakeupOptionItems(EffectManagerData.TYPE_MAKEUP_FACIAL)),
        new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYEBROW, new Material('app.media.ic_makeup_eyebrow', '眉毛'), undefined, false).setChildren(this._getMakeupOptionItems(EffectManagerData.TYPE_MAKEUP_EYEBROW)),
        new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYESHADOW, new Material('app.media.ic_makeup_eyeshadow', '眼影'), undefined, false).setChildren(this._getMakeupOptionItems(EffectManagerData.TYPE_MAKEUP_EYESHADOW)),
        // new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYELASH, new Material('app.media.ic_makeup_eyelash', '睫毛'), undefined, false).setChildren(this._getMakeupOptionItems(EffectManagerData.TYPE_MAKEUP_EYELASH)),
        // new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYELIGHT, new Material('app.media.ic_makeup_eye_light', '眼神光'), undefined, false).setChildren(this._getMakeupOptionItems(EffectManagerData.TYPE_MAKEUP_EYELIGHT)),
        new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_PUPIL, new Material('app.media.ic_makeup_pupil', '美瞳'), undefined, false).setChildren(this._getMakeupOptionItems(EffectManagerData.TYPE_MAKEUP_PUPIL)),
        new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_WOCAN, new Material('app.media.ic_makeup_eye_wocan', '卧蚕'), undefined, false).setChildren(this._getMakeupOptionItems(EffectManagerData.TYPE_MAKEUP_WOCAN)),
        new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_HAIR, new Material('app.media.ic_makeup_hair', '染发'), undefined, false).setChildren(this._getMakeupOptionItems(EffectManagerData.TYPE_MAKEUP_HAIR)),
      ])
    }
    return this.mBeautyMakeupItems
  }

  private _getStyleMakeupItems(): EffectButtonItem {
    if (this.mStyleMakeupItems == null) {
      let defaultIntensity = this._getDefaultIntensity(EffectManagerData.TYPE_STYLE_MAKEUP, 0)
      this.mStyleMakeupItems = new EffectButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('', ""),undefined,false)
      this.mStyleMakeupItems.setChildren([
        new StickerButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', "关闭")),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_baicha', '白茶'), new ComposerNode('style_makeup_local/baicha', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_xiaoxiong', '没有小熊'), new ComposerNode('style_makeup_local/meiyouxiaoxiong', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_lantong', '冰川蓝瞳'), new ComposerNode('style_makeup_local/bingchuan', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_qise', '气色'), new ComposerNode('style_makeup_local/qise', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_aidou', '爱豆'), new ComposerNode('style_makeup_local/aidou', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_youya', '优雅'), new ComposerNode('style_makeup_local/youya', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_cwei', 'C位'), new ComposerNode('style_makeup_local/cwei', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_nuannan', '暖男'), new ComposerNode('style_makeup_local/nuannan', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_baixi', '白皙'), new ComposerNode('style_makeup_local/baixi', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_wennuan', '温暖'), new ComposerNode('style_makeup_local/wennuan', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_shensui', '深邃'), new ComposerNode('style_makeup_local/shensui', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_tianmei', '甜美'), new ComposerNode('style_makeup_local/tianmei', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_duanmei', '断眉'), new ComposerNode('style_makeup_local/duanmei', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_oumei', '欧美'), new ComposerNode('style_makeup_local/oumei', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_zhigan', '质感'), new ComposerNode('style_makeup_local/zhigan', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        // new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_hanxi', '韩系'), new ComposerNode('style_makeup_local/hanxi', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_yuanqi', '元气'), new ComposerNode('style_makeup_local/yuanqi', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_shuiwu', '水雾'), new ComposerNode('style_makeup_local/shuiwu', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_naicha', '奶茶'), new ComposerNode('style_makeup_local/naicha', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_mitaofen', '蜜桃粉Ⅲ'), new ComposerNode('style_makeup_local/mitaofen3', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_fenxia', '粉夏'), new ComposerNode('style_makeup_local/fenxia', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_tiansang', '甜丧'), new ComposerNode('style_makeup_local/tiansang', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_insfeng', 'ins风Ⅱ'), new ComposerNode('style_makeup_local/insfeng2', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_heisirong', '黑丝绒'), new ComposerNode('style_makeup_local/heisirong', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_nyushen', '女神'), new ComposerNode('style_makeup_local/nyushen', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_qizhi', '气质'), new ComposerNode('style_makeup_local/qizhi', ["Filter_ALL", "Makeup_ALL"], defaultIntensity)),
        new StickerButtonItem(EffectManagerData.TYPE_STYLE_MAKEUP, new Material('app.media.icon_naixiong', '奶凶'), new ComposerNode('style_makeup_local/naixiong', ["Filter_ALL", "Makeup_ALL"], defaultIntensity))
      ])
    }
    return this.mStyleMakeupItems
  }

  private _getPaletteItems(): EffectButtonItem{
    if (this.mPaletteItems == null) {
      let mEffectType = 0
      this.mPaletteItems = new EffectButtonItem(EffectManagerData.TYPE_PALETTE, new Material('', ""))
      this.mPaletteItems.setChildren([
        new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', "关闭")),
        new EffectButtonItem(EffectManagerData.TYPE_PALETTE_TEMPERATURE, new Material('app.media.icon_temperature', "色温"), new ComposerNode("palette/color", "Intensity_Temperature", this._getDefaultIntensity(EffectManagerData.TYPE_PALETTE_TEMPERATURE, mEffectType, true)[0]), true, true),
        new EffectButtonItem(EffectManagerData.TYPE_PALETTE_TONE, new Material('app.media.icon_tone', "色调"), new ComposerNode("palette/light", "Intensity_Hue", this._getDefaultIntensity(EffectManagerData.TYPE_PALETTE_TONE, mEffectType, true)[0]), true, true),
        new EffectButtonItem(EffectManagerData.TYPE_PALETTE_SATURATION, new Material('app.media.icon_saturation', "饱和度"), new ComposerNode("palette/color", "Intensity_Saturation", this._getDefaultIntensity(EffectManagerData.TYPE_PALETTE_SATURATION, mEffectType, true)[0]), true, true),
        new EffectButtonItem(EffectManagerData.TYPE_PALETTE_BRIGHTNESS, new Material('app.media.icon_brightness', "亮度"), new ComposerNode("palette/light", "Intensity_Light", this._getDefaultIntensity(EffectManagerData.TYPE_PALETTE_BRIGHTNESS, mEffectType, true)[0]), true, true),
        new EffectButtonItem(EffectManagerData.TYPE_PALETTE_CONTRAST, new Material('app.media.icon_contrast', "对比度"), new ComposerNode("palette/contrast", "Intensity_Contrast", this._getDefaultIntensity(EffectManagerData.TYPE_PALETTE_CONTRAST, mEffectType, true)[0]), true, true),
        new EffectButtonItem(EffectManagerData.TYPE_PALETTE_HIGHLIGHT, new Material('app.media.icon_highlight', "高亮"), new ComposerNode("palette/light", "Intensity_Highlight", this._getDefaultIntensity(EffectManagerData.TYPE_PALETTE_HIGHLIGHT, mEffectType, true)[0]), true, true),
        new EffectButtonItem(EffectManagerData.TYPE_PALETTE_SHADOW, new Material('app.media.icon_shadow', "阴影"), new ComposerNode("palette/color", "Intensity_Shadow", this._getDefaultIntensity(EffectManagerData.TYPE_PALETTE_SHADOW, mEffectType, false)[0]), true, false),
        new EffectButtonItem(EffectManagerData.TYPE_PALETTE_LIGHT_SENSATION, new Material('app.media.icon_light_perception', "光感"), new ComposerNode("palette/light", "Intensity_Light_Sensation", this._getDefaultIntensity(EffectManagerData.TYPE_PALETTE_LIGHT_SENSATION, mEffectType, true)[0]), true, true),
        new EffectButtonItem(EffectManagerData.TYPE_PALETTE_PARTICLE, new Material('app.media.icon_particles', "颗粒"), new ComposerNode("palette/particle", "Intensity_Particle", this._getDefaultIntensity(EffectManagerData.TYPE_PALETTE_PARTICLE, mEffectType, false)[0]), true, false),
        new EffectButtonItem(EffectManagerData.TYPE_PALETTE_FADE, new Material('app.media.icon_fading', "褪色"), new ComposerNode("palette/color", "Intensity_Fade", this._getDefaultIntensity(EffectManagerData.TYPE_PALETTE_FADE, mEffectType, false)[0]), true, false),
        new EffectButtonItem(EffectManagerData.TYPE_PALETTE_VIGNETTING, new Material('app.media.icon_vignette', "暗角"), new ComposerNode("palette/vignette", "Intensity_Vignette", this._getDefaultIntensity(EffectManagerData.TYPE_PALETTE_VIGNETTING, mEffectType, false)[0]), true, false)
      ])
    }
    return this.mPaletteItems
  }

  private _getBlackTechnologyItems(): EffectButtonItem {
    if (this.mBlackTechnologyItems == null) {
      let mEffectType = 0
      this.mBlackTechnologyItems = new EffectButtonItem(EffectManagerData.TYPE_BLACK_TECHNOLOGY, new Material('', ""))
      this.mBlackTechnologyItems.setChildren([
        new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', "关闭")),
        new EffectButtonItem(EffectManagerData.TYPE_BLACK_TECHNOLOGY_YUNFU, new Material('app.media.icon_black_technology_levelling', "匀肤"), new ComposerNode("hack/yunfu_fengying_liuchanglian_standard", "Levelling", 0)),
        new EffectButtonItem(EffectManagerData.TYPE_BLACK_TECHNOLOGY_FULING, new Material('app.media.icon_black_technology_full', "丰盈"), new ComposerNode("hack/yunfu_fengying_liuchanglian_standard", "Full", 0)),
        new EffectButtonItem(EffectManagerData.TYPE_BLACK_TECHNOLOGY_LUNKUOPINGHUA, new Material('app.media.icon_black_technology_fluid_face', "流畅脸"), new ComposerNode("hack/yunfu_fengying_liuchanglian_standard", "Fluid_Face", 0))
      ])
    }
    return this.mBlackTechnologyItems
  }

  private _getFilterItems(): EffectButtonItem {
    if (this.mFilterItems == null) {
      let defaultIntensity = 0;
      this.mFilterItems = new EffectButtonItem(EffectManagerData.TYPE_FILTER, new Material('', ""), undefined, false)
      this.mFilterItems.setChildren([
        new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', "关闭")),
        new EffectButtonItem(EffectManagerData.TYPE_FILTER, new Material('app.media.icon_filter_category_portrait', '人像'), undefined, false)
          .setChildren([
            new FilterButtonItem(EffectManagerData.TYPE_CLOSE, 'app.media.clear', "关闭"),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_roubai', '柔白', "Filter_01_38", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_ziran', '自然', "Filter_38_F1", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_chujian', '初见', "Filter_25_Po3", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_qingtou', '清透', "Filter_37_L5", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_wenrou', '温柔', "Filter_23_Po1", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_lianaichaotian', '恋爱超甜', "Filter_24_Po2", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_soft', 'soft', "Filter_28_Po6", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_lengbaipi', '冷白皮', "Filter_48_4001", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_touliang', '透亮', "Filter_49_4002", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_liangju', '亮橘', "Filter_50_4003", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_gaojihui', '高级灰', "Filter_32_Po10", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_haibianrenxiang', '海边人像', "Filter_31_Po9", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_lengyang', '冷氧', "Filter_30_Po8", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_hongzong', '红棕', "Filter_36_L4", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_naicha', '奶茶', "Filter_27_Po5", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_andiao', '暗调', "Filter_26_Po4", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_qiannuan', '浅暖', "Filter_10_11", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_hutaomu', '胡桃木', "Filter_51_4004", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_shenhe', '深褐', "Filter_52_4005", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_degula', '德古拉', "Filter_53_4006", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_naiyou', '奶油', "Filter_02_14", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_makalong', '马卡龙', "Filter_07_06", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_yangqi', '氧气', "Filter_03_20", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_wuyu', '物语', "Filter_11_09", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_luolita', '洛丽塔', "Filter_05_10", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_jiegeng', '桔梗', "Filter_04_12", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_lise', '栗色', "Filter_54_4007", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_yelin', '椰林', "Filter_55_4008", defaultIntensity),
          ]),
        new EffectButtonItem(EffectManagerData.TYPE_FILTER, new Material('app.media.icon_filter_category_cusine', '美食'), undefined, false)
          .setChildren([
            new FilterButtonItem(EffectManagerData.TYPE_CLOSE, 'app.media.clear', "关闭"),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_shise', '食色', "Filter_41_F4", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_chuanwei', '川味', "Filter_42_F5", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_suda', '苏打', "Filter_39_F2", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_nuanshi', '暖食', "Filter_56_4009", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_qipaoshui', '气泡水', "Filter_57_4010", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_liaoli', '料理', "Filter_58_4011", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_tanshao', '炭烧', "Filter_59_4012", defaultIntensity),
          ]),
        new EffectButtonItem(EffectManagerData.TYPE_FILTER, new Material('app.media.icon_filter_category_vintage', '风景'), undefined, false)
          .setChildren([
            new FilterButtonItem(EffectManagerData.TYPE_CLOSE, 'app.media.clear', "关闭"),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_yinghua', '樱花', "Filter_09_19", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_jiazhou', '加州', "Filter_40_F3", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_mitao', '蜜桃', "Filter_06_03", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_qianxia', '浅夏', "Filter_34_L2", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_haidao', '海岛', "Filter_33_L1", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_beihaidao', '北海道', "Filter_12_08", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_xiyang', '夕阳', "Filter_29_Po7", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_yese', '夜色', "Filter_35_L3", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_jingdu', '京都', "Filter_60_4013", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_haian', '海岸', "Filter_61_4014", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_lyuyan', '绿妍', "Filter_62_4015", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_wanying', '晚樱', "Filter_63_4016", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_qingcheng', '青橙', "Filter_64_4017", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_aizhicheng', '爱之城', "Filter_65_4018", defaultIntensity),
          ]),
        new EffectButtonItem(EffectManagerData.TYPE_FILTER, new Material('app.media.icon_filter_category_portrait', '复古'), undefined, false)
          .setChildren([
            new FilterButtonItem(EffectManagerData.TYPE_CLOSE, 'app.media.clear', "关闭"),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_meishijiaopian', '美式胶片', "Filter_43_S1", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_hongsefugu', '红色复古', "Filter_44_S2", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_lyutu', '旅途', "Filter_45_S3", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_nuanhuang', '暖黄', "Filter_46_S4", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_landiaojiaopian', '蓝调胶片', "Filter_47_S5", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_riza', '日杂', "Filter_13_02", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_ct', 'CT', "Filter_66_4019", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_ek', 'EK', "Filter_67_4020", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_fj', 'FJ', "Filter_68_4021", defaultIntensity),
          ]),
        new EffectButtonItem(EffectManagerData.TYPE_FILTER, new Material('app.media.icon_filter_category_stylization', '风格化'), undefined, false)
          .setChildren([
            new FilterButtonItem(EffectManagerData.TYPE_CLOSE, 'app.media.clear', "关闭"),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_hongchun', '红唇', "Filter_19_37", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_julandiao', '橘蓝调', "Filter_20_05", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_tuise', '褪色', "Filter_21_01", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_heibai', '黑白', "Filter_22_16", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_heijin', '黑金', "Filter_69_4022", defaultIntensity),
            new FilterButtonItem(EffectManagerData.TYPE_FILTER, 'app.media.icon_filter_heben', '赫本', "Filter_70_4023", defaultIntensity),
          ]),
      ])
    }

    return this.mFilterItems
  }
  private _getDefaultIntensity(type: number, effectType: number, enableNegative?: boolean): number[] {
    let intensity = [0]
    if (EffectManagerData.DEFAULT_STANDARD_VALUE && EffectManagerData.DEFAULT_STANDARD_VALUE.has(type)) {
      intensity = EffectManagerData.DEFAULT_STANDARD_VALUE.get(type)!!
    }
    if (enableNegative != undefined && enableNegative && intensity[0] == 0) {
      intensity = [0.5]
    }
    return intensity;
  }

  private _getBeautyReshapeItemsStandard(): EffectButtonItem {
    let reshapeNodeOld = "reshape_standard"
    let reshapeNode = "reshape_lite"
    let mEffectType = 0
    //脸部
    let faceGroup = new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE, new Material('app.media.icon_face', "面部"))
    faceGroup.setChildren([
      new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', "关闭")),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_OVERALL, new Material('app.media.ic_beauty_cheek_reshape', '瘦脸'), undefined, false).setChildren(this._getMakeupOptionItems(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_OVERALL)),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_SMALL, new Material('app.media.ic_beauty_reshape_face_small', '小脸'), new ComposerNode(reshapeNode, "Internal_Deform_Face", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_SMALL,mEffectType)[0])),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_CUT, new Material('app.media.ic_beauty_reshape_face_cut', '窄脸'), new ComposerNode(reshapeNode, "Internal_Deform_CutFace", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_CUT,mEffectType)[0])),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_BODY_SHRINK_HEAD, new Material('app.media.ic_beauty_body_shrink_head', '小头'), new ComposerNode(reshapeNode, "BEF_BEAUTY_BODY_SHRINK_HEAD", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_BODY_SHRINK_HEAD, mEffectType)[0])),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_CHEEK, new Material('app.media.ic_beauty_reshape_cheek', '颧骨'), new ComposerNode(reshapeNode, "Internal_Deform_Zoom_Cheekbone", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_CHEEK,mEffectType)[0])),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_JAW, new Material('app.media.ic_beauty_reshape_jaw', '下颌'), new ComposerNode(reshapeNode, "Internal_Deform_Zoom_Jawbone", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_JAW,mEffectType)[0])),
      // new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_V, new Material('app.media.ic_beauty_reshape_face_v', 'v脸'), new ComposerNode(reshapeNodeOld, "Internal_Deform_VFace", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_V,mEffectType)[0])),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_CHIN, new Material('app.media.ic_beauty_reshape_chin', '下巴长短'), new ComposerNode(reshapeNode, "Internal_Deform_Chin", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_CHIN,mEffectType, true)[0]), true, true),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_FOREHEAD, new Material('app.media.ic_beauty_reshape_forehead', '发际线'), new ComposerNode(reshapeNode, "Internal_Deform_Forehead", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_FOREHEAD,mEffectType, true)[0]), true, true),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_SMILE_FOLDS, new Material('app.media.ic_beauty_reshape_smile_folds', '法令纹'), new ComposerNode(EffectManagerData.NODE_BEAUTY_4ITEMS, "BEF_BEAUTY_SMILES_FOLDS", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_SMILE_FOLDS,mEffectType)[0]))
    ]);
    //眼部
    let eyeGroup = new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE, new Material('app.media.icon_eye', "眼睛"))
    eyeGroup.setChildren([
      new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', "关闭")),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_SIZE, new Material('app.media.ic_reshape_eye_size', "大小"), new ComposerNode(reshapeNode, "Internal_Deform_Eye", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_SIZE, mEffectType)[0])),
      // new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_HEIGHT, new Material('app.media.ic_reshape_eye_height', "眼高"), new ComposerNode(reshapeNodeOld, "Internal_EyeHeight", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_HEIGHT, mEffectType, true)[0]), true, true),
      // new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_WIDTH, new Material('app.media.ic_reshape_eye_width', "眼宽"), new ComposerNode(reshapeNodeOld, "Internal_EyeWidth", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_WIDTH, mEffectType, true)[0]), true, true),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_MOVE, new Material('app.media.ic_reshape_eye_move', "位置"), new ComposerNode(reshapeNode, "Internal_Deform_Eye_Move", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_MOVE, mEffectType)[0])),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_SPACING, new Material('app.media.ic_reshape_eye_spacing', "眼距"), new ComposerNode(reshapeNode, "Internal_Eye_Spacing", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_SPACING, mEffectType)[0])),
      // new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_LOWER_EYELID, new Material('app.media.ic_reshape_eye_lower_eyelid', "眼睑下至"), new ComposerNode(reshapeNodeOld, "Internal_LowerEyelid", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_LOWER_EYELID, mEffectType)[0]), true, true),
      // new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_PUPIL, new Material('app.media.ic_reshape_eye_pupil', "瞳孔大小"), new ComposerNode(reshapeNodeOld, "Internal_EyePupil", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_PUPIL, mEffectType, true)[0]), true, true),
      // new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_INNER_CORNER, new Material('app.media.ic_reshape_eye_inner_corner', "内眼角"), new ComposerNode(reshapeNodeOld, "Internal_EyeInnerCorner", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_INNER_CORNER, mEffectType, true)[0]), true, true),
      // new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_OUTER_CORNER, new Material('app.media.ic_reshape_eye_outer_corner', "外眼角"), new ComposerNode(reshapeNodeOld, "Internal_EyeOuterCorner", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_OUTER_CORNER, mEffectType, true)[0]), true, true),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_ROTATE, new Material('app.media.ic_reshape_eye_rotate', "眼尾上扬"), new ComposerNode(reshapeNode, "Internal_Deform_RotateEye", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_EYE_ROTATE, mEffectType)[0])),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_BRIGHTEN_EYE, new Material('app.media.ic_reshape_eye_brighten', "亮眼"), new ComposerNode(EffectManagerData.NODE_BEAUTY_4ITEMS, "BEF_BEAUTY_BRIGHTEN_EYE", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_BRIGHTEN_EYE,mEffectType)[0])),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_REMOVE_POUCH, new Material('app.media.ic_reshape_eye_remove_pouch', "黑眼圈"), new ComposerNode(EffectManagerData.NODE_BEAUTY_4ITEMS, "BEF_BEAUTY_REMOVE_POUCH", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_REMOVE_POUCH,mEffectType)[0])),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_SINGLE_TO_DOUBLE_EYELID, new Material('app.media.ic_reshape_eye_double_eye_lid', "双眼皮"), new ComposerNode("double_eye_lid", "BEF_BEAUTY_EYE_SINGLE_TO_DOUBLE", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_SINGLE_TO_DOUBLE_EYELID, mEffectType)[0])),
    ])

    let noseGroup = new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_NOSE, new Material('app.media.icon_nose', "鼻子"))
    noseGroup.setChildren([
      new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', "关闭")),
      // new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_NOSE_SIZE, new Material('app.media.ic_reshape_nose_size', "大小"), new ComposerNode(reshapeNodeOld, "Internal_Deform_NoseSize", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_NOSE_SIZE, mEffectType, true)[0]), true, true),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_NOSE_SWING, new Material('app.media.ic_reshape_nose_swing', "鼻翼"), new ComposerNode(reshapeNode, "Internal_Deform_Nose", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_NOSE_SWING, mEffectType, true)[0]), true, true),
      // new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_NOSE_BRIDGE, new Material('app.media.ic_reshape_nose_bridge', "鼻梁"), new ComposerNode(reshapeNodeOld, "Internal_Deform_NoseBridge", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_NOSE_BRIDGE, mEffectType, true)[0]), true, true),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_NOSE_MOVE, new Material('app.media.ic_reshape_nose_move', "提升"), new ComposerNode(reshapeNode, "Internal_Deform_MovNose", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_NOSE_MOVE, mEffectType, true)[0]), true, true),
      // new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_NOSE_TIP, new Material('app.media.ic_reshape_nose_tip', "鼻尖"), new ComposerNode(reshapeNodeOld, "Internal_Deform_NoseTip", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_NOSE_TIP, mEffectType, true)[0]), true, true),
      // new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_NOSE_ROOT, new Material('app.media.ic_reshape_nose_root', "山根"), new ComposerNode(reshapeNodeOld, "Internal_Deform_NoseRoot", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_NOSE_ROOT, mEffectType, true)[0]), true, true),
    ])

      // let eyeBrowGroup = new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_BROW, new Material('app.media.icon_brow', "眉毛"))
      // eyeBrowGroup.setChildren([
      //   new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', "关闭")),
      //   new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_BROW_SIZE, new Material('app.media.ic_beauty_reshape_brow_size', "粗细"), new ComposerNode(reshapeNodeOld, "Internal_BrowSize", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_BROW_SIZE, mEffectType, true)[0]), true, true),
      //   new EffectButtonItem(EffectManagerData.TTYPE_BEAUTY_RESHAPE_BROW_POSITION, new Material('app.media.ic_beauty_reshape_brow_position', "位置"), new ComposerNode(reshapeNodeOld, "Internal_BrowPosition", this._getDefaultIntensity(EffectManagerData.TTYPE_BEAUTY_RESHAPE_BROW_POSITION, mEffectType, true)[0]), true, true),
      //   new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_BROW_TILT, new Material('app.media.ic_beauty_reshape_brow_tilt', "倾斜"), new ComposerNode(reshapeNodeOld, "Internal_BrowTilt", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_BROW_TILT, mEffectType, true)[0]), true, true),
      //   new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_BROW_RIDGE, new Material('app.media.ic_beauty_reshape_brow_ridge', "眉峰"), new ComposerNode(reshapeNodeOld, "Internal_BrowRidge", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_BROW_RIDGE, mEffectType, true)[0]), true, true),
      //   new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_BROW_DISTANCE, new Material('app.media.ic_beauty_reshape_brow_distance', "间距"), new ComposerNode(reshapeNodeOld, "Internal_BrowDistance", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_BROW_DISTANCE, mEffectType, true)[0]), true, true),
      //   new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_BROW_WIDTH, new Material('app.media.ic_beauty_reshape_brow_width', "长短"), new ComposerNode(reshapeNodeOld, "Internal_BrowWidth", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_BROW_WIDTH, mEffectType, true)[0]), true, true),
      // ])

    let mouthGroup = new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_MOUTH, new Material('app.media.icon_mouth', "嘴巴"))
    mouthGroup.setChildren([
      new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', "关闭")),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_MOUTH_ZOOM, new Material('app.media.ic_reshape_mouth_zoom', "大小"), new ComposerNode(reshapeNode, "Internal_Deform_ZoomMouth", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_MOUTH_ZOOM, mEffectType, true)[0]), true, true),
      // new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_MOUTH_WIDTH, new Material('app.media.ic_reshape_mouth_width', "宽度"), new ComposerNode(reshapeNodeOld, "Internal_MouseWidth", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_MOUTH_WIDTH, mEffectType, true)[0]), true, true),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_MOUTH_MOVE, new Material('app.media.ic_reshape_mouth_move', "位置"), new ComposerNode(reshapeNode, "Internal_Deform_MovMouth", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_MOUTH_MOVE, mEffectType)[0])),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_MOUTH_SMILE, new Material('app.media.ic_reshape_mouth_smile', "微笑"), new ComposerNode(reshapeNode, "Internal_Deform_MouthCorner", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_MOUTH_SMILE,mEffectType)[0])),
      new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_WHITEN_TEETH, new Material('app.media.ic_reshape_mouth_white_teeth', "白牙"), new ComposerNode(EffectManagerData.NODE_BEAUTY_4ITEMS, "BEF_BEAUTY_WHITEN_TEETH", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_WHITEN_TEETH, mEffectType)[0])),
    ])

    return new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE, new Material('', '')).setChildren([
      new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
      faceGroup, eyeGroup, noseGroup, mouthGroup
    ])
  }

  private _getColorForChoose(type: number): ArrayList<ColorItem>{
    let list = new ArrayList<ColorItem>()
    switch (type)
    {
      case EffectManagerData.TYPE_MAKEUP_LIP: {
        list.add(new ColorItem("元气", 0.867, 0.388, 0.388))
        list.add(new ColorItem("柔和粉", 0.949, 0.576, 0.620))
        list.add(new ColorItem("西柚", 0.945, 0.510, 0.408))
        list.add(new ColorItem("火龙果", 0.714, 0.224, 0.388))
        list.add(new ColorItem("草莓啵啵", 0.631, 0.016, 0.016))
        break
      }
      case EffectManagerData.TYPE_MAKEUP_BLUSHER: {
        list.add(new ColorItem("浅粉", 0.988, 0.678, 0.733))
        list.add(new ColorItem("杏仁", 0.996, 0.796, 0.545))
        list.add(new ColorItem("珊瑚", 1.000, 0.565, 0.443))
        list.add(new ColorItem("粉桃", 1.000, 0.506, 0.529))
        list.add(new ColorItem("浅紫", 0.980, 0.722, 0.855))
        break;
      }
      case EffectManagerData.TYPE_MAKEUP_EYEBROW: {
        list.add(new ColorItem("黑", 0.078, 0.039, 0.039))
        list.add(new ColorItem("棕", 0.420, 0.314, 0.239))
        break;
      }
      case EffectManagerData.TYPE_MAKEUP_EYELASH: {
        list.add(new ColorItem("黑", 0.078, 0.039, 0.039))
        list.add(new ColorItem("棕", 0.420, 0.314, 0.239))
        break;
      }
      case EffectManagerData.TYPE_HAIR_DYE_HIGHLIGHT: {
        list.add(new ColorItem("雾霾蓝", 0.541, 0.616, 0.706))
        list.add(new ColorItem("白茶灰", 0.808, 0.792, 0.745))
        list.add(new ColorItem("玫红色", 0.384, 0.075, 0.086))
        break;
      }

    }
    return list
  }

  private _getMakeupOptionItems(type: number): EffectButtonItem[] {
    switch (type & EffectManagerData.SUB_MASK) {
      case EffectManagerData.TYPE_MAKEUP_LIP: {
        let effectType = 0;
        let colorItems = this._getColorForChoose(EffectManagerData.TYPE_MAKEUP_LIP);
        return [
          new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_LIP, new Material('app.media.ic_makeup_lip', "复古红"), new ComposerNode("lip/lite/fuguhong", ["Internal_Makeup_Lips"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_LIP, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_LIP, new Material('app.media.ic_makeup_lip', "少女粉"), new ComposerNode("lip/lite/shaonvfen", ["Internal_Makeup_Lips"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_LIP, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_LIP, new Material('app.media.ic_makeup_lip', "元气橘"), new ComposerNode("lip/lite/yuanqiju", ["Internal_Makeup_Lips"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_LIP, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_LIP, new Material('app.media.ic_makeup_lip', "西柚色"), new ComposerNode("lip/lite/xiyouse", ["Internal_Makeup_Lips"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_LIP, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_LIP, new Material('app.media.ic_makeup_lip', "西瓜红"), new ComposerNode("lip/lite/xiguahong", ["Internal_Makeup_Lips"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_LIP, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_LIP, new Material('app.media.ic_makeup_lip', "丝绒红"), new ComposerNode("lip/lite/sironghong", ["Internal_Makeup_Lips"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_LIP, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_LIP, new Material('app.media.ic_makeup_lip', "脏橘色"), new ComposerNode("lip/lite/zangjuse", ["Internal_Makeup_Lips"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_LIP, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_LIP, new Material('app.media.ic_makeup_lip', "梅子色"), new ComposerNode("lip/lite/meizise", ["Internal_Makeup_Lips"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_LIP, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_LIP, new Material('app.media.ic_makeup_lip', "珊瑚色"), new ComposerNode("lip/lite/shanhuse", ["Internal_Makeup_Lips"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_LIP, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_LIP, new Material('app.media.ic_makeup_lip', "豆沙粉"), new ComposerNode("lip/lite/doushafen", ["Internal_Makeup_Lips"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_LIP, effectType)), false, false),
        ];
      }
      case EffectManagerData.TYPE_MAKEUP_BLUSHER:{
        let effectType = 0;
        let colorItems = this._getColorForChoose(EffectManagerData.TYPE_MAKEUP_BLUSHER);
        return [
          new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_BLUSHER, new Material('app.media.ic_makeup_blusher', "微醺"), new ComposerNode("blush/lite/weixun", ["Internal_Makeup_Blusher"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_BLUSHER, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_BLUSHER, new Material('app.media.ic_makeup_blusher', "日常"), new ComposerNode("blush/lite/richang", ["Internal_Makeup_Blusher"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_BLUSHER, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_BLUSHER, new Material('app.media.ic_makeup_blusher', "蜜桃"), new ComposerNode("blush/lite/mitao", ["Internal_Makeup_Blusher"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_BLUSHER, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_BLUSHER, new Material('app.media.ic_makeup_blusher', "甜橙"), new ComposerNode("blush/lite/tiancheng", ["Internal_Makeup_Blusher"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_BLUSHER, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_BLUSHER, new Material('app.media.ic_makeup_blusher', "俏皮"), new ComposerNode("blush/lite/qiaopi", ["Internal_Makeup_Blusher"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_BLUSHER, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_BLUSHER, new Material('app.media.ic_makeup_blusher', "心机"), new ComposerNode("blush/lite/xinji", ["Internal_Makeup_Blusher"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_BLUSHER, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_BLUSHER, new Material('app.media.ic_makeup_blusher', "晒伤"), new ComposerNode("blush/lite/shaishang", ["Internal_Makeup_Blusher"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_BLUSHER, effectType)), false, false)
        ]
      }
      case EffectManagerData.TYPE_MAKEUP_PUPIL:{
        let effectType = 0;
        return [
          new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_PUPIL, new Material('app.media.ic_makeup_pupil', "混血棕"), new ComposerNode("pupil/hunxuezong", "Internal_Makeup_Pupil", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_PUPIL, effectType))),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_PUPIL, new Material('app.media.ic_makeup_pupil', "可可棕"), new ComposerNode("pupil/kekezong", "Internal_Makeup_Pupil", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_PUPIL, effectType))),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_PUPIL, new Material('app.media.ic_makeup_pupil', "蜜桃粉"), new ComposerNode("pupil/mitaofen", "Internal_Makeup_Pupil", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_PUPIL, effectType))),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_PUPIL, new Material('app.media.ic_makeup_pupil', "水光黑"), new ComposerNode("pupil/shuiguanghei", "Internal_Makeup_Pupil", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_PUPIL, effectType))),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_PUPIL, new Material('app.media.ic_makeup_pupil', "星空蓝"), new ComposerNode("pupil/xingkonglan", "Internal_Makeup_Pupil", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_PUPIL, effectType))),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_PUPIL, new Material('app.media.ic_makeup_pupil', "初见灰"), new ComposerNode("pupil/chujianhui", "Internal_Makeup_Pupil", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_PUPIL, effectType))),
        ]
      }
      case EffectManagerData.TYPE_MAKEUP_HAIR:{
        return [
          new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_HAIR, new Material('app.media.ic_makeup_hair', '暗蓝'), new ComposerNode("hair/anlan")),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_HAIR, new Material('app.media.ic_makeup_hair', '墨绿'), new ComposerNode("hair/molv")),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_HAIR, new Material('app.media.ic_makeup_hair', '深棕'), new ComposerNode("hair/shenzong")),
        ]
      }
      case EffectManagerData.TYPE_MAKEUP_EYESHADOW:{
        let effectType = 0;
        return [
          new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYESHADOW, new Material('app.media.ic_makeup_eyeshadow', "晚霞红"), new ComposerNode("eyeshadow/wanxiahong", "Internal_Makeup_Eye", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYESHADOW, effectType))),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYESHADOW, new Material('app.media.ic_makeup_eyeshadow', "少女粉"), new ComposerNode("eyeshadow/shaonvfen", "Internal_Makeup_Eye", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYESHADOW, effectType))),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYESHADOW, new Material('app.media.ic_makeup_eyeshadow', "气质粉"), new ComposerNode("eyeshadow/qizhifen", "Internal_Makeup_Eye", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYESHADOW, effectType))),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYESHADOW, new Material('app.media.ic_makeup_eyeshadow', "梅子红"), new ComposerNode("eyeshadow/meizihong", "Internal_Makeup_Eye", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYESHADOW, effectType))),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYESHADOW, new Material('app.media.ic_makeup_eyeshadow', "焦糖棕"), new ComposerNode("eyeshadow/jiaotangzong", "Internal_Makeup_Eye", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYESHADOW, effectType))),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYESHADOW, new Material('app.media.ic_makeup_eyeshadow', "元气橘"), new ComposerNode("eyeshadow/yuanqiju", "Internal_Makeup_Eye", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYESHADOW, effectType))),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYESHADOW, new Material('app.media.ic_makeup_eyeshadow', "奶茶色"), new ComposerNode("eyeshadow/naichase", "Internal_Makeup_Eye", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYESHADOW, effectType))),
        ]
      }
      case EffectManagerData.TYPE_MAKEUP_EYEBROW:{
        let effectType = 0;
        let colorItems = this._getColorForChoose(EffectManagerData.TYPE_MAKEUP_EYEBROW);
        return [
          new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYEBROW, new Material('app.media.ic_makeup_eyebrow', "棕色"), new ComposerNode("eyebrow/lite/BR01", ["Internal_Makeup_Brow"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYEBROW, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYEBROW, new Material('app.media.ic_makeup_eyebrow', "粗黑"), new ComposerNode("eyebrow/lite/BK01", ["Internal_Makeup_Brow"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYEBROW, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYEBROW, new Material('app.media.ic_makeup_eyebrow', "黑色"), new ComposerNode("eyebrow/lite/BK02", ["Internal_Makeup_Brow"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYEBROW, effectType)), false, false),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYEBROW, new Material('app.media.ic_makeup_eyebrow', "细黑"), new ComposerNode("eyebrow/lite/BK03", ["Internal_Makeup_Brow"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYEBROW, effectType)), false, false),
        ]
      }
      case EffectManagerData.TYPE_MAKEUP_FACIAL:{
        let effectType = 0;
        return [
          new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_FACIAL, new Material('app.media.ic_makeup_facial', "精致"), new ComposerNode("facial/jingzhi", "Internal_Makeup_Facial", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_FACIAL, effectType))),
        ]
      }
      case EffectManagerData.TYPE_MAKEUP_EYELASH: {
        let effectType = 0;
        let colorItems = this._getColorForChoose(EffectManagerData.TYPE_MAKEUP_EYELASH);
        return [
          new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYELASH, new Material('app.media.ic_makeup_eyelash', "自然"), new ComposerNode("eyelashes/ziran", ["Internal_Makeup_Eyelash", "R","G","B"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYELASH, effectType)), false, false, colorItems),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYELASH, new Material('app.media.ic_makeup_eyelash', "卷翘"), new ComposerNode("eyelashes/juanqiao", ["Internal_Makeup_Eyelash", "R","G","B"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYELASH, effectType)), false, false, colorItems),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYELASH, new Material('app.media.ic_makeup_eyelash', "翅膀"), new ComposerNode("eyelashes/chibang", ["Internal_Makeup_Eyelash", "R","G","B"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYELASH, effectType)), false, false, colorItems),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYELASH, new Material('app.media.ic_makeup_eyelash', "漫画"), new ComposerNode("eyelashes/manhua", ["Internal_Makeup_Eyelash", "R","G","B"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYELASH, effectType)), false, false, colorItems),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYELASH, new Material('app.media.ic_makeup_eyelash', "下垂"), new ComposerNode("eyelashes/xiachui", ["Internal_Makeup_Eyelash", "R","G","B"], this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYELASH, effectType)), false, false, colorItems),
        ]
      }
      case EffectManagerData.TYPE_MAKEUP_WOCAN: {
        let effectType = 0;
        return [
          new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_WOCAN, new Material('app.media.ic_makeup_wocan', "自然"), new ComposerNode("wocan/ziran", "Internal_Makeup_WoCan", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_WOCAN, effectType))),
          // new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_WOCAN, new Material('app.media.ic_makeup_wocan', "初恋"), new ComposerNode("wocan/chulian", "Internal_Makeup_WoCan", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_WOCAN, effectType))),
          // new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_WOCAN, new Material('app.media.ic_makeup_wocan', "漫画眼"), new ComposerNode("wocan/manhuayan", "Internal_Makeup_WoCan", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_WOCAN, effectType))),
          // new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_WOCAN, new Material('app.media.ic_makeup_wocan', "下垂"), new ComposerNode("wocan/xiachui", "Internal_Makeup_WoCan", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_WOCAN, effectType))),
          // new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_WOCAN, new Material('app.media.ic_makeup_wocan', "桃花"), new ComposerNode("wocan/taohua", "Internal_Makeup_WoCan", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_WOCAN, effectType))),
        ]
      }
      case EffectManagerData.TYPE_MAKEUP_EYELIGHT: {
        let effectType = 0;
        return [
          new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYELIGHT, new Material('app.media.ic_makeup_eye_light', "自然光"), new ComposerNode("eyelight/ziranguang", "Internal_Makeup_EyeLight", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYELIGHT, effectType))),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYELIGHT, new Material('app.media.ic_makeup_eye_light', "月牙光"), new ComposerNode("eyelight/yueyaguang", "Internal_Makeup_EyeLight", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYELIGHT, effectType))),
          new EffectButtonItem(EffectManagerData.TYPE_MAKEUP_EYELIGHT, new Material('app.media.ic_makeup_eye_light', "聚光灯"), new ComposerNode("eyelight/juguangdeng", "Internal_Makeup_EyeLight", this._getDefaultIntensity(EffectManagerData.TYPE_MAKEUP_EYELIGHT, effectType))),
        ]
      }
      case EffectManagerData.TYPE_BEAUTY_FACE_WHITEN:{
        let effectType = 0;
        return [
          new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
          new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_FACE_WHITEN_DEFAULT, new Material('app.media.ic_beauty_whiten_default', '美白'), new ComposerNode("beauty_lite_new", "whiten", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_FACE_WHITEN_DEFAULT, effectType))),
          new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_FACE_WHITEN_LENGBAI, new Material('app.media.ic_beauty_whiten_cool', '白皙'), new ComposerNode("beauty_Android_lengbai_standard", "whiten", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_FACE_WHITEN_LENGBAI, effectType))),
          new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_FACE_WHITEN_FENBAI, new Material('app.media.ic_beauty_whiten_pink', '粉白'), new ComposerNode("beauty_Android_fenbai_standard", "whiten", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_FACE_WHITEN_FENBAI, effectType))),
        ]
     }
      case EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_OVERALL: {
        let reshapeNode = "reshape_lite"
        let reshapeNode_face_overall = "reshape_girl";
        let reshapeNode_face_overall_boy = "reshape_boy";
        let reshapeNode_face_overall_nature = "reshape_nature";
        return [
          new EffectButtonItem(EffectManagerData.TYPE_CLOSE, new Material('app.media.clear_no_border', '关闭')),
          new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_OVERALL1, new Material('app.media.ic_beauty_cheek_reshape_default', "瘦脸"), new ComposerNode(reshapeNode, "Internal_Deform_Overall", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_OVERALL, 0))),
          new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_OVERALL3, new Material('app.media.ic_beauty_cheek_reshape_nanshen', "男神"), new ComposerNode(reshapeNode_face_overall_boy, "Face_ALL_boy", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_OVERALL, 0))),
          new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_OVERALL2, new Material('app.media.ic_beauty_cheek_reshape_nvshen', "女神"), new ComposerNode(reshapeNode_face_overall, "Face_ALL_girl", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_OVERALL, 0))),
          new EffectButtonItem(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_OVERALL4, new Material('app.media.ic_beauty_cheek_reshape_ziranlian', "自然脸"), new ComposerNode(reshapeNode_face_overall_nature, "Face_ALL", this._getDefaultIntensity(EffectManagerData.TYPE_BEAUTY_RESHAPE_FACE_OVERALL, 0)))
        ];
      }
    }

    return []
  }
}