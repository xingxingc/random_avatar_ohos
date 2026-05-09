import generateCharacter from "./model/BlobbyCharacter";
import { RetroButton } from "../../../view/RetroButton";
import { Util } from "../../../model/util/Util";
import { common } from "@kit.AbilityKit";
import fileUri from '@ohos.file.fileuri';

@Entry
@Component
export struct BlobbyPage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State svgUri :string = ''
  svgString :string = ''
  filePath :string = ''
  readonly imgSize = 240

  /*随机生成*/
  async randomAction() {
    this.svgString = generateCharacter()
    const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.filePath = await Util.svgToTempFile(context, this.svgString)
    let uri = fileUri.getUriFromPath(this.filePath);
    this.svgUri = uri
  }

  /*保存相册*/
  async saveAction() {
    const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

    let isGranted = await Util.requestWriteMediaPermission(context)
    if (!isGranted) return

    await Util.svgToPngAndSaveToPhoto(context, this.filePath, this.imgSize * 2);
  }

  /******************
   * UI以及生命周期方法
   ******************/

  onDidBuild(): void {
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

