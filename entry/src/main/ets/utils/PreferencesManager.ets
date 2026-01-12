// utils/PreferencesManager.ets
import preferences from '@ohos.data.preferences';

const PREF_NAME = 'health_pref';
let healthPrefs: preferences.Preferences | null = null;
let isInitialized: boolean = false;

export async function initHealthPrefs(context: Context): Promise<boolean> {
  try {
    healthPrefs = await preferences.getPreferences(context, PREF_NAME);
    isInitialized = true;
    console.info('Preferences initialized successfully');
    return true;
  } catch (err) {
    console.error('Failed to initialize preferences:', err);
    return false;
  }
}

export async function savePurchaseType(purchaseType: string): Promise<boolean> {
  if (!healthPrefs || !isInitialized) {
    console.error('Preferences not initialized');
    return false;
  }

  try {
    await healthPrefs.put('purchaseType', purchaseType);
    await healthPrefs.flush(); // ⭐ BU ÇOK ÖNEMLİ!
    console.info('Purchase type saved:', purchaseType);
    return true;
  } catch (err) {
    console.error('Failed to save purchase type:', err);
    return false;
  }
}

export async function getPurchaseType(): Promise<string> {
  if (!healthPrefs || !isInitialized) {
    console.error('Preferences not initialized when getting purchase type');
    return 'none';
  }

  try {
    const value = await healthPrefs.get('purchaseType', 'none');
    console.info('Retrieved purchase type:', value);
    return value.toString();
  } catch (err) {
    console.error('Failed to get purchase type:', err);
    return 'none';
  }
}

export function isPrefsInitialized(): boolean {
  return isInitialized && healthPrefs !== null;
}