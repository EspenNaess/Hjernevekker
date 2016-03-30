//
//  ViewController.h
//  Hjernevekker
//
//  Created by Espen Næss on 26.10.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//
#import "Alarm.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController {
    NSMutableArray *AlarmArray;
    NSMutableArray *AlarmUkeArray;
    NSMutableArray *AlarmLydArray;
    NSMutableArray *AlarmNavnArray;
    IBOutlet UILabel *Dato;
    IBOutlet UILabel *Dag;
    IBOutlet UILabel *KlokkeLabel;
    IBOutlet UILabel *bakgrunn;
    
    NSString *MusikkForAlarm;
    NSString *NavnForAlarmen;
    Alarm *kjorendeAlarm;
    
    NSArray *MatteViews;
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *Kontekst;
@property (nonatomic, strong) IBOutlet UIImageView *VerTegn;
@property (nonatomic, weak) IBOutlet UILabel *VaerLabel;

- (IBAction)TekstKlikk:(id)sender;

- (void)lastOm;
- (void)Tidsinstans:(id)sender;
- (void)VaerKlikk:(id)sender;



@end
