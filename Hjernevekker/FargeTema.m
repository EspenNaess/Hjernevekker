//
//  FargeTema.m
//  Hjernevekker
//
//  Created by Espen Næss on 05.11.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import "FargeTema.h"

@interface FargeTema ()

@end

@implementation FargeTema

NSArray *fargenavn;
NSUserDefaults *lager;
long valgt;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    fargenavn = @[@"Blå", @"Rød", @"Gul", @"Grønn", @"Grå", @"Lilla", @"Oransje"];
    lager = [NSUserDefaults standardUserDefaults];
    valgt = [lager integerForKey:@"Farge"];
    
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fargenavn count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *celle = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FargeTemaerCeller"];
    
    [celle setAccessoryType:([indexPath row] == valgt ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)];
    [[celle textLabel] setText:[fargenavn objectAtIndex:[indexPath row]]];
    
    return celle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:valgt inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    valgt = [indexPath row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [lager setInteger:valgt forKey:@"Farge"];
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
