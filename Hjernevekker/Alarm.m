//
//  Alarm.m
//  Hjernevekker
//
//  Created by Espen Næss on 22.12.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import "Alarm.h"
#import "Alarmdata.h"

@implementation Alarm

@dynamic alarmstatus;
@dynamic gjentagelser;
@dynamic musikkvalg;
@dynamic navn;
@dynamic tidAlarm;

- (NSDictionary *)somOrdbok {
    return @{@"alarmstatus": [self alarmstatus], @"gjentagelser" : [self gjentagelser], @"musikkvalg" : [self musikkvalg], @"navn" : [self navn], @"tidAlarm" : [self tidAlarm]};
}

- (BOOL)fraOrdbok:(NSDictionary *)ordbok {
    @try {
        [self setAlarmstatus:[ordbok objectForKey:@"alarmstatus"]];
        [self setGjentagelser:[ordbok objectForKey:@"gjentagelser"]];
        [self setMusikkvalg:[ordbok objectForKey:@"musikkvalg"]];
        [self setNavn:[ordbok objectForKey:@"navn"]];
        [self setTidAlarm:[ordbok objectForKey:@"tidAlarm"]];
    } @catch (NSException *e) {
        NSLog(@"%@", e);
        return false;
    }
    return true;
}

@end
