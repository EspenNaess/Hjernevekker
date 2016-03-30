//
//  Informasjon.h
//  Hjernevekker
//
//  Created by Espen Næss on 14.12.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Informasjon : UIViewController {
    IBOutlet UISegmentedControl *Tabbar;
    
    IBOutlet UITextView *Tekstboks1;
    IBOutlet UITextView *Tekstboks2;
    
    IBOutlet UILabel *label1;
    IBOutlet UILabel *label2;
    
    IBOutlet UIButton *KlikkeHer;
}

- (void)KlikkHer;

@end
