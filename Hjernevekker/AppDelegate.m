//
//  AppDelegate.m
//  Hjernevekker
//
//  Created by Espen Næss on 28.10.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Alarmdata.h"
#import "EnkelMatte.h"
#import "VanskeligMatte.h"
#import "HentVerData.h"
#import "Velkommen.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

BOOL startFraBakgrunn;
NSUserDefaults *lager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Initialiserer viewcontrolleren
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // nytt ved iOS 8
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *initViewController = [storyBoard instantiateInitialViewController];
    [self.window setRootViewController:initViewController];
    
    lager = [NSUserDefaults standardUserDefaults];
    
    // Starter og hente væroppdateringer
    lokalisasjonsManager = [[CLLocationManager alloc] init];
    lokalisasjonsManager.delegate = self;
    lokalisasjonsManager.distanceFilter = kCLDistanceFilterNone;
    lokalisasjonsManager.desiredAccuracy = kCLLocationAccuracyBest;
    [lokalisasjonsManager requestWhenInUseAuthorization];
    [lokalisasjonsManager requestAlwaysAuthorization];
    
    [self startVerOppdateringer];
    
    // Får lyden til å kjøre i bakgrunnen
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // Sjekker om det har vært notifikasjoner (om app var terminert)
    UILocalNotification *varsel = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    if (varsel) {
        [self VisAlarmForVarsel:varsel];
    }
    
    if (![lager boolForKey:@"TidlStartet"]) {
        [lager setBool:YES forKey:@"TidlStartet"];
        [lager setBool:YES forKey:@"lommelykt"];
        Velkommen *velkommenView = [storyBoard instantiateViewControllerWithIdentifier:@"Velkommen"];
        [self.window.rootViewController presentViewController:velkommenView animated:NO completion:nil];
    }
    return YES;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"lokasjonsforespørsel usendt");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"lokalisasjon begrenset");
            break;
        case kCLAuthorizationStatusDenied:
        {
            NSLog(@"lokaliasjon nektet");
        }
            break;
        default:{
            [lokalisasjonsManager startUpdatingLocation];
        }
            break;
    }
}

- (void)startVerOppdateringer {
    NSString *postnummer = [lager objectForKey:@"postnummer"];
    if (postnummer) {
        [[HentVerData alloc] HentVerDataForPostnummer:postnummer];
    } else {
        [self OppdaterVer];
    }
    [self performSelector:@selector(startVerOppdateringer) withObject:nil afterDelay:60*15];
}

- (void)OppdaterVer {
    [lokalisasjonsManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self HentPostNummer:newLocation];
    [lokalisasjonsManager stopUpdatingLocation];
}

- (void)HentPostNummer:(CLLocation *)lokalisasjon {
    CLGeocoder* reverseGeocoder = [[CLGeocoder alloc] init];
    if (reverseGeocoder) {
        [reverseGeocoder reverseGeocodeLocation:lokalisasjon completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks firstObject];
            if (placemark) {
                NSString *postnr = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressZIPKey];
                NSLog(@"POSTNUMMERET: %@", postnr);
                [[HentVerData alloc] HentVerDataForPostnummer:postnr];
            }
        }];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if (startFraBakgrunn) {[self VisAlarmForVarsel:notification];}
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Henter alarmer
    NSMutableArray *alarmArray;
    NSMutableArray *NavnArray = [[NSMutableArray alloc] init];
    NSMutableArray *TidArray = [[NSMutableArray alloc] init];
    NSMutableArray *DagArray = [[NSMutableArray alloc] init];
    
    
    [Alarmdata les:&alarmArray];
    
    for (NSManagedObject *obj in alarmArray) {
        if ([[obj valueForKey:@"alarmstatus"] isEqualToString:@"on"]) {
            NSString *NavnString = [obj valueForKey:@"navn"];
            [NavnArray addObject:NavnString];
            NSString *TidString = [[obj valueForKey:@"tidAlarm"] stringByAppendingString:@":00"];
            [TidArray addObject:TidString];
            NSString *DagString = [obj valueForKey:@"gjentagelser"];
            [DagArray addObject:DagString];
        }
    }
    
    // Setter varsler for alarmer (a = alarm, d = valgte dager, n = notifikasjon)
    NSDate *fyredato = [NSDate date];
    int iDag = [Alarmdata ukedagFraDato:fyredato]; // 0 mandag, 1 tirsdag ..
    // Sjekker vekkegrad og henter repetisjoner for varsler
    int vekkegrad = (2+[[lager objectForKey:@"ValgtVekkegrad"] intValue])*2;
    
    // Tar bort klokkeslettet ved å lagre en streng som tida skal legges til
    NSDateFormatter *dformat = [[NSDateFormatter alloc] init];
    [dformat setDateFormat:@"yyyy-MM-dd"];
    NSString *fdato = [dformat stringFromDate:fyredato];
    [dformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    for (int a = 0; a < [TidArray count]; a++) {
        int valgte = [[DagArray objectAtIndex:a] intValue];
        if (valgte == 0) valgte = 127;
        for (int d = 0; d < 7; d++) {
            // Ser om alarmen skal kjøres den aktuelle dagen
            if ((1 << d) & valgte) {
                // Antall dager fram i tid alarmen skal fyres av
                int leggTil = (d - iDag) % 7;
                for (int n = 0; n < vekkegrad; n++) {
                    // Finn fyredatoen og legg til dager og sekunder
                    fyredato = [[dformat dateFromString:[NSString stringWithFormat:@"%@ %@", fdato, [TidArray objectAtIndex:a]]] dateByAddingTimeInterval:(86400*leggTil + 30*n /*+ ([[NSTimeZone systemTimeZone] isDaylightSavingTime] ? 0 : 3600)*/)];
                    
                    // sørger for at datoene legges til i fremtiden
                    if ([[NSDate date] timeIntervalSinceDate:fyredato] > 0) {
                        NSDateComponents *datokomp = [[NSDateComponents alloc] init];
                        [datokomp setWeekOfMonth:1];
                        NSCalendar *kalender = [NSCalendar currentCalendar];
                        fyredato = [kalender dateByAddingComponents:datokomp toDate:fyredato options:0];
                    }
                    
                    // Stille inn egenskapene til varselet og aktiver det
                    UILocalNotification *varsel = [[UILocalNotification alloc] init];
                    [varsel setFireDate:fyredato];
                    [varsel setTimeZone:[NSTimeZone systemTimeZone]];
                    [varsel setAlertBody:[[NavnArray objectAtIndex:a] isEqualToString:@""] ? @"Alarm" : [NavnArray objectAtIndex:a]];
                    [varsel setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber]+1];
                    [varsel setSoundName:@"Klassisk.mp3"];
                    [varsel setRepeatInterval:NSWeekCalendarUnit];
                    [[UIApplication sharedApplication] scheduleLocalNotification:varsel];
                }
            }
        }
    }
    
    NSLog(@"%lu", (unsigned long)[[[UIApplication sharedApplication] scheduledLocalNotifications] count]);
    for (UILocalNotification *varsel in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        NSLog(@"%@", varsel.fireDate);
    }
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)VisAlarmForVarsel:(UILocalNotification *)notification {
    NSArray *alarmViews = @[@"Matte1",@"Matte2"];
    if ([[alarmViews objectAtIndex:arc4random() % [alarmViews count]] isEqualToString:@"Matte1"]) {
        EnkelMatte *enkelMatte = [storyBoard instantiateViewControllerWithIdentifier:@"EnkelMatte"];
        [enkelMatte setNavnForAlarm:[notification alertBody]];
        [enkelMatte setMusikkForAlarmen:[Alarmdata lydvalg:0]];
        [self.window.rootViewController presentViewController:enkelMatte animated:YES completion:nil];
    }
    else {
        VanskeligMatte *vanskeligMatte = [storyBoard instantiateViewControllerWithIdentifier:@"VanskeligMatte"];
        [vanskeligMatte setNavnForAlarm:[notification alertBody]];
        [vanskeligMatte setMusikkForAlarmen:[Alarmdata lydvalg:0]];
        [self.window.rootViewController presentViewController:vanskeligMatte animated:YES completion:nil];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    startFraBakgrunn = YES;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [NSThread sleepForTimeInterval:2];
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Hjernevekker" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Hjernevekker.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
