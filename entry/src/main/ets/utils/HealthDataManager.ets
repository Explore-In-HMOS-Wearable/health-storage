import { HeartRateRecord, StepCountRecord } from '../types/HealthRecords'
import { getGlobalContext } from '../entryability/EntryAbility';
import { common } from '@kit.AbilityKit';

import relationalStore from '@ohos.data.relationalStore';

interface StoreConfig {
  name: string;
  securityLevel: relationalStore.SecurityLevel;
  encrypt?: boolean;
}

class HealthDataManager {

  private static rdbStore: relationalStore.RdbStore
  private static instance: HealthDataManager;

  public static getInstance(): HealthDataManager {
    if (!HealthDataManager.instance) {
      HealthDataManager.instance = new HealthDataManager();
    }
    return HealthDataManager.instance;
  }


  private rdbStore: relationalStore.RdbStore | null = null;
  private context: common.UIAbilityContext = getGlobalContext();
  private readonly HEART_RATE_TABLE = 'heart_rate';
  private readonly STEP_COUNT_TABLE = 'step_count';

  private readonly SQL_CREATE_HEART_RATE_TABLE = `
    CREATE TABLE IF NOT EXISTS ${this.HEART_RATE_TABLE} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      timestamp INTEGER NOT NULL,
      heart_rate INTEGER NOT NULL,
      date TEXT NOT NULL,
      time TEXT NOT NULL,
      sensor_type TEXT DEFAULT 'auto'
    )
  `;

  private readonly SQL_CREATE_STEP_COUNT_TABLE = `
    CREATE TABLE IF NOT EXISTS ${this.STEP_COUNT_TABLE} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      timestamp INTEGER NOT NULL,
      step_count INTEGER NOT NULL,
      date TEXT NOT NULL,
      time TEXT NOT NULL,
      sensor_type TEXT DEFAULT 'auto'
    )
  `;

  async initializeDatabase(): Promise<void> {
    const config: StoreConfig = {
      name: 'HealthData.db',
      securityLevel: relationalStore.SecurityLevel.S1,
      encrypt: false
    };

    try {
      this.rdbStore = await relationalStore.getRdbStore(this.context, config);
      await this.rdbStore.executeSql(this.SQL_CREATE_HEART_RATE_TABLE);
      await this.rdbStore.executeSql(this.SQL_CREATE_STEP_COUNT_TABLE);
    } catch (error) {
    }
  }

  private async getRdbStore(): Promise<relationalStore.RdbStore> {
    if (!this.rdbStore) {
      await this.initializeDatabase();
    }
    return this.rdbStore!;
  }

  async addHeartRate(heartRate: number): Promise<void> {
    try {
      const store = await this.getRdbStore();
      const currentTime = new Date().getTime();
      const currentDate = new Date().toISOString().split('T')[0];
      const currentTimeString = new Date().toTimeString().split(' ')[0]; // HH:MM:SS

      const valuesBucket: relationalStore.ValuesBucket = {
        'timestamp': currentTime,
        'heart_rate': heartRate,
        'date': currentDate,
        'time': currentTimeString,
        'sensor_type': 'auto'
      };

      await store.insert(this.HEART_RATE_TABLE, valuesBucket);
    } catch (error) {
    }
  }

  async addStepCount(stepCount: number): Promise<void> {
    try {
      const store = await this.getRdbStore();
      const currentTime = new Date().getTime();
      const currentDate = new Date().toISOString().split('T')[0];
      const currentTimeString = new Date().toTimeString().split(' ')[0]; // HH:MM:SS

      const valuesBucket: relationalStore.ValuesBucket = {
        'timestamp': currentTime,
        'step_count': stepCount,
        'date': currentDate,
        'time': currentTimeString,
        'sensor_type': 'auto'
      };

      await store.insert(this.STEP_COUNT_TABLE, valuesBucket);
    } catch (error) {
    }
  }

  async getAllHeartRates(): Promise<HeartRateRecord[]> {
    try {
      const store = await this.getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.HEART_RATE_TABLE);
      predicates.orderByDesc('timestamp');

      const resultSet = await store.query(predicates,
        ['id', 'timestamp', 'heart_rate', 'date', 'time', 'sensor_type']);

      const records: HeartRateRecord[] = [];
      while (resultSet.goToNextRow()) {
        records.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          timestamp: resultSet.getLong(resultSet.getColumnIndex('timestamp')),
          heartRate: resultSet.getLong(resultSet.getColumnIndex('heart_rate')),
          date: resultSet.getString(resultSet.getColumnIndex('date')),
          time: resultSet.getString(resultSet.getColumnIndex('time')),
          sensorType: resultSet.getString(resultSet.getColumnIndex('sensor_type'))
        });
      }
      resultSet.close();
      return records;
    } catch (error) {
      return [];
    }
  }

  async getAllStepCounts(): Promise<StepCountRecord[]> {
    try {
      const store = await this.getRdbStore();
      const predicates = new relationalStore.RdbPredicates(this.STEP_COUNT_TABLE);
      predicates.orderByDesc('timestamp');

      const resultSet = await store.query(predicates,
        ['id', 'timestamp', 'step_count', 'date', 'time', 'sensor_type']);

      const records: StepCountRecord[] = [];
      while (resultSet.goToNextRow()) {
        records.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          timestamp: resultSet.getLong(resultSet.getColumnIndex('timestamp')),
          stepCount: resultSet.getLong(resultSet.getColumnIndex('step_count')),
          date: resultSet.getString(resultSet.getColumnIndex('date')),
          time: resultSet.getString(resultSet.getColumnIndex('time')),
          sensorType: resultSet.getString(resultSet.getColumnIndex('sensor_type'))
        });
      }
      resultSet.close();
      return records;
    } catch (error) {
      console.error('Failed to fetch all step counts:', error);
      return [];
    }
  }

}

export const healthDataManager = new HealthDataManager();