//
//  Vekkefunksjoner.m
//  Hjernevekker
//
//  Created by Espen Næss on 15.12.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import "Vekkefunksjoner.h"
#import "Alarmdata.h"

@interface Vekkefunksjoner ()

@end

@implementation Vekkefunksjoner
@synthesize kommerFraVelkommenVindu;

NSArray *vGrad; // vekkegrad
NSMutableArray *ValgteSpm; // mattespørsmål valgt
long vValg = 0; // valgt vekkegrad
NSUserDefaults *lager;

NSInteger vEmner = 0;
NSArray *emner;

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
    lager = [NSUserDefaults standardUserDefaults];
    ValgteSpm = [[NSMutableArray alloc] init];
    
    vGrad = @[@"Jeg våkner lett", @"Jeg har vansker med å våkne", @"Jeg våkner ikke"];
    vValg = [[lager objectForKey:@"ValgtVekkegrad"] intValue];
    
    ValgteSpm = [lager objectForKey:@"ValgtMattegrad"];
    
    vEmner = [lager integerForKey:@"ValgteEmner"];
    emner = [Alarmdata matteSpm];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    tilbakeKnapp = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [tilbakeKnapp setFrame:CGRectMake(kommerFraVelkommenVindu ? 255 : 6, 32, 60, 20)];
    [tilbakeKnapp setTitle:kommerFraVelkommenVindu ? @"Ferdig" : @"Tilbake" forState:UIControlStateNormal];
    [tilbakeKnapp.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [tilbakeKnapp addTarget:self action:@selector(Tilbake) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:tilbakeKnapp];
}

- (void)Tilbake {
    [lager setObject:[NSString stringWithFormat:@"%ld", vValg] forKey:@"ValgtVekkegrad"];
    [lager setInteger:vEmner forKey:@"ValgteEmner"];
    
    if (kommerFraVelkommenVindu) {
        [self performSegueWithIdentifier:@"InnstillingerFerdig" sender:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? [vGrad count] : [emner count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *celle = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"celle"];
    
    // Kryss av rette celler
    [celle setAccessoryType:(([indexPath section] == 0 && [indexPath row] == vValg) ?
                             UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone) ||
                             ([indexPath section] == 1 && (vEmner & (1 << [indexPath row]))) ?
                             UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
    
    // Still inn celleteksten
    [[celle textLabel] setText:([indexPath section] == 0 ?
                                [vGrad objectAtIndex:[indexPath row]] :
                                [emner objectAtIndex:[indexPath row]])];
    
    return celle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        // Skift merking (vekkegrad)
        [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:vValg inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        vValg = [indexPath row];
    } else {
        // Legg til eller fjern merking (matteemner)
        vEmner ^= (1 << [indexPath row]);
        UITableViewCell *celle = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[indexPath row] inSection:1]];
        [celle setAccessoryType:(vEmner & (1 << [indexPath row])) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
    }
    
    // Animer
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0) ? @"Vanskelighetsgrad på vekking" : @"Velg velkjente matteemner";
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
