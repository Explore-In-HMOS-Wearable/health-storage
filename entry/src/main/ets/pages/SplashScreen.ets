import { getPurchaseType, initHealthPrefs } from '../utils/PreferencesManager'
import { abilityAccessCtrl, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import hilog from '@ohos.hilog';
import { getGlobalContext } from '../entryability/EntryAbility';

@Entry
@Component
struct SplashScreen {
  private purchaseType = 'none'
  pathStack: NavPathStack = new NavPathStack()
  private context: common.UIAbilityContext = getGlobalContext();
  private permissions : Array<Permissions> = ['ohos.permission.ACTIVITY_MOTION', 'ohos.permission.READ_HEALTH_DATA']

  async requestPermissions(permissions: Array<Permissions>, context: Context) {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(context, permissions)
      .then((data: PermissionRequestResult) => {
        hilog.info(0x0000, '',
          `Permissions have been granted`)
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, '',
          `Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
      })
  }

  async aboutToAppear(): Promise<void> {
    await this.requestPermissions(this.permissions,this.context)
    await initHealthPrefs(this.context)
    this.purchaseType = await getPurchaseType()
    if(this.purchaseType === 'none') {
      this.pathStack.pushPathByName('PurchaseProduct',null)
    }
    else {
      this.pathStack.pushPathByName('HealthData',null)
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        LoadingProgress()
      }
    }
    .mode(NavigationMode.Stack)
  }
}