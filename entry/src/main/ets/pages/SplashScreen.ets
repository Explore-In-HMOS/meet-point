import { abilityAccessCtrl, bundleManager, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { getGlobalContext } from '../entryability/EntryAbility';


@Entry
@Component
struct SplashScreen {

  private context: common.UIAbilityContext = getGlobalContext();

  async checkPermissions() {
    const permissions: Array<Permissions> = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION_IN_BACKGROUND'];
    let allGranted = true;
    for (let permission of permissions) {
      let grantStatus: abilityAccessCtrl.GrantStatus = await this.checkAccessToken(permission);
      if (grantStatus !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        allGranted = false;
        break;
      }
    }

    if (allGranted) {
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/Index'
      })
    } else {
      this.requestPermissions();
    }
  }


  requestPermissions(): void {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(this.context, ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'])
      .then((data: PermissionRequestResult) => {
        this.checkPermissionsAfterRequest();
      })
      .catch((err: BusinessError) => {
        console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
        this.getUIContext().getRouter().pushUrl({
          url: 'pages/Index'
        })
      });
  }

  async checkPermissionsAfterRequest() {
    const permissions: Array<Permissions> = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];
    let allGranted = true;

    for (let permission of permissions) {
      let grantStatus: abilityAccessCtrl.GrantStatus = await this.checkAccessToken(permission);
      if (grantStatus !== abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        allGranted = false;
        break;
      }
    }

    if (allGranted) {
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/Index'
      })
    } else {
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/Index'
      })
    }
  }

  async checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    try {
      let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

      let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      console.info('Succeeded in getting Bundle.');
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      let tokenId: number = appInfo.accessTokenId;

      grantStatus = await atManager.checkAccessToken(tokenId, permission);
      console.info('Succeeded in checking access token.');
      return grantStatus;
    } catch (error) {
      console.error('Error checking access token:', error);
      return abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;
    }
  }

  aboutToAppear(): void {
    this.checkPermissions();
  }

  build() {
    Stack() {
      LoadingProgress()
    }
    .height('100%')
    .width('100%')
  }
}