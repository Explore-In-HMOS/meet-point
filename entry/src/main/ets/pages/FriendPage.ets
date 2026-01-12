import { Friend } from '../types/Friend';
import { deleteFriend, updateFriend } from '../utils/FriendUtils';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

@Builder
export function FriendPageBuilder() {
  FriendPage()
}

@Component
struct FriendPage {
  @State friend: Friend | null = null;
  @State showEditPopup: boolean = false;
  @State editName: string = '';
  @Consume pathStack: NavPathStack

  onEditClick(): void {
    this.showEditPopup = true;
  }

  onSaveEdit(): void {
    if (this.friend && this.editName.trim()) {
      const updatedFriend: Friend = {
        id: this.friend.id,
        name: this.editName,
        latitude: this.friend.latitude,
        longitude: this.friend.longitude
      };

      updateFriend(updatedFriend.id, updatedFriend.name)
        .then(() => {
          this.friend = updatedFriend;
          this.showEditPopup = false;

          promptAction.openToast({
            message: 'Friend updated successfully',
            duration: 2000
          });
        })
        .catch((error: BusinessError) => {
          promptAction.openToast({
            message: `${error.message}`,
            duration: 3000
          });
          console.error('Update error:', error);
        });
    } else {
      promptAction.openToast({
        message: 'Please enter valid name and phone number',
        duration: 2000
      });
    }
  }

  onDeleteClick(): void {
    if (this.friend) {
      deleteFriend(this.friend.id)
        .then(() => {
          promptAction.openToast({
            message: `${this.friend?.name} deleted successfully`,
            duration: 2000
          });
          setTimeout(() => {
            this.pathStack.pop()
          }, 1000);
        })
        .catch((error: BusinessError) => {
          promptAction.openToast({
            message: `${error.message}`,
            duration: 3000
          });
          console.error('Delete error:', error);
        });
    }
  }

  onCancelEdit(): void {
    if (this.friend) {
      this.editName = this.friend.name;
    }
    this.showEditPopup = false;
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          if (this.friend) {
            Column() {
              Text(this.friend.name)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 10 });
            }
            .width('100%')
            .padding(20)
            .justifyContent(FlexAlign.Center)

            Row() {
              Button('Edit')
                .onClick(() => this.onEditClick())
                .backgroundColor(Color.Blue)
                .width(60)
                .margin({ right: 20 });

              Button('Delete')
                .onClick(() => this.onDeleteClick())
                .backgroundColor('#FF3B30')
                .width(60);
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
          } else {
            Text('Friend not found')
              .fontSize(18)
              .margin({ bottom: 20 });
          }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        if (this.showEditPopup) {

          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(Color.Black)
            .opacity(0.9)
            .onClick(() => this.onCancelEdit())
            .position({ x: 0, y: 0 })
            .zIndex(1)

          Column() {
            TextInput({ text: this.editName })
              .onChange((value: string) => {
                this.editName = value;
              })
              .height(50)
              .width('90%')
              .margin({ bottom: 15 })
              .padding(10)
              .borderRadius(8)
              .borderWidth(1)
              .borderColor('#CCCCCC');

            Row() {
              Button('Cancel')
                .onClick(() => this.onCancelEdit())
                .backgroundColor('#CCCCCC')
                .width(70)
                .margin({ right: 15 });

              Button('Save')
                .onClick(() => this.onSaveEdit())
                .backgroundColor(Color.Blue)
                .width(70);
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .alignItems(HorizontalAlign.Center)
          .borderRadius(16)
          .zIndex(1)
        }
      }
      .width('100%')
      .height('100%')
    }.onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
      const params = context.pathInfo.param as Friend
      if (params) {
        this.friend = {
          id: params.id,
          name: params.name,
          latitude: params.latitude,
          longitude: params.longitude
        }
        this.editName = params.name;
      }

    })
    .hideTitleBar(true)
  }
}