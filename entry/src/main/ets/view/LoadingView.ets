export class LoadingTime {
  // 显示时间为baseTime+msg.length*wordTime
  static baseTime: number = 400; // 消息显示基本时间
  static wordTime: number = 90; // 每个字增加显示的时间

  // 最终显示时间为上面计算结果限制到最短与最长之间
  static minTime: number = 1600; // 最短显示时间
  static maxTime: number = 4200; // 最长显示时间
};

export enum LoadingType {
  Loading = 0,
  Info,
  Success,
  Error,
  Length
};

interface LoadingParam {
  msg: string,
  cancelCallBack?: () => void,
  alignment?: DialogAlignment,
  offset?: Offset,
  showInSubWindow?: boolean,
  isModal?: boolean,
  tmpHUDNum?: number, // 缓存HUD的数量，用于多层返回HUD不显示情况
};

@Entry
@CustomDialog
struct _LoadingView {
  controller: CustomDialogController;
  close: () => void = () => {
  };
  type: LoadingType = LoadingType.Loading;
  image: ResourceStr | undefined = undefined;
  @State angle: number = 0;
  msg: string = '';

  aboutToAppear() {
    if (this.type === LoadingType.Loading) {
      setTimeout(() => {
        this.angle = 360;
      }, 100);
    }
  }

  build() {
    Column() {
      if (this.type === LoadingType.Loading) {
        Row()
          .width(this.getUIContext().px2vp(200))
          .height(this.getUIContext().px2vp(200))
          .sweepGradient({
            center: [this.getUIContext().px2vp(100), this.getUIContext().px2vp(100)],
            rotation: 280,
            start: 0,
            end: 360,
            colors:
            [['rgba(255, 255, 255, 0.0)', 0.0], ['rgba(255, 255, 255, 0.0)', 0.18], ['rgba(255, 255, 255, 1.0)', 1.0]]
          })
          .clipShape(new Path({
            width: 100, height: 100, commands:
            `M100 10 A90 90 0 1 0 190 100 A2 8 0 1 0 182 100 A82 82 0 1 1 100 18 A4 4 0 0 0 100 10 Z`
          }))
          .rotate({
            z: 1,
            angle: this.angle
          })
          .animation({
            duration: 1000,
            curve: Curve.Linear,
            iterations: -1,
            expectedFrameRateRange: {
              min: 20,
              max: 60,
              expected: 60,
            }
          })
          .scale({ x: 0.9, y: 0.9 })
      } else if (this.image) {
        Image(this.image)
          .fitOriginalSize(true)
          .objectFit(ImageFit.None)
      }
      if (this.msg) {
        Text(this.msg)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .padding({ top: this.type === LoadingType.Loading || this.image ? 10 : 0 })
      }
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(12)
    .margin(30)
    .backgroundColor(Color.Black)
    .borderRadius(10)
    .shadow({
      radius: 10,
      color: Color.Gray,
      offsetX: 3,
      offsetY: 0
    })
  }
}

let _dialogController: CustomDialogController | null;
let _cancelCallBack: (() => void) | undefined;

let tmpHUDArray: LoadingView[] = [];

@Component
export struct LoadingView {
  showLoading(
    msg: string | LoadingParam = '',
    cancelCallBack?: () => void,
    alignment?: DialogAlignment,
    offset?: Offset,
    showInSubWindow?: boolean,
    isModal?: boolean,
    tmpHUDNum: number = 1, // 缓存HUD的数量，用于多层返回HUD不显示情况
  ): void {
    if (typeof msg === 'string') {
      this.showType(LoadingType.Loading, undefined, msg, cancelCallBack, alignment, offset, showInSubWindow, isModal);
    } else {
      this.showType(LoadingType.Loading, undefined, msg.msg, msg.cancelCallBack, msg.alignment, msg.offset,
        msg.showInSubWindow, msg.isModal);
      tmpHUDNum = msg.tmpHUDNum ?? 1;
    }

    // 用于解决网络返回或者其它情况下不显示的问题
    if (tmpHUDArray.length < tmpHUDNum) {
      for (let index = 0; index < tmpHUDNum; index++) {
        tmpHUDArray.push(new LoadingView());
      }
    }
  }

  showInfo(
    msg: string | LoadingParam = '',
    cancelCallBack?: () => void,
    alignment?: DialogAlignment,
    offset?: Offset,
    showInSubWindow?: boolean,
    isModal?: boolean,
  ): void {
    if (typeof msg === 'string') {
      this.showType(LoadingType.Info, undefined, msg, cancelCallBack, alignment, offset, showInSubWindow, isModal);
    } else {
      this.showType(LoadingType.Info, undefined, msg.msg, msg.cancelCallBack, msg.alignment, msg.offset,
        msg.showInSubWindow, msg.isModal);
    }
  }

  showSuccess(
    msg: string | LoadingParam = '',
    cancelCallBack?: () => void,
    alignment?: DialogAlignment,
    offset?: Offset,
    showInSubWindow?: boolean,
    isModal?: boolean,
  ): void {
    if (typeof msg === 'string') {
      this.showType(LoadingType.Success, $r('app.media.startIcon'), msg, cancelCallBack, alignment, offset,
        showInSubWindow, isModal);
    } else {
      this.showType(LoadingType.Success, $r('app.media.startIcon'), msg.msg, msg.cancelCallBack, msg.alignment,
        msg.offset, msg.showInSubWindow, msg.isModal);
    }
  }

  showError(
    msg: string | LoadingParam = '',
    cancelCallBack?: () => void,
    alignment?: DialogAlignment,
    offset?: Offset,
    showInSubWindow?: boolean,
    isModal?: boolean,
  ): void {
    if (typeof msg === 'string') {
      this.showType(LoadingType.Error, $r('app.media.startIcon'), msg, cancelCallBack, alignment, offset,
        showInSubWindow, isModal);
    } else {
      this.showType(LoadingType.Error, $r('app.media.startIcon'), msg.msg, msg.cancelCallBack, msg.alignment,
        msg.offset, msg.showInSubWindow, msg.isModal);
    }
  }

  showType(
    type: LoadingType,
    image: Resource | undefined,
    msg: string,
    cancelCallBack?: () => void,
    alignment: DialogAlignment = DialogAlignment.Center,
    offset: Offset = { dx: 0, dy: 0 },
    showInSubWindow: boolean = false,
    isModal: boolean = false,
    useTmpHUD: boolean = true // 是否使用缓存的HUD
  ): void {
    let self: LoadingView | undefined = this;
    if (useTmpHUD && tmpHUDArray.length > 0) {
      self = tmpHUDArray.shift();
    };
    self?.showTypeReal(type, image, msg, cancelCallBack, alignment, offset, showInSubWindow, isModal);
  }

  private showTypeReal(
    type: LoadingType,
    image: Resource | undefined,
    msg: string,
    cancelCallBack?: () => void,
    alignment: DialogAlignment = DialogAlignment.Center,
    offset: Offset = { dx: 0, dy: 0 },
    showInSubWindow: boolean = false,
    isModal: boolean = false,
  ): void {
    this.hide();

    _cancelCallBack = cancelCallBack;

    let animate: AnimateParam = {
      duration: 90,
      delay: 0,
      curve: Curve.EaseInOut
    };

    _dialogController = new CustomDialogController({
      builder: _LoadingView({ type: type, image: image, msg: msg }),
      autoCancel: false,
      cancel: () => {
        _dialogController = null;
        if (_cancelCallBack) {
          _cancelCallBack();
        };
      },
      customStyle: true,
      alignment: alignment,
      offset: offset,
      maskColor: 0x33000000,
      openAnimation: animate,
      closeAnimation: animate,
      showInSubWindow: showInSubWindow,
      isModal: isModal, // api11是否有蒙层
    });
    _dialogController.open();
    if (type !== LoadingType.Loading) {
      let time: number = LoadingTime.baseTime;
      if (msg) {
        time += msg.length * LoadingTime.wordTime;
      }
      time = Math.max(time, LoadingTime.minTime);
      time = Math.min(time, LoadingTime.maxTime);
      setTimeout(() => {
        this.hide();
      }, time);
    }
  }

  hide() {
    if (_dialogController) {
      _dialogController.close();
      _dialogController = null;
      if (_cancelCallBack) {
        _cancelCallBack();
      }
    }
  }

  build() {
  }
}