import { kMyOpenSources,
  kOpenSourceProjectList,
  MyOpenSource, OpenSourceProject } from "../../model/object/OpenSourceProject"
import { Util } from "../../model/util/Util"
import { bundleManager } from "@kit.AbilityKit"

@Component
export struct SettingTabPage {
  @State
  version :string = ''

  onDidBuild(): void {
    let bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT)
    this.version = `v${bundleInfo.versionName}`
  }

  build() {
    Scroll() {
      Column() {
        Image($r('app.media.startIcon'))
          .width(88)
          .height(88)
          .margin({ top: 0 })
        Text('随机头像')
          .fontSize(18)
          .fontColor($r('app.color.black18'))
          .margin({ top: 15, bottom: 12 })
          .fontWeight(FontWeight.Bold)
        Text(this.version)
          .fontSize(13)
          .fontColor($r('app.color.black33'))
          .margin({ top: 0, bottom: 10 })
        Text('一款随机生成用户头像的工具类应用')
          .fontSize(13)
          .fontColor($r('app.color.grey77'))
        Column() {
          this.titleText('【开源声明】')
          this.descText('本项目遵循MIT开源协议。')
          ForEach(
            kMyOpenSources,
            (item :MyOpenSource) => {
              this.myOpenSourceRow(item)
            }
          )

          this.titleText('【致谢声明】')
          this.descText('站在巨人的肩膀上，感恩开源。在本应用中使用或借鉴了下方列出的开源项目里的功能，在此，向所有开发者致以诚挚的感谢。')
          ForEach(
            kOpenSourceProjectList,
            (item :OpenSourceProject, index: number) => {
              this.thirdPartSourceItem(item, index == kOpenSourceProjectList.length-1)
            }
          )
        }
        .margin({ top: 10 })
        .padding({ left:15, right: 15 })
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  titleText(title :string) {
    Text(title)
      .fontColor($r('app.color.black18'))
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .margin({ top: 25 })
  }

  @Builder
  descText(desc: string) {
    Text(desc)
      .fontColor($r('app.color.grey77'))
      .fontSize(13)
      .margin({ top: 10 })
  }

  @Builder
  myOpenSourceRow(item :MyOpenSource) {
    Row(){
      Blank()
        .width(4)
        .height(4)
        .backgroundColor($r('app.color.black18'))
        .borderRadius(2)
        .margin({ left: 6, right: 6 })
      Text(item.target)
        .fontSize(13)
        .fontColor($r('app.color.black18'))
        .fontWeight(FontWeight.Bold)
      Image($r("app.media.copy_link"))
        .size({ width: 12, height: 12 })
        .margin({ left: 5, right: 3 })
      Text('链接')
        .fontSize(12)
        .fontColor($r('app.color.copy_blue'))
        .margin({ right: 10 })
    }
    .alignItems(VerticalAlign.Center)
    .margin({ top: 10 })
    .onClick(() => {
      Util.copyText(item.link)
    })
  }

  @Builder
  thirdPartSourceItem(item :OpenSourceProject, isLastOne :boolean) {
    Column() {
      Row() {
        Blank()
          .width(4)
          .height(4)
          .backgroundColor($r('app.color.black18'))
          .borderRadius(2)
          .margin({ left: 6, right: 6 })
        Text(`[${item.name}]（作者：${item.author}）`)
          .fontSize(13)
          .fontColor($r('app.color.black18'))
          .fontWeight(FontWeight.Bold)
      }
      .alignItems(VerticalAlign.Center)
      Row() {
        Text(item.desc)
          .fontSize(13)
          .fontColor($r('app.color.grey77'))
          .fontWeight(FontWeight.Bold)
        Image($r("app.media.copy_link"))
          .size({ width: 12, height: 12 })
          .margin({ left: 5, right: 3 })
        Text('链接')
          .fontSize(12)
          .fontColor($r('app.color.copy_blue'))
          .margin({ right: 10 })
      }
      .alignItems(VerticalAlign.Center)
      .margin({ top: 8 })
      .onClick(() => {
        Util.copyText(item.link)
      })
    }
    .margin({ top: 15, bottom: isLastOne ? 20 : 0 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }
}