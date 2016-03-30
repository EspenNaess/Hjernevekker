//
//  Velkommen.m
//  Hjernevekker
//
//  Created by Espen Næss on 13.04.14.
//  Copyright (c) 2014 Espen Næss. All rights reserved.
//

#import "Velkommen.h"
#import "Vekkefunksjoner.h"
@interface Velkommen ()

@end

@implementation Velkommen

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [UIView animateWithDuration:1 animations:^{
        [tekstInfo setAlpha:1];
    } completion:^(BOOL ferdig){
        [UIView animateWithDuration:2 animations:^{
            [Fortsett setAlpha:1];
        }];
    }];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)Fortsett:(id)sender {
    [self performSegueWithIdentifier:@"Velkommen" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    Vekkefunksjoner *vekkeFunk = [segue destinationViewController];
    [vekkeFunk erFraVelkommenvindu:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
