import { addFriend } from '../utils/FriendUtils';
import { common } from '@kit.AbilityKit';
import { prompt, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct AddFriendPage {
  @State name: string = '';
  private async saveFriend() {
    if (!this.name.trim()) {
      promptAction.showToast({ message: 'Please fill all fields' });
      return;
    }

    try {
      await addFriend(this.name).then(() => {
        prompt.showToast({
          message: `${this.name} added successfully`,
          duration: 2000
        });
        setTimeout(() => {
          this.getUIContext().getRouter().back();
        }, 1000);
      })
        .catch((error: BusinessError) => {
          prompt.showToast({
            message: 'Error deleting friend: ' + error.message,
            duration: 3000
          });
          console.error('Adding error:', error);
        });
    } catch (error) {
      promptAction.showToast({ message: 'Friend Adding Error!' });
    }
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          TextInput({ placeholder: 'Full Name' })
            .width('70%')
            .height(50)
            .fontSize(18)
            .margin({ top: 40, bottom: 10 })
            .padding(10)
            .border({ width: 1, color: Color.White, radius: 15 })
            .onChange((value: string) => {
              this.name = value;
            })

          Button('Save')
            .width('70%')
            .height(50)
            .fontSize(18)
            .backgroundColor(this.name ? '#007AFF' : '#ccc')
            .enabled(!!this.name)
            .onClick(() => {
              this.saveFriend();
            })
            .margin({ bottom: 20 })

        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

}