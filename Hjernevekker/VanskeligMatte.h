//
//  VanskeligMatte.h
//  Hjernevekker
//
//  Created by Espen Næss on 09.12.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import "Alarm.h"
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

@interface VanskeligMatte : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate> {
    IBOutlet UITextField *SvarTekstFelt;
    IBOutlet UILabel *Spurnad;
    IBOutlet UILabel *Klokke;
    IBOutlet UILabel *StatusTittel;
    IBOutlet UILabel *TaskMatte;
    IBOutlet UILabel *TaskFysisk;
    IBOutlet UILabel *Navn;
    
    NSArray *FysiskeSpurningar;
    NSTimer *vibrering;
    
    int AntallShake;
    
    BOOL FysiskFerdig;
    BOOL TeoretiskFerdig;
    
    NSString *Mattesvar;
    
    NSString *ValgtFysiskOppgave;
    
    AVAudioPlayer *MusikkSpiller;
}

@property (nonatomic, strong) NSString *MusikkForAlarmen;
@property (nonatomic, strong) NSString *NavnForAlarm;

- (void)HenteMatteOppgave;
- (void)Vibrer;
- (void)tid;

@end
