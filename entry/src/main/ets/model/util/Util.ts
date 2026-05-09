import { pasteboard } from "@kit.BasicServicesKit";
import promptAction from '@ohos.promptAction';
import { common } from "@kit.AbilityKit";
import { fileIo } from '@kit.CoreFileKit';
import fs from '@ohos.file.fs';
import image from '@ohos.multimedia.image';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

export class Util {
  /*复制文本*/
  static copyText(text :string) {
    let data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    pasteboard.getSystemPasteboard().setDataSync(data);
    this.toast('复制成功');
  }

  /*toast提示*/
  static toast(text :string) {
    promptAction.openToast({
      message: text,
      duration: 2000,
      bottom: 100
    })
  }

  /*svg字符串保存为文件并返回路径*/
  static async svgToTempFile(
    context: common.UIAbilityContext,
    svg: string
  ): Promise<string> {

    const filePath = `${context.cacheDir}/svg_${Date.now()}.svg`;

    const file = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
    await fs.write(file.fd, svg);
    await fs.close(file.fd);

    return filePath;
  }

  /*请求写入相册的权限*/
  static async requestWriteMediaPermission(context) : Promise<boolean> {
    const permission = 'ohos.permission.WRITE_IMAGEVIDEO'
    const atManager = abilityAccessCtrl.createAtManager();
    let result = await atManager.requestPermissionsFromUser(context, [
      permission
    ]);

    let isGranted = result.authResults[0] === 0;
    if (!isGranted) {
      // cxx_test 弹窗提示
    }

    return isGranted;
  }

  /*把svg文件转成png的PixelMap对象*/
  static async svgToPngAndSaveToPhoto(context, svgFilePath, size) {
    let imageSource = image.createImageSource(svgFilePath);
    let pixelMap :image.PixelMap
    try {
      pixelMap = await imageSource.createPixelMap({
        desiredSize: { width: size, height: size },
      });
    } catch (e) {
      console.error('svgToPngAndSaveToPhoto error: ' + JSON.stringify(e))
    }

    let imagePacker = image.createImagePacker();
    let buffer = await imagePacker.packToData(pixelMap, {
      format: "image/png",
      quality: 100
    });

    await this.savaPngBufferToPhoto(context, buffer)
  }
  static async savaPngBufferToPhoto(context, buffer) {
    let imageResource = image.createImageSource(buffer);
    let opts: image.DecodingOptions = { editable: true };
    let pixel = await imageResource.createPixelMap(opts);

    let helper = photoAccessHelper.getPhotoAccessHelper(context);
    let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
    let file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    let imagePackerApi = image.createImagePacker();
    let packOpts: image.PackingOption = { format: "image/png", quality: 100 };

    imagePackerApi.packToFile(pixel, file.fd, packOpts, (err) => {
      if (err) {
        console.error(`Failed to pack the image to file.code ${err.code},message is ${err.message}`);
      } else {
        console.info('Succeeded in packing the image to file.');
        imagePackerApi.release((err) => {
          if (err) {
            console.error(`Failed to release the image source instance.code ${err.code},message is ${err.message}`);
          } else {
            console.info('Succeeded in releasing the image source instance.');
            fileIo.close(file.fd);
          }
        })
        this.toast('已保存至相册！')
      }
    })
  }
}