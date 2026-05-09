import { RetroButton } from "../../../view/RetroButton";
import { Util } from "../../../model/util/Util";
import { common } from "@kit.AbilityKit";
import fileUri from '@ohos.file.fileuri';
import { UglyModel } from "./modal/ugly_model";
import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';
import { LoadingView } from "../../../view/LoadingView";

@Entry
@Component
export struct UglyPage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State svgUri :string = ''
  pngBuffer :ArrayBuffer = new ArrayBuffer(0)
  readonly imgSize = 240

  loadingView: LoadingView = new LoadingView();

  /*随机生成*/
  /*UglyModel().generateFace()不太兼容鸿蒙系统（直接显示只能看到眼球和鼻子，svg文件保存到系统文件里，缩小的时候没问题，放大之后和在这个App一样，只显示很少的部分*/
  /*临时解决办法：直接生成png图片再展示*/
  async randomAction() {
    this.loadingView.showLoading('生成中')

    let p = new Promise<void>(async (resolve) => {
      await this.didGenAvatar()
      resolve()
    })

    await p

    this.loadingView.hide()
  }

  async didGenAvatar() {
    let svgString = new UglyModel().generateFace()
    const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let svgFilePath = await Util.svgToTempFile(context, svgString)
    const size = this.imgSize * 2

    const format = "image/png"
    let imageSource = image.createImageSource(svgFilePath);
    let pixelMap = await imageSource.createPixelMap({
      desiredSize: { width: size, height: size }
    });

    let imagePacker = image.createImagePacker();
    let buffer = await imagePacker.packToData(pixelMap, {
      format: format,
      quality: 100
    });

    let filePath = await this.savePngToTemp(context, buffer)
    let uri = fileUri.getUriFromPath(filePath);
    this.svgUri = uri
    this.pngBuffer = buffer
  }

  async savePngToTemp(context: common.UIAbilityContext, buffer: ArrayBuffer) {
    const tempDir = context.cacheDir;
    const fileName = `face_${Date.now()}.png`;
    const filePath = tempDir + '/' + fileName;
    let file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
    try {
      fs.writeSync(file.fd, buffer);

      fs.fsyncSync(file.fd);
    } finally {
      fs.closeSync(file);
    }
    return filePath;
  }

  /*保存相册*/
  async saveAction() {
    const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

    let isGranted = await Util.requestWriteMediaPermission(context)
    if (!isGranted) return

    Util.savaPngBufferToPhoto(context, this.pngBuffer)
  }

  /******************
   * UI以及生命周期方法
   ******************/

  onDidBuild(): void {

  }

  aboutToAppear(): void {
    this.randomAction()
  }

  aboutToDisappear(): void {}

  build() {
    NavDestination() {
      Scroll() {
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
  }
}

