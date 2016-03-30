//
//  Instillinger.m
//  Hjernevekker
//
//  Created by Espen Næss on 05.11.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import "Instillinger.h"

@implementation Instillinger

NSArray *meny, *overganger, *deler;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    meny = @[@[@"Fargetema", @"Været"], @[@"Lommelykt"], @[@"Vekkeinnstillinger"]]; // menynavn
    overganger = @[@[@"fargetema", @"veret"], @[@"lommelykt"], @[@"vekking"]]; // overgangsnavn
    deler = @[@"Visning", @"Alarmer", @"Generelt"]; // navn på delene
    [super viewDidLoad];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 2 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *celle = [tableView dequeueReusableCellWithIdentifier:@"Innstillinger"];
    celle = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Innstillinger"];
    [celle setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [[celle textLabel] setText:[[meny objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]]];
    
    return celle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:[[overganger objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]] sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [deler objectAtIndex:section];
}

/// Funksjonen gjør ingenting annet enn å virke som et anker
- (IBAction)innstillingerValgt:(UIStoryboardSegue *)segue {
    return;
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
