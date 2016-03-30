//
//  OpprettAlarm.h
//  Hjernevekker
//
//  Created by Espen Næss on 27.10.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "Alarm.h"

@interface OpprettAlarm : UIViewController <UITextFieldDelegate, ADBannerViewDelegate> {
    IBOutlet UIDatePicker *VelgDato;
    UISlider *Volum;
    IBOutlet UITableView *Meny;
    IBOutlet UINavigationBar *Navigasjonsbar;
    UITextField *navn;
}

@property (nonatomic) BOOL endre; // Sett til YES om alarmen endres, ellers NO
@property (nonatomic, retain) Alarm *alarm;

@end
