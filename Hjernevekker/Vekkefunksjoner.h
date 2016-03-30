//
//  Vekkefunksjoner.h
//  Hjernevekker
//
//  Created by Espen Næss on 15.12.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface Vekkefunksjoner : UIViewController <ADBannerViewDelegate> {
    UIButton *tilbakeKnapp;
}

@property (nonatomic, setter = erFraVelkommenvindu:) BOOL kommerFraVelkommenVindu;

@end
