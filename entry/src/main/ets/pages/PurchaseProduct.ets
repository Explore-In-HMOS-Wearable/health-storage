import { productTypes } from '../data/ProductTypes';
import { ProductType } from '../types/ProductType';
import { iap } from '@kit.IAPKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { getGlobalContext } from '../entryability/EntryAbility';
import {savePurchaseType} from '../utils/PreferencesManager';

@Builder
export function PurchaseProductBuilder() {
  PurchaseProduct()
}

@Component
struct PurchaseProduct {

  private context: common.UIAbilityContext = getGlobalContext();
  private currentIndex: number = 0;
  pathStack: NavPathStack = new NavPathStack()

  createPurchase(context: common.UIAbilityContext, purchaseType: string) {
    const parameter: iap.PurchaseParameter = {
      productType: iap.ProductType.CONSUMABLE,
      productId: 'test_product_1',
      developerPayload: 'test developer payload string.'
    }
    iap.createPurchase(this.context, parameter).then((data: iap.CreatePurchaseResult) => {
      savePurchaseType(purchaseType)
      console.info(`Succeeded in creating purchase. data: ${data.purchaseData}`);
      this.pathStack.pushPathByName('HealthData',null)
    }).catch((err: BusinessError) => {
      // The request failed.
      savePurchaseType(purchaseType)
      console.error(`Failed to create purchase. Code is ${err.code}, message is ${err.message}`);
      this.pathStack.pushPathByName('HealthData',null)
    });
  }

  build() {
    NavDestination() {
      Column() {
        Swiper() {
          ForEach(productTypes, (item: ProductType, index: number) => {
            Column() {
              Text(item.name)
                .fontSize(20)
                .fontColor('#CCCCCC')
                .fontWeight(FontWeight.Bold)

              Text(item.description)
                .fontSize(16)
                .fontColor('#CCCCCC')

              Text(`${item.price}`)
                .fontSize(18)
                .fontColor('#CCCCCC')

              Button('BUY NOW', { type: ButtonType.Capsule, stateEffect: true })
                .width(120)
                .height(40)
                .backgroundColor('#4CAF50')
                .fontColor(Color.White)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ top: 10 })
                .onClick(() => {
                  this.createPurchase(this.context, item.name)
                })
            }
            .width('100%')
            .height(200)
            .borderRadius(16)

          })
        }
        .loop(false)
        .vertical(false)
        .indicator(false)
        .duration(300)
        .onChange((index: number) => {
          this.currentIndex = index;
          console.info(`Current index: ${index}`);
        })
      }
      .width('100%')
      .height('100%')

    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })

  }
}