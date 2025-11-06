import {mainMenuItems} from '../data/MainMenuItems';
import {MainMenuItem} from '../types/MainMenuItem';
import { ComponentContent, LengthMetrics, promptAction } from '@kit.ArkUI';
import { UIContext } from '@kit.ArkUI';
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute } from '@kit.ArkUI';
import {router} from '@kit.ArkUI'
import { common } from '@kit.AbilityKit';

@Builder
function buildText() {
  Column() {
    Text('Meet Point')
      .fontSize('36px')
      .fontWeight(FontWeight.Bold)
  }
}

@Entry
@Component
struct Index {

  @State mainMenuItems: MainMenuItem[] = mainMenuItems
  private watchSize: string = '466px'
  private listSize: string = '410px'

  context: UIContext = this.getUIContext()
  tabBar1: ComponentContent<Object> = new ComponentContent(this.context, wrapBuilder(buildText));




  aboutToAppear(): void {
  }

  build() {
    Column() {
      Stack() {
        ArcList({ initialIndex: 0, header: this.tabBar1 }) {
          ForEach(this.mainMenuItems, (item: MainMenuItem) => {
            ArcListItem() {
              Button({ type: ButtonType.Capsule }) {
                Row() {
                  Image(item.icon)
                    .width('64px')
                    .height('64px')
                    .margin({ right: '12px' })
                  Text(`${item.name}`)
                    .fontSize('36px')
                    .fontColor(Color.Black)
                    .fontWeight(FontWeight.Bold)
                }
                .justifyContent(FlexAlign.Center)
                .width('100%')
              }
              .width(this.listSize)
              .height('100px')
              .fontSize('24px')
              .fontColor(Color.Black)
              .fontWeight(FontWeight.Bold)
              .focusable(true)
              .opacity(0.9)
              .focusOnTouch(true)
              .backgroundColor('#f0f8ff')
            }.align(Alignment.Center).onClick(() => {

              router.pushUrl({
                url: `pages/${item.pageName}`
              });

            })

          }, (item: string, index: number) => item + index)
        }
        .space(LengthMetrics.px(10))
        .borderRadius(this.watchSize)
        .focusable(true)
        .focusOnTouch(true)
        .defaultFocus(true)
      }
      .align(Alignment.Center)
      .width(this.watchSize)
      .height(this.watchSize)
      .border({color: Color.Black, width: 3})
      .borderRadius(this.watchSize)
    }
    .height('100%')
    .width('100%')
  }
}