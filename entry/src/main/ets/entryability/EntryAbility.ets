import { AbilityConstant, common, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import relationalStore from '@ohos.data.relationalStore';

export class GlobalContext {
  // Static property replaces the global 'let'
  static abilityContext: common.UIAbilityContext | null = null;
}

export class GlobalRdbStore {
  static rdbStore: relationalStore.RdbStore
}

interface StoreConfig {
  name: string;
  securityLevel: relationalStore.SecurityLevel;
  encrypt?: boolean;
}

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
 public async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
   GlobalContext.abilityContext = this.context;
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

   const FRIENDSTREE_CONFIG: StoreConfig = {
     name: 'MeetPointDB.db',
     securityLevel: relationalStore.SecurityLevel.S1,
     encrypt: false
   }

   const SQL_CREATE_FRIENDS_TABLE = `
    CREATE TABLE IF NOT EXISTS friends (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      latitude REAL,
      longitude REAL
    )
    `;

   try {
     GlobalRdbStore.rdbStore = await relationalStore.getRdbStore(this.context, FRIENDSTREE_CONFIG);
     await GlobalRdbStore.rdbStore.executeSql(SQL_CREATE_FRIENDS_TABLE);
   } catch (error) {
     hilog.error(DOMAIN, 'DataAbility', 'RDB error: %{public}s', JSON.stringify(error));
   }

  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/SplashScreen', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}

export function getGlobalContext(): common.UIAbilityContext {
  if (!GlobalContext.abilityContext) {
    throw new Error('Global context is not initialized. Make sure EntryAbility is created.');
  }
  return GlobalContext.abilityContext;
}