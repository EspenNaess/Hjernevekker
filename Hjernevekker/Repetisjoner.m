//
//  Repetisjoner.m
//  Hjernevekker
//
//  Created by Espen Næss on 16.11.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import "Repetisjoner.h"
#import "Alarmdata.h"

@interface Repetisjoner ()

@end

@implementation Repetisjoner

@synthesize valgte;

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
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Setter opp cellene
    UITableViewCell *celle = [tableView dequeueReusableCellWithIdentifier:@"DagCeller"];
    celle = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DagCeller"];
    
    // Bruk systemspråkets navn på ukedagen
    [[celle textLabel] setText:[[Alarmdata ukedag:(int)[indexPath row] medStil:ukedagFull] capitalizedString]];
    
    // Merk av raden dersom ukedagen er valgt
    [celle setAccessoryType:([Alarmdata er:(int)[indexPath row] blant:valgte] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)];
    
    return celle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Slå ukedagen av/på
    [self setValgte:[Alarmdata skift:(int)[indexPath row] blant:[self valgte]]];
    
    // Merk av raden dersom ukedagen er valgt
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:([Alarmdata er:(int)[indexPath row] blant:valgte] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    // Dispose of any resources that can be recreated.
}

@end
