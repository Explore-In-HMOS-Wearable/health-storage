import sensor from '@ohos.sensor';
import { BusinessError } from '@kit.BasicServicesKit';
import {getPurchaseType} from '../utils/PreferencesManager';
import { healthDataManager } from '../utils/HealthDataManager';
import { HeartRateRecord, StepCountRecord } from '../types/HealthRecords'

@Builder
export function HealthDataBuilder() {
  HealthData()
}

@Component
struct HealthData {

  @State heartRateList: HeartRateRecord[] = [];
  @State stepCountList: StepCountRecord[] = [];
  @State heartRate: number = 0;
  @State stepCount: number = 0;
  @State isMonitoring: boolean = false;
  @State purchaseType: string = 'none';
  private lastHeartRateSave: number = 0;
  private readonly SAVE_INTERVAL: number = 60000;

  startHeartRateMonitoring() {
    const INTERVAL = 5000;
    try {
      sensor.on(sensor.SensorId.HEART_RATE, async (data: sensor.HeartRateResponse) => {
        this.heartRate = data.heartRate
        const now = Date.now();
        if (now - this.lastHeartRateSave >= this.SAVE_INTERVAL) {
          healthDataManager.addHeartRate(this.heartRate)
          this.lastHeartRateSave = now;
          this.heartRateList = await healthDataManager.getAllHeartRates();
        }
      }, { interval: INTERVAL });

    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`Failed to invoke on. Code: ${e.code}, message: ${e.message}`);
    }
  }

  startStepCountMonitoring() {

    try {
      sensor.on(sensor.SensorId.PEDOMETER, async (data: sensor.PedometerResponse) => {
        this.stepCount = data.steps
        healthDataManager.addStepCount(this.stepCount)
      }, { interval: 5000 });
      setTimeout(() => {

        sensor.off(sensor.SensorId.PEDOMETER);
      }, 500);

    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`Failed to invoke on. Code: ${e.code}, message: ${e.message}`);
    }
  }

  async aboutToAppear()  {

    this.heartRateList = await healthDataManager.getAllHeartRates()
    this.stepCountList = await healthDataManager.getAllStepCounts()
    this.purchaseType = await getPurchaseType()
    this.startHeartRateMonitoring()
    if(this.purchaseType === 'EXTRA') {
      this.startStepCountMonitoring();
    }
  }

  build() {
    NavDestination() {
      Column() {
        Swiper() {
          Column() {
            Text('Heart Rate')
              .fontSize(18)
            Text(`${this.heartRate} BPM`)
              .fontSize(30)
              .fontColor(Color.Red)
          }
          .width('100%')

          Column() {
            Text('Step Count')
              .fontSize(18)
            Text(this.purchaseType === 'EXTRA' ? `${this.stepCount}` : 'You Need To Buy Extra')
              .fontSize(30)
              .fontColor(Color.Red)

          }
          .width('100%')

          Column() {
            Text('Recent Heart Rates')
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)


            if (this.heartRateList.length === 0) {
              Text('No heart rate data yet')
                .fontSize(16)
                .fontColor('#888888')
                .textAlign(TextAlign.Center)
            } else {
              List({ space: 10 }) {
                ForEach(this.heartRateList, (item: HeartRateRecord, index: number) => {
                  ListItem() {
                    Row() {
                      Column() {
                        Text(`${item.heartRate} BPM`)
                          .fontSize(18)
                          .fontColor(Color.White)
                          .fontWeight(FontWeight.Medium)

                        Text(item.time)
                          .fontSize(14)
                          .fontColor('#AAAAAA')
                      }
                      .alignItems(HorizontalAlign.Start)

                      Text(item.date)
                        .fontSize(12)
                        .fontColor('#666666')
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceBetween)
                    .padding(15)
                    .backgroundColor('#2A2A2A')
                    .borderRadius(12)
                  }
                })
              }
              .layoutWeight(1)
              .width('100%')
              .padding(10)
            }
          }
          .width('100%')
          .height('100%')

          Column() {
            Text('Recent Step Counts')
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)

            if (this.stepCountList.length === 0) {
              Text('No step count data yet')
                .fontSize(16)
                .fontColor('#888888')
                .textAlign(TextAlign.Center)
            } else {
              List({ space: 10 }) {
                ForEach(this.stepCountList, (item: StepCountRecord, index: number) => {
                  ListItem() {
                    Row() {
                      Column() {
                        Text(`${item.stepCount} steps`)
                          .fontSize(18)
                          .fontColor(Color.White)
                          .fontWeight(FontWeight.Medium)

                        Text(item.time)
                          .fontSize(14)
                          .fontColor('#AAAAAA')
                      }
                      .alignItems(HorizontalAlign.Start)

                      Text(item.date)
                        .fontSize(12)
                        .fontColor('#666666')
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceBetween)
                    .padding(15)
                    .backgroundColor('#2A2A2A')
                    .borderRadius(12)
                  }
                })
              }
              .layoutWeight(1)
              .width('100%')
              .padding(10)
            }
          }
          .width('100%')
          .height('100%')
        }
        .loop(false)
        .vertical(false)
        .indicator(false)
        .duration(300)
      }
      .width('100%')
      .height('100%')

    }
  }
}

