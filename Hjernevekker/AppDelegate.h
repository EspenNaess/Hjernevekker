//
//  AppDelegate.h
//  Hjernevekker
//
//  Created by Espen Næss on 28.10.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate> {
    UIStoryboard *storyBoard;
    CLLocationManager *lokalisasjonsManager;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)VisAlarmForVarsel:(UILocalNotification *)notification;
- (void)HentPostNummer:(CLLocation *)lokalisasjon;
- (void)OppdaterVer;

@end
