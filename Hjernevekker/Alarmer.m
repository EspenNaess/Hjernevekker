//
//  Alarmer.m
//  Hjernevekker
//
//  Created by Espen Næss on 27.10.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import "Alarmer.h"
#import "AppDelegate.h"
#import "OpprettAlarm.h"
#import "Alarmdata.h"

@implementation Alarmer

AppDelegate *Mindelegate;
OpprettAlarm *OPAlarmView;

AppDelegate *appDelegate;
NSManagedObjectContext *kontekst;

bool endre = NO; // brukes til å varsle OpprettAlarm

@synthesize AlarmArray, _Alarm;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    kontekst = [appDelegate managedObjectContext];
    
    // Last inn alarmene
    NSMutableArray *alarmArray = [self AlarmArray];
    
    NSError *feil = [Alarmdata les:&alarmArray];
    if (feil) {
        NSLog(@"Det oppstod en feil (%ld): %@", (long)[feil code], [feil description]);
    }
    
    [Tabell setRowHeight:75];
    [self setAlarmArray:alarmArray];
    [super viewDidLoad];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [AlarmArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Celletekst
    UITableViewCell *celle = [tableView dequeueReusableCellWithIdentifier:@"Alarm"];
    celle = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Alarm"];
    Alarm *alarm = [AlarmArray objectAtIndex:indexPath.row];
    
    // Detaljtekst
    NSString *detalj;
    
    if ([alarm gjentagelser] == nil || [[alarm gjentagelser] intValue] == 0) {
        detalj = [alarm navn];
    } else {
        detalj = [Alarmdata ukedager:[[alarm gjentagelser] intValue] medStil:ukedagKort];
        if (![[alarm navn] isEqualToString:@""]) {
            detalj = [[NSString alloc] initWithFormat:@"%@ (%@)", [alarm navn], detalj];
        }
    }
    
    // Klargjør cella
    [[celle textLabel] setText:[alarm tidAlarm]];
    [[celle textLabel] setFont:[UIFont systemFontOfSize:45]];
    [[celle detailTextLabel] setText:detalj];
    [[celle detailTextLabel] setFont:[UIFont systemFontOfSize:15]];
    [celle setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    // Klargjør bryteren
    UISwitch *bryter = [[UISwitch alloc] initWithFrame:CGRectMake(230, 22.5, 0, 0)];
    [bryter addTarget:self action:@selector(AlarmStatusEndret:) forControlEvents:UIControlEventValueChanged];
    [bryter setTag:indexPath.row];
    [[celle contentView] addSubview:bryter];
    [bryter setOn:[[alarm alarmstatus] isEqualToString:@"on"] ? YES : NO];
    
    return celle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _Alarm = [AlarmArray objectAtIndex:indexPath.row];
    
    @try {
        [self performSegueWithIdentifier:@"endre" sender:self];
    } @catch (NSException *e) {
        [e description];
    }
}

- (void)AlarmStatusEndret:(UISwitch *)sender {
    Alarm *alarm = [AlarmArray objectAtIndex:sender.tag];
    if (sender.on) {
        [alarm setAlarmstatus:@"on"];
    } else {
        [alarm setAlarmstatus:@"av"];
    }
    [Alarmdata lagre];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [Alarmdata slettAlarm:[[self AlarmArray] objectAtIndex:[indexPath row]]];
        [AlarmArray removeObjectAtIndex:[indexPath row]];
        [Tabell deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"endre"]) {
        // Endre alarm
        OpprettAlarm *opprettAlarm = [segue destinationViewController];
        opprettAlarm.endre = YES;
        opprettAlarm.alarm = _Alarm;
    } else if ([[segue identifier] isEqualToString:@"ny"]) {
        // Opprett ny alarm
        OpprettAlarm *opprettAlarm = [segue destinationViewController];
        opprettAlarm.endre = NO;
    }
}

- (IBAction)ferdig:(UIStoryboardSegue *)segue {
    OpprettAlarm *kilde = [segue sourceViewController];
    Alarm *alarm = [kilde alarm];
    
    if ([kilde endre]) {
        // Lagre endringene
        [_Alarm fraOrdbok:[alarm somOrdbok]];
        [Alarmdata lagre];
    } else {
        // Legge til den nye alarmen
        [Alarmdata nyAlarm:[alarm somOrdbok] somAlarm:&alarm];
        [AlarmArray addObject:alarm];
    }
    
    // Sortere AlarmArray
    [AlarmArray sortUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"tidAlarm" ascending:YES]]];
    
    // Last tabellen på nytt
    [Tabell reloadData];
}

- (IBAction)avbryt:(UIStoryboardSegue *)segue {
    // Brukes bare av seguene til å komme tilbake
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

-(void)viewWillAppear:(BOOL)animated {
    // fjerner valget av celle
    [super viewWillAppear:animated];
    
    NSIndexPath *valgt = [Tabell indexPathForSelectedRow];
    if (valgt) {
        [Tabell deselectRowAtIndexPath:valgt animated:YES];
    }
}

@end
