import { Friend } from '../types/Friend';
import router from '@ohos.router';
import { deleteFriend, updateFriend } from '../utils/FriendUtils';
import { common } from '@kit.AbilityKit';
import prompt from '@ohos.prompt';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct FriendPage {
  @State friend: Friend | null = null;
  @State showEditPopup: boolean = false;
  @State editName: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Friend;
    if (params) {
      this.friend = {
        id: params.id,
        name: params.name,
        latitude: params.latitude,
        longitude: params.longitude
      }
      this.editName = params.name;
    }
  }

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

          prompt.showToast({
            message: 'Friend updated successfully',
            duration: 2000
          });
        })
        .catch((error: BusinessError) => {
          prompt.showToast({
            message: 'Error updating friend: ' + error.message,
            duration: 3000
          });
          console.error('Update error:', error);
        });
    } else {
      prompt.showToast({
        message: 'Please enter valid name and phone number',
        duration: 2000
      });
    }
  }

  onDeleteClick(): void {
    prompt.showDialog({
      title: 'Delete Friend',
      message: `Are you sure you want to delete ${this.friend?.name}?`,
      buttons: [
        {
          text: 'No',
          color: '#000000'
        },
        {
          text: 'Yes',
          color: '#FF3B30'
        }
      ]
    }).then((data) => {
      if (data.index === 1) {
        if (this.friend) {
          deleteFriend(this.friend.id)
            .then(() => {
              prompt.showToast({
                message: `${this.friend?.name} deleted successfully`,
                duration: 2000
              });
              setTimeout(() => {
                router.back();
              }, 1000);
            })
            .catch((error: BusinessError) => {
              prompt.showToast({
                message: 'Error deleting friend: ' + error.message,
                duration: 3000
              });
              console.error('Delete error:', error);
            });
        }
      }
    });
  }

  onCancelEdit(): void {
    if (this.friend) {
      this.editName = this.friend.name;
    }
    this.showEditPopup = false;
  }

  build() {
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
              .backgroundColor('#007DFF')
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
          .backgroundColor('#000000')
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
              .backgroundColor('#007DFF')
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
  }
}