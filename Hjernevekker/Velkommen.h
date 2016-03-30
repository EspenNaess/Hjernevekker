//
//  Velkommen.h
//  Hjernevekker
//
//  Created by Espen Næss on 13.04.14.
//  Copyright (c) 2014 Espen Næss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Velkommen : UIViewController {
    IBOutlet UITextView *tekstInfo;
    IBOutlet UIButton *Fortsett;
}

- (IBAction)Fortsett:(id)sender;

@end
