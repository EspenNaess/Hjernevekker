//
//  EnkelMatte.h
//  Hjernevekker
//
//  Created by Espen Næss on 01.02.14.
//  Copyright (c) 2014 Espen Næss. All rights reserved.
//

#import "Alarm.h"
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

@interface EnkelMatte : UIViewController <CLLocationManagerDelegate> {
    IBOutlet UILabel *Klokke;
    IBOutlet UILabel *Spurnad;
    IBOutlet UILabel *Status;
    IBOutlet UILabel *Navn;
    
    IBOutlet UILabel *TaskFysisk;
    IBOutlet UILabel *TaskTeoretisk;
    
    NSArray *EnkleSpurnader;
    NSArray *MiddelsSpurnader;
    NSArray *VanskeligSpurnader;
    NSArray *FysiskeSpurningar;
    
    IBOutlet UIButton *Alternativ1;
    IBOutlet UIButton *Alternativ2;
    IBOutlet UIButton *Alternativ3;
    IBOutlet UIButton *Alternativ4;
    
    NSMutableArray *MatteAlternativer;
    
    AVAudioPlayer *MusikkSpiller;
    
    NSString *ValgtFysiskOppgave;
    
    NSString *Mattesvar;
}
@property (nonatomic, strong) NSString *MusikkForAlarmen;
@property (nonatomic, strong) NSString *NavnForAlarm;

- (IBAction)KnappKlikket:(UIButton *)knapp;
- (void)Vibrer;
- (void)Tid;

@end
