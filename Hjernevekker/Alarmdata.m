//
//  Alarmdata.m
//  Hjernevekker
//
//  Created by Espen Næss on 19.01.14.
//  Copyright (c) 2014 Espen Næss. All rights reserved.
//

#import "Alarmdata.h"
#import "AppDelegate.h"

@implementation Alarmdata

/// 1 = mandag, 2 = tirsdag, 4 = onsdag, 8 = torsdag, 16 = fredag, 32 = lørdag, 64 = søndag
int const dager[] = {1, 2, 4, 8, 16, 32, 64};
char const *streng[] = {"hei", "du"};

/* strtol(tall, NULL, 10)
const char *spurnader[][6] = {
    {"3", "EnkelAlgebra:", "Gangestykke:", "BrokIProsent:"},
    {"5", "MiddelsAlgebra:", "EnkelAlgebra:", "Gangestykke:", "Kvadratrot:", "BrokIProsent:"},
    {"4", "Logaritme:", "MiddelsAlgebra:", "Kvadratrot:"}};
 */

// Funksjoner tilhørende vekking

+ (NSString *)matteSpm:(NSString **)fasit {
    NSUserDefaults *lager = [NSUserDefaults standardUserDefaults];
    NSInteger v, vEmner = [lager integerForKey:@"ValgtMattegrad"];
    NSArray *emner = [self matteSpm];
    
    // Plukk fra alle emner dersom brukeren ikke har valgt noe som helst
    vEmner = (vEmner == 0) ? 31 : vEmner;
    
    // Plukk et tilfeldig valgt emne blant brukerens valgte
    do {
        v = arc4random_uniform((int)[emner count]);
    } while (!((1 << v) & vEmner));
    SEL s = NSSelectorFromString([[emner objectAtIndex:v] stringByAppendingString:@":"]);
    return [self methodForSelector:s](self, s, fasit);
}

+ (NSArray *)matteSpm {
    return @[@"Gangestykker", @"Kvadratrot", @"Logaritmer", @"Plusstykker", @"Minusstykker", @"Potensregnestykker"];
}

// Funksjoner - lager og løser matematikkspørsmål

+ (NSString *)Logaritmer:(NSString **)svar {
    double logaritmetall = pow(10, arc4random() % 8);
    NSString *Spurnad = [NSString stringWithFormat:@"Hva er logaritmen til %.f?", logaritmetall];
    *svar = [NSString stringWithFormat:@"%.f", log10(logaritmetall)];
    
    return Spurnad;
}

+ (NSString *)Kvadratrot:(NSString **)svar {
    int s = arc4random_uniform(9) + 2;
    *svar = [NSString stringWithFormat:@"%d", s];
    return [NSString stringWithFormat:@"Hva er kvadratroten av %d?",s * s];
}

+ (NSString *)Potensregnestykker:(NSString **)svar {
    int s = arc4random_uniform(5) + 2;
    int n = arc4random_uniform(4) + 2;
    NSString *nTegn = [NSString stringWithUTF8String:"\u207F"];
    NSString *spurnad = [NSString stringWithFormat:@"%i%@ = %.f", s, nTegn, pow(s, n)];
    *svar = [NSString stringWithFormat:@"%i", n];
    
    return spurnad;
}

+ (NSString *)Gangestykker:(NSString **)svar {
    int tall1 = 1 + arc4random_uniform(10);
    int tall2 = 1 + arc4random_uniform(10);
    NSString *Spurnad = [NSString stringWithFormat:@"Hva er %d ganger %d", tall1, tall2];
    *svar = [NSString stringWithFormat:@"%d", tall1 * tall2];
    
    return Spurnad;
}

+ (NSString *)Plusstykker:(NSString **)svar {
    int tall1 = 1 + arc4random_uniform(100);
    int tall2 = 1 + arc4random_uniform(100);
    NSString *Spurnad = [NSString stringWithFormat:@"Hva er %i pluss %i", tall1, tall2];
    *svar = [NSString stringWithFormat:@"%d", tall1 + tall2];
    
    return Spurnad;
}

+ (NSString *)Minusstykker:(NSString **)svar {
    int tall1 = 1 + arc4random_uniform(100);
    int tall2 = tall1 + arc4random_uniform(100);
    NSString *Spurnad = [NSString stringWithFormat:@"Hva er %i minus %i", tall2, tall1];
    *svar = [NSString stringWithFormat:@"%d", tall2 - tall1];
    return Spurnad;
}

+ (NSDictionary *)Fysiskordbok {
    return @{@"Shake": @"● Rist telefonen 10 ganger (0/10)", /*@"Snurr": @"● Snurr rundt 5 ganger (0/5)"*/};
}

// Funksjoner tilhørende vær

+ (NSDictionary *)verSymbolerDag {
    return @{@"1":@"1d", @"2":@"2d", @"3":@"3d", @"4":@"4", @"40":@"40d", @"5":@"5d", @"41":@"41d", @"24": @"24d", @"6":@"6d", @"25":@"6d", @"42":@"7d", @"7": @"7d", @"43":@"7d", @"26":@"20d", @"20":@"20d", @"27":@"20d", @"44":@"44d", @"8":@"8d", @"45":@"45d", @"28":@"29d", @"29":@"29d", @"21":@"21d", @"46":@"46", @"9":@"9", @"10":@"10", @"30":@"30",@"22":@"22",@"11":@"22", @"47":@"48", @"12":@"48",@"48":@"48",@"31":@"23",@"23":@"23",@"23":@"32",@"49":@"49",@"13":@"13",@"50":@"50", @"33":@"33",@"14":@"14", @"34":@"14",@"15":@"15"};
}
+ (NSDictionary *)verSymbolerNatt {
    return @{@"1": @"1n",@"2":@"3n",@"3":@"3n",@"4":@"4",@"40":@"46",@"5":@"9",@"41":@"41n",@"24":@"30", @"6":@"22",@"25":@"22",@"42":@"48",@"7":@"48",@"43":@"48",@"20":@"23",@"27":@"23",@"44":@"49", @"8":@"13",@"45":@"50",@"28":@"33",@"21":@"14",@"29":@"14",@"46":@"46", @"9":@"9", @"10":@"10", @"30":@"30",@"22":@"22",@"11":@"22", @"47":@"48",@"12":@"48",@"48":@"48",@"31":@"23",@"23":@"23",@"23":@"32",@"49":@"49",@"13":@"13",@"50":@"50",@"33":@"33",@"14":@"14",@"34":@"14",@"15":@"15"};
}

/**
 ** Funksjoner ukedager og gjentaking
 **/

+ (int)ukedagFraDato:(NSDate *)dato {
    // Finner ukedagnummeret i dag
    NSDateFormatter *datoformat = [[NSDateFormatter alloc] init];
    [datoformat setLocale:[NSLocale currentLocale]];
    [datoformat setDateFormat:@"e"];
    int iDag = [[datoformat stringFromDate:dato] intValue];
    
    // Finner første ukedag
    NSCalendar *c = [NSCalendar currentCalendar];
    [c setLocale:[NSLocale currentLocale]];
    int fDag = (int)[c firstWeekday];
    
    // Kompenserer for kalenderforskjeller og returnerer ekte ukedagnummer
    return (iDag + fDag - 3) % 7;

}

+ (int)iDagErValgt:(int)valgte {
    if (valgte == 0) return 1;
    return [self er:[self ukedagFraDato:[NSDate date]] blant:valgte];
}

+ (int)er:(int)ukedag blant:(int)valgte {
    return valgte & dager[ukedag];
}

+ (int)skift:(int)ukedag blant:(int)valgte {
    return valgte ^ dager[ukedag];
}

+ (NSString *)ukedag:(int)u medStil:(stil)s {
    NSDateFormatter *datoformat = [[NSDateFormatter alloc] init];
    NSArray *ukedager = (s == ukedagFull ? [datoformat weekdaySymbols] : [datoformat shortWeekdaySymbols]);
    
    return [ukedager objectAtIndex:(u + 1) % 7];
}

+ (NSString *)ukedager:(int)u medStil:(stil)s {
    NSDateFormatter *datoformat = [[NSDateFormatter alloc] init];
    NSArray *ukedager = (s == ukedagFull ? [datoformat weekdaySymbols] : [datoformat shortWeekdaySymbols]);
    
    NSMutableArray *a = [[NSMutableArray alloc] init];
    for (int i = 0; i < 7; i++) {
        if (dager[i] & u) [a addObject:[ukedager objectAtIndex:(i + 1) % 7]];
    }
    
    return [a componentsJoinedByString:@" "];
}

/**
 ** Funksjoner tilhørende valg av alarmlyd
 **/

+ (NSArray *)lydvalg {
    return @[@"Klassisk", @"Kykkeliky", @"Evakueringsirene", @"Nedtellingsirene"];
}


+ (NSString *)lydvalg:(int)vedIndeks {
    NSArray *lyder = [self lydvalg];
    if (vedIndeks >= 0 && vedIndeks < [lyder count]) {
        return [lyder objectAtIndex:vedIndeks];
    } else {
        return @"";
    }
}

/**
 ** Funksjoner for CoreData
 **/

/// Lagrer dataen
+ (NSError *)lagre {
    NSManagedObjectContext *kontekst = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *feil = nil;
    return [kontekst save:&feil] ? nil : feil;
}

/// Leser inn alle lagra alarmer
+ (NSError *)les:(NSMutableArray **)alarmer {
    // Les dataene
    NSManagedObjectContext *kontekst = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *spurning = [[NSFetchRequest alloc] initWithEntityName:@"Alarm"];
    [spurning setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"tidAlarm" ascending:YES]]];
    
    NSError *feil = nil;
    *alarmer = [[kontekst executeFetchRequest:spurning error:&feil] mutableCopy];
    return feil;
}

/// Sletter alle lagra alarmer
+ (NSError *)slettAlarmer {
    NSManagedObjectContext *kontekst = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *spurning = [[NSFetchRequest alloc] initWithEntityName:@"Alarm"];
    NSError *feil = nil;
    NSArray *alarmer = [kontekst executeFetchRequest:spurning error:&feil];
    for (Alarm *a in alarmer) {
        [kontekst deleteObject:a];
    }
    
    return alarmer == nil ? feil : [self lagre];
}

/// Legger til en ny alarm i databasen
+ (NSError *)nyAlarm:(NSDictionary *)ordbok somAlarm:(Alarm **)alarm {
    NSManagedObjectContext *kontekst = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    Alarm *ny = [NSEntityDescription insertNewObjectForEntityForName:@"Alarm" inManagedObjectContext:kontekst];
    [ny setValuesForKeysWithDictionary:ordbok];
    
    NSError *feil = nil;
    [kontekst save:&feil];
    *alarm = ny;
    return feil;
}

/// Slett én enkelt alarm
+ (NSError *)slettAlarm:(Alarm *)alarm {
    NSManagedObjectContext *kontekst = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSError *feil = nil;
    [kontekst deleteObject:alarm];
    [kontekst save:&feil];
    return feil;
}

@end
