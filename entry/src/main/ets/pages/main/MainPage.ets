import { kRandomPages } from '../../model/object/RandomSource';
import { DuckPage } from '../random/duck/DuckPage';
import { ShapeStackPage } from '../random/shape_stack/ShapeStackPage';
import { UglyPage } from '../random/ugly/UglyPage';
import { RandomListTabPage } from './RandomListTabPage';
import { SettingTabPage } from './SettingTabPage';
import { BlobbyPage } from '../random/blobby/BlobbyPage';
import { SmilePage } from '../random/smile/SmilePage';
import { KawaiiPage } from '../random/kawaii/KawaiiPage';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;

  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack();

  readonly normalIconSize :SizeOptions = { width: 22, height: 22 }
  readonly selectedIconSize :SizeOptions = { width: 24, height: 24 }
  readonly normalFontSize = 11
  readonly selectedFontSize = 13

  build() {
    Navigation(this.navPathStack) {
      Tabs({
        index: this.currentIndex,
        barPosition: BarPosition.End,
      }) {
        TabContent() {
          RandomListTabPage()
        }
        .tabBar(
          this.tabItemBuilder('随机头像', 0, $r('app.media.tab_random'), $r('app.media.tab_random_on'))
        )

        TabContent() {
          SettingTabPage()
        }
        .tabBar(
          this.tabItemBuilder('设置', 1, $r('app.media.tab_set'), $r('app.media.tab_set_on'))
        )
      }
      .onSelected((index) => {
        this.currentIndex = index
      })
      .scrollable(false)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .navDestination(this.pageMap)
    .navBarPosition(NavBarPosition.Start)
    .title(this.currentIndex == 0 ? '随机头像' : '')
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
  }

  @Builder
  pageMap(name: string) {
    if (name === kRandomPages.shapeStack) {
      ShapeStackPage()
    } else if (name === kRandomPages.ugly) {
      UglyPage()
    } else if (name === kRandomPages.duck) {
      DuckPage()
    } else if (name === kRandomPages.blobby) {
      BlobbyPage()
    } else if (name === kRandomPages.smile) {
      SmilePage()
    } else if (name === kRandomPages.kawaii) {
      KawaiiPage()
    }
  }

  @Builder
  /* 构建tab项 */
  tabItemBuilder(title: ResourceStr, targetIndex: number, normalImg: Resource, selectedImg: Resource) {
    Column({space: 5}) {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size(this.currentIndex === targetIndex ? this.selectedIconSize: this.normalIconSize)
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? $r('app.color.black33') : $r('app.color.grey77'))
        .fontSize(this.currentIndex === targetIndex ? this.selectedFontSize : this.normalFontSize)
    }
    .width('100%')
    .height(52)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}