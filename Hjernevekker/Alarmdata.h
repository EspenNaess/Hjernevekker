//
//  Alarmdata.h
//  Hjernevekker
//
//  Created by Espen Næss on 19.01.14.
//  Copyright (c) 2014 Espen Næss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Alarm.h"

@interface Alarmdata : NSObject

typedef enum Stil {
    ukedagKort,
    ukedagFull
} stil;

/// Finner ukedagnummer fra dato
+ (int)ukedagFraDato:(NSDate *)dato;

/// Ser etter om dagen i dag er blant de valgte ukedagene
+ (int)iDagErValgt:(int)valgte;

/// Ser etter om en dag er valgt (antar mandag = 0, søndag = 6)
+ (int)er:(int)ukedag blant:(int)valgte;

/// Legger til / fjerner en ukedag fra valgte (antar mandag = 0, søndag = 6)
+ (int)skift:(int)ukedag blant:(int)valgte;

/// Gir tilbake (ett) ukedagnavn fra en int der mandag = 0, søndag = 6
+ (NSString *)ukedag:(int)u medStil:(stil)s;

/// Gir tilbake ukedagnavn fra en int i intervallet [0, 127]
+ (NSString *)ukedager:(int)u medStil:(stil)s;

/// Gir tilbake alle tilgjengelige lydvalg
+ (NSArray *)lydvalg;

/// Gir tilbake lydvalg ved bestemt indeks
+ (NSString *)lydvalg:(int)vedIndeks;

// Core Data
+ (NSError *)lagre;
+ (NSError *)les:(NSMutableArray **)alarmer;
+ (NSError *)slettAlarmer;
+ (NSError *)nyAlarm:(NSDictionary *)ordbok somAlarm:(Alarm **)alarm;
+ (NSError *)slettAlarm:(Alarm *)alarm;

// Mattefunksjoner
+ (NSString *)matteSpm:(NSString **)fasit;
+ (NSDictionary *)Fysiskordbok;
+ (NSArray *)matteSpm;

+ (NSString *)Logaritmer:(NSString **)svar;
+ (NSString *)Gangestykker:(NSString **)svar;
+ (NSString *)Kvadratrot:(NSString **)svar;
+ (NSString *)Plusstykker:(NSString **)svar;
+ (NSString *)Minusstykker:(NSString **)svar;
+ (NSString *)Potensregnestykker:(NSString **)svar;

// Værfunksjoner
+ (NSDictionary *)verSymbolerDag;
+ (NSDictionary *)verSymbolerNatt;

@end
