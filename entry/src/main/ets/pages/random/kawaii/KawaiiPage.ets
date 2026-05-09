import { genKawaiiSvg } from "./kawaii";
import { RetroButton } from "../../../view/RetroButton";
import { Util } from "../../../model/util/Util";
import { common } from "@kit.AbilityKit";
import fileUri from '@ohos.file.fileuri';
import { KawaiiMood, KawaiiShapre } from "./types";
import { MOODS, SHAPES } from "./constants";
import { image } from "@kit.ImageKit";

@Entry
@Component
export struct KawaiiPage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State svgUri :string = ''
  svgString :string = ''
  filePath :string = ''
  readonly imgSize = 240
  readonly bodyColors = ['rgb(167, 226, 145)', 'rgb(232, 176, 178)', 'rgb(234, 182, 154)', 'rgb(229, 203, 132)', 'rgb(170, 192, 170)', 'rgb(166, 189, 217)', 'rgb(188, 172, 214)', 'rgb(214, 174, 182)', 'rgb(199, 188, 178)', 'rgb(171, 201, 208)', 'rgb(201, 196, 189)']
  readonly bgColor = 'rgb(255, 255, 255)'
  shapeColor = this.bodyColors[0]
  shape :KawaiiShapre = 'humanDinosaur'
  mood :KawaiiMood = 'happy'

  private readonly settings: RenderingContextSettings = new RenderingContextSettings(true);
  private readonly ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  /*随机生成*/
  async randomAction() {
    this.shapeColor = this.bodyColors[Math.floor(Math.random() * this.bodyColors.length)]
    this.shape = SHAPES[Math.floor(Math.random() * SHAPES.length)]
    this.mood = MOODS[Math.floor(Math.random() * MOODS.length)]
    await this.genSvg()
  }

  /*生成svg图形*/
  async genSvg() {
    this.svgString = genKawaiiSvg(this.shape, this.mood, this.shapeColor, this.bgColor)
    const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.filePath = await Util.svgToTempFile(context, this.svgString)
    let uri = fileUri.getUriFromPath(this.filePath);
    this.svgUri = uri

    this.ctx.clearRect(0, 0, this.imgSize, this.imgSize)
    this.ctx.fillStyle = '#fff'
    this.ctx.fillRect(0, 0, this.imgSize, this.imgSize)
    this.ctx.drawImage(new ImageBitmap(this.svgUri), 0, 0, this.imgSize, this.imgSize)
  }

  /*保存相册*/
  async saveAction() {
    const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

    let isGranted = await Util.requestWriteMediaPermission(context)
    if (!isGranted) return

    // 直接使用svg图像转成png图片会导致带红点的那个嘴巴消失掉，所以此处改成通过canvas实现图像转化
    // await Util.svgToPngAndSaveToPhoto(context, this.filePath, this.imgSize * 2);

    const pixelMap = this.ctx.getPixelMap(0, 0, this.imgSize, this.imgSize)
    const packer = image.createImagePacker()
    const buffer = await packer.packing(pixelMap, {
      format: 'image/png',
      quality: 100
    })
    Util.savaPngBufferToPhoto(context, buffer)
  }

  /******************
   * UI以及生命周期方法
   ******************/

  onDidBuild(): void {
    this.genSvg()
  }

  aboutToDisappear(): void {}

  build() {
    NavDestination() {
      Scroll() {
        Stack() {
          Canvas(this.ctx)
            .width(this.imgSize)
            .height(this.imgSize)
            .position({
              x: -1 * this.imgSize + 1,
              y: -1 * this.imgSize + 1
            })
            .opacity(0.01)
          Column() {
            Image(this.svgUri)
              .width(this.imgSize)
              .height(this.imgSize)
              .borderRadius(10)
            RetroButton({ title: '随机生成' })
              .onClick(() => this.randomAction())
              .margin({ top: 30 })
            RetroButton({ title: '保存相册' })
              .onClick(() => this.saveAction())
              .margin({ top: 15 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
    }
  }
}

