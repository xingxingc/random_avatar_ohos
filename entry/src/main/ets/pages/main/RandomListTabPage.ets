import { kRandomList, RandomSource } from "../../model/object/RandomSource"

@Component
export struct RandomListTabPage {

  @Consume('navPathStack') navPathStack: NavPathStack;

  build() {
    List({ space: 0 }) {
      Repeat(kRandomList)
        .each((r) => {
          this.itemCell(r.item)
        })
        .key((item, index) => item.title)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  itemCell(item :RandomSource) {
    ListItem() {
      Column() {
        Row() {
          Image($r(`app.media.${item.icon}`))
            .width(58)
            .height(58)
            .borderRadius(10)
          Text(item.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.black18'))
            .margin({ left: 10 })
          Blank()
            .layoutWeight(1)
          Image($r('app.media.random_arrow_right'))
            .width(22)
            .height(22)
        }
        .border({
          width: 2,
          color: $r('app.color.black18'),
          radius: 12
        })
        .height(80)
        .width('100%')
        .padding(10)
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.navPathStack.pushPathByName(item.path, null, true)
        })
      }
      .padding({ left: 10, right: 10, bottom: 10 })
    }
  }
}