@Component
export struct RetroButton {
  @Prop title :string = ''

  @State isPressed: boolean = false

  build() {
    Stack() {
      // 👇 阴影层（黑块，带偏移）
      Text('')
        .width(180)
        .height(46)
        .backgroundColor($r('app.color.black18'))
        .borderRadius(10)
        .translate({
          x: this.isPressed ? 1 : 2,
          y: this.isPressed ? 1 : 2
        })
      // 👇 按钮本体
      Text(this.title)
        .width(180)
        .height(46)
        .textAlign(TextAlign.Center)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isPressed ? $r('app.color.white') : $r('app.color.black18'))
        .backgroundColor(this.isPressed ? $r('app.color.black33') : $r('app.color.white'))
        .border({
          width: 2,
          color: $r('app.color.black18')
        })
        .borderRadius(10)
        .translate({
          x: this.isPressed ? 1 : 0,
          y: this.isPressed ? 1 : 0
        })
    }
    .onTouch((event) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false
      }
    })
  }
}
