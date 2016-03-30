//
//  Alarm.h
//  Hjernevekker
//
//  Created by Espen Næss on 22.12.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Alarm : NSManagedObject

@property (nonatomic, retain) NSString *alarmstatus;
@property (nonatomic, retain) NSString *gjentagelser;
@property (nonatomic, retain) NSString *musikkvalg;
@property (nonatomic, retain) NSString *navn;
@property (nonatomic, retain) NSString *tidAlarm;

/// Lager et NSDictionary-objekt av alarmen
- (NSDictionary *)somOrdbok;

/// Lagrer alarmegenskaper fra en NSDictionary*
- (BOOL)fraOrdbok:(NSDictionary *)ordbok;

@end
