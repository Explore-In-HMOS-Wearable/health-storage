// utils/PreferencesManager.ets
import preferences from '@ohos.data.preferences';

const PREF_NAME = 'health_pref';
let healthPrefs: preferences.Preferences | null = null;
let isInitialized: boolean = false;

export async function initHealthPrefs(context: Context): Promise<boolean> {
  try {
    healthPrefs = await preferences.getPreferences(context, PREF_NAME);
    isInitialized = true;
    return true;
  } catch (err) {
    return false;
  }
}

export async function savePurchaseType(purchaseType: string): Promise<boolean> {
  if (!healthPrefs || !isInitialized) {
    return false;
  }

  try {
    await healthPrefs.put('purchaseType', purchaseType);
    await healthPrefs.flush(); // ⭐ BU ÇOK ÖNEMLİ!
    return true;
  } catch (err) {
    return false;
  }
}

export async function getPurchaseType(): Promise<string> {
  if (!healthPrefs || !isInitialized) {
    return 'none';
  }

  try {
    const value = await healthPrefs.get('purchaseType', 'none');
    return value.toString();
  } catch (err) {
    return 'none';
  }
}

export function isPrefsInitialized(): boolean {
  return isInitialized && healthPrefs !== null;
}