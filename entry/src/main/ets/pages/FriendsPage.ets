import {Friend} from '../types/Friend';
import {getFriends} from '../utils/FriendUtils';
import { common} from '@kit.AbilityKit';
import { LengthMetrics } from '@kit.ArkUI';
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute } from '@kit.ArkUI';
import {router} from '@kit.ArkUI'

@Builder
function buildText() {
  Column() {
    Text('Friends')
      .fontSize('36px')
      .fontWeight(FontWeight.Bold)
  }
}

@Entry
@Component
struct FriendsPage {

  @State friends: Friend[] = [];

  private watchSize: string = '466px';
  private listSize: string = '410px';

  private navigateToAddFriend() {
    router.pushUrl({
      url: 'pages/AddFriendPage'
    });
  }


  private async loadFriends() {
    try {
      const friends = await getFriends();
      this.friends= friends;
    } catch (error) {
      console.error('Failed to load friends:', error);
    }
  }

  onPageShow(): void {
    this.loadFriends();
  }

  build() {
    Column() {
      Stack() {
        ArcList({ initialIndex: 0 }) {
          ArcListItem() {
            Button({ type: ButtonType.Capsule }) {
              Row() {
                Text('+ Add Friend')
                  .fontSize('24px')
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
            .backgroundColor('#e6f7ff')
            .onClick(() => {
              this.navigateToAddFriend();
            })
          }.align(Alignment.Center)
          ForEach(this.friends, (item: Friend) => {
            ArcListItem() {
              Button({ type: ButtonType.Capsule }) {
                Column() {
                  Text(item.name)
                    .fontSize('34px')
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.Black)
                    .textAlign(TextAlign.Center)
                    .width('100%')
                    .margin({ bottom: 1 })
                }
                .width('100%')
                .padding(10)
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
            }.align(Alignment.Center)
            .onClick(() => {
              router.push({
                url: 'pages/FriendPage',
                params: item
              });
            })

          }, (friend: Friend) => friend.name)
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