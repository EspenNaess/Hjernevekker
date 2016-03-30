//
//  LommelyktInnstillinger.m
//  Hjernevekker
//
//  Created by Espen Næss on 14.11.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import "LommelyktInnstillinger.h"

@interface LommelyktInnstillinger ()

@end

@implementation LommelyktInnstillinger

NSUserDefaults *lager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    lager = [NSUserDefaults standardUserDefaults];
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *celle = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"innstillinger"];
    [[celle textLabel] setText:@"Lommelykt på hjemskjerm"];
    
    bryter = [[UISwitch alloc] initWithFrame:CGRectMake(240, 8, 0, 0)];
    BOOL lommelykt = [lager boolForKey:@"lommelykt"];
    [bryter setOn:lommelykt ? true : false];
    [[celle contentView] addSubview:bryter];
    
    return celle;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [lager setBool:[bryter isOn] forKey:@"lommelykt"];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"Dobbeltklikk på bakgrunnen på hovedskjermen for å slå på lommelykta";
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    [banner setAlpha:1];
    [UIView commitAnimations];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    [banner setAlpha:0];
    [UIView commitAnimations];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
