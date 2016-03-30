//
//  Verinnstillinger.h
//  Hjernevekker
//
//  Created by Erik Bråthen Solem on 23.01.14.
//  Copyright (c) 2014 Espen Næss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Verinnstillinger : UIViewController <UITextFieldDelegate> {
    UITextField *postnummerfelt;
}

- (IBAction)Tilbake:(id)sender;

@end
