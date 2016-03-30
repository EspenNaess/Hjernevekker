//
//  OpprettAlarm.m
//  Hjernevekker
//
//  Created by Espen Næss on 27.10.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import "OpprettAlarm.h"
#import "Alarmer.h"
#import "AppDelegate.h"
#import "Repetisjoner.h"
#import "MusikkValg.h"
#import "Alarmdata.h"


@interface OpprettAlarm ()
@end

@implementation OpprettAlarm

@synthesize alarm;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    NSDateFormatter *datoformat = [[NSDateFormatter alloc] init];
    [datoformat setDateFormat:@"HH:mm"];
    
    if ([self endre]) {
        // Oppretter en ny alarm og overfører verdiene fra alarmen som skal endres
        // Endringene føres tilbake dersom brukeren velger å lagre
        Alarm *a = (Alarm *)[[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:[(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]] insertIntoManagedObjectContext:nil];
        [a fraOrdbok:[[self alarm] somOrdbok]];
        [self setAlarm:a];
        
        [[[self alarm] navn] isEqualToString:@""] ? [Navigasjonsbar.topItem setTitle:@"Alarm"] : [Navigasjonsbar.topItem setTitle:[[self alarm] navn]];
        [VelgDato setDate:[datoformat dateFromString:[[self alarm] tidAlarm]]];
    } else {
        // Oppretter en ny, tom alarm og fyller den med noen standardverdier
        [self setAlarm:(Alarm *)[[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Alarm" inManagedObjectContext:[(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]] insertIntoManagedObjectContext:nil]];
        [[self alarm] fraOrdbok:@{@"alarmstatus": @"on", @"gjentagelser" : @"0", @"musikkvalg" : @"-1", @"navn" : @"", @"tidAlarm" : @"00:00"}];
    }
    
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"musikk"]) {
        // Har valgt musikk
        MusikkValg *musikkValg = [segue destinationViewController];
        [musikkValg setMusikkvalg:[[[self alarm] musikkvalg] intValue]];
    } else if ([[segue identifier] isEqualToString:@"repetisjoner"]) {
        // Har valgt gjentakinger
        Repetisjoner *repetisjoner = [segue destinationViewController];
        [repetisjoner setValgte:[[[self alarm] gjentagelser] intValue]];
    } else {
        // Har trykt «Ferdig»
        NSDate *datoValgt = [VelgDato date];
        NSDateFormatter *datoformat = [[NSDateFormatter alloc] init];
        [datoformat setDateFormat:@"HH:mm"];
        
        [[self alarm] setNavn:[navn text]];
        [[self alarm] setTidAlarm:[datoformat stringFromDate:datoValgt]];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Opprett celleobjekt
    UITableViewCell *celle = [tableView dequeueReusableCellWithIdentifier:@"Celle"];
    
    if ([indexPath row] < 2) {
        celle = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Celle"];
    } else {
        celle = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Celle"];
    }
    
    // Sett opp cella
    NSArray *titler = @[@"Alarmlyder", @"Repetisjoner", @"Etikett", @"Volum"];
    
    // Tekst og celletype
    [[celle textLabel] setText:[titler objectAtIndex:indexPath.row]];
    [celle setAccessoryType:([indexPath row] < 2 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone)];
    
    if ([indexPath row] < 2) {
        // Alarmlyder/repetisjoner
        if ([self endre]) {
            if ([indexPath row] == 1) {
                [[celle detailTextLabel] setText:[Alarmdata ukedager:[[[self alarm] gjentagelser] intValue] medStil:ukedagKort]];
            } else {
                [[celle detailTextLabel] setText:[Alarmdata lydvalg:[[[self alarm] musikkvalg] intValue]]];
            }
        }
    } else if ([indexPath row] == 2) {
        // Etikett
        navn = [[UITextField alloc] initWithFrame:CGRectMake(90, 8, 375, 30)];
        [navn setPlaceholder:@"Navn på alarm her …"];
        [navn setClearButtonMode:UITextFieldViewModeWhileEditing];
        [[celle contentView] addSubview:navn];
        [navn setReturnKeyType:UIReturnKeyDone];
        [navn setDelegate:self];
        [navn setText:([self endre] ? [[self alarm] navn] : @"")];
    }
    
    [celle setSelectionStyle:UITableViewCellSelectionStyleNone];
    return celle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    long n = indexPath.row;
    if (n == 0) {
        [self performSegueWithIdentifier:@"musikk" sender:self];
    } else if (n == 1) {
        [self performSegueWithIdentifier:@"repetisjoner" sender:self];
    }
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)musikkFerdig:(UIStoryboardSegue *)segue {
    MusikkValg *musikkValg = [segue sourceViewController];
    [[self alarm] setMusikkvalg:[NSString stringWithFormat:@"%ld", [musikkValg musikkvalg]]];
    // Oppdatere tabellen (menyen)
    
    [[[Meny cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] detailTextLabel] setText:[Alarmdata lydvalg:[[[self alarm] musikkvalg] intValue]]];
    [[Meny cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] setNeedsLayout];
}

- (IBAction)repetisjonerFerdig:(UIStoryboardSegue *)segue {
    Repetisjoner *repetisjoner = [segue sourceViewController];
    [[self alarm] setGjentagelser:[NSString stringWithFormat:@"%d", [repetisjoner valgte]]];
    // Oppdatere tabellen (menyen)
    [[[Meny cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] detailTextLabel] setText:[Alarmdata ukedager:[[[self alarm] gjentagelser] intValue] medStil:ukedagKort]];
    [[Meny cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] setNeedsLayout];
}

@end
