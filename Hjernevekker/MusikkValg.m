//
//  MusikkValg.m
//  Hjernevekker
//
//  Created by Espen Næss on 14.12.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import "MusikkValg.h"
#import "Alarmdata.h"

@interface MusikkValg ()

@end

@implementation MusikkValg

NSArray *lyder;

@synthesize musikkvalg;

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
    lyder = [Alarmdata lydvalg];
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Erstatter Ferdig
    return;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [lyder count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Sett opp celler
    UITableViewCell *celle = [tableView dequeueReusableCellWithIdentifier:@"Celle"];
    celle = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Celle"];
    
    [celle setAccessoryType:([self musikkvalg] == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)];
    [[celle textLabel] setText:[lyder objectAtIndex:indexPath.row]];
    return celle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Velg ny lyd
    NSIndexPath *valgt = [NSIndexPath indexPathForRow:[self musikkvalg] inSection:0];
    if (valgt && ([[tableView cellForRowAtIndexPath:valgt] accessoryType] == UITableViewCellAccessoryCheckmark)) {
        [[tableView cellForRowAtIndexPath:valgt] setAccessoryType:UITableViewCellAccessoryNone];
    }
    [self setMusikkvalg:indexPath.row];
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Spiller av lyden
    NSString *ValgtMusikk = [[Alarmdata lydvalg] objectAtIndex:indexPath.row];
    NSString *Lyd = [[NSBundle mainBundle] pathForResource:ValgtMusikk ofType:@"mp3"];
    NSURL *LydURL = [NSURL fileURLWithPath:Lyd];
    MusikkSpiller = [[AVAudioPlayer alloc] initWithContentsOfURL:LydURL error:nil];
    [MusikkSpiller play];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? @"Lyder" : @"";
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
