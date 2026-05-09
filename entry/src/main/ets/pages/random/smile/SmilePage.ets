import { RetroButton } from "../../../view/RetroButton";
import { Util } from "../../../model/util/Util";
import { common } from "@kit.AbilityKit";

import fileUri from '@ohos.file.fileuri';
import { getBoolean, getContrast, getRandomColor, getUnit, hashCode} from './model/SmileUtil'
import { SmileObjectLiteralInterface } from "./model/SmileObjectLiteralInterface";


@Entry
@Component
export struct SmilePage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State svgUri :string = ''
  svgString :string = ''
  filePath :string = ''
  readonly imgSize = 240
  readonly SIZE = 36

  /*随机生成*/
  async randomAction() {
    const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

    let square = true
    let id = this.generateRandomString(8)
    let name = this.generateRandomString(12)

    const colors: string[] = [];
    for (let i = 0; i < 10; i++) {
      colors.push(this.getRandomHexColor());
    }

    const numFromName = hashCode(name);
    const range = colors && colors.length;
    const wrapperColor = getRandomColor(numFromName, colors, range);
    const preTranslateX = getUnit(numFromName, 10, 1);
    const wrapperTranslateX =
      preTranslateX < 5 ? preTranslateX + this.SIZE / 9 : preTranslateX;
    const preTranslateY = getUnit(numFromName, 10, 2);
    const wrapperTranslateY =
      preTranslateY < 5 ? preTranslateY + this.SIZE / 9 : preTranslateY;

    const data: SmileObjectLiteralInterface = {
      wrapperColor: wrapperColor,
      faceColor: getContrast(wrapperColor),
      backgroundColor: getRandomColor(numFromName + 13, colors, range),
      wrapperTranslateX: wrapperTranslateX,
      wrapperTranslateY: wrapperTranslateY,
      wrapperRotate: getUnit(numFromName, 360),
      wrapperScale: 1 + getUnit(numFromName, this.SIZE / 12) / 10,
      isMouthOpen: getBoolean(numFromName, 2),
      isCircle: getBoolean(numFromName, 1),
      eyeSpread: getUnit(numFromName, 5),
      mouthSpread: getUnit(numFromName, 3),
      faceRotate: getUnit(numFromName, 10, 3),
      faceTranslateX: wrapperTranslateX > this.SIZE / 6 ?
        wrapperTranslateX / 2 : getUnit(numFromName, 8, 1),
      faceTranslateY: wrapperTranslateY > this.SIZE / 6 ?
        wrapperTranslateY / 2 : getUnit(numFromName, 7, 2),
    };

    let mouthPath = ''
    if (data.isMouthOpen) {
      mouthPath = `
		  <path
		    d='M15 ${19 + data.mouthSpread}c2 1 4 1 6 0'
		    stroke='${data.faceColor}'
		    fill='none'
		    stroke-linecap='round'
		  />
		  `
    } else {
      mouthPath = `
		  <path
		    d='M13,${19 + data.mouthSpread} a1,0.75 0 0,0 10,0'
		    fill='${data.faceColor}'
		  />
		  `
    }
    let svg = `
			<svg
			  viewBox='0 0 ${this.SIZE} ${this.SIZE}'
			  fill='none'
			  role='img'
			  xmlns='http://www.w3.org/2000/svg'
			  width='${this.imgSize}'
			  height='${this.imgSize}'
			>
			  <mask
			    id='${id}'
			    maskUnits='userSpaceOnUse'
			    x='0'
			    y='0'
			    width='${this.SIZE}'
			    height='${this.SIZE}'
			  >
			    <rect
			      width='${this.SIZE}'
			      height='${this.SIZE}'
			      rx='${!square ? this.SIZE * 2 : 0}'
			      fill='#FFFFFF'
			    />
			  </mask>
			  <g mask='url(#${id})'>
			    <rect width='${this.SIZE}' height='${this.SIZE}' fill='${data.backgroundColor}' />
			    <rect
			      x='0'
			      y='0'
			      width='${this.SIZE}'
			      height='${this.SIZE}'
			      transform='translate(${data.wrapperTranslateX} ${data.wrapperTranslateY}) rotate(${data.wrapperRotate} ${this.SIZE / 2} ${this.SIZE / 2}) scale(${data.wrapperScale})'
			      fill='${data.wrapperColor}'
			      rx='${data.isCircle ? this.SIZE : this.SIZE / 6}'
			    />
			    <g
			      transform='translate(${data.faceTranslateX} ${data.faceTranslateY}) rotate(${data.faceRotate} ${this.SIZE / 2} ${this.SIZE / 2})'
			    >
			      ${mouthPath}
			      <rect
			        x='${14 - data.eyeSpread}'
			        y='14'
			        width='1.5'
			        height='2'
			        rx='1'
			        stroke='none'
			        fill='${data.faceColor}'
			      />
			      <rect
			        x='${20 + data.eyeSpread}'
			        y='14'
			        width='1.5'
			        height='2'
			        rx='1'
			        stroke='none'
			        fill='${data.faceColor}'
			      />
			    </g>
			  </g>
			</svg>
	`
    this.svgString = svg.replaceAll(/[\t\n]/g, '');
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

  /*随机色值*/
  getRandomHexColor() :string {
    return '#' + Math.floor(Math.random() * 16777215).toString(16).padStart(6, '0');
  }

  /*随机字符串*/
  generateRandomString(length: number = 12) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
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

