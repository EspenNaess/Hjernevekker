//
//  Alarmer.h
//  Hjernevekker
//
//  Created by Espen Næss on 27.10.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alarm.h"
#import "AppDelegate.h"
@interface Alarmer : UIViewController {
    IBOutlet UITableView *Tabell;
}

@property (nonatomic, retain) NSMutableArray *AlarmArray;
@property (nonatomic, retain) Alarm *_Alarm;

- (void)AlarmStatusEndret:(id)sender;

@end
