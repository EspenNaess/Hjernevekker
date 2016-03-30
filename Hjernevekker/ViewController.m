//
//  ViewController.m
//  Hjernevekker
//
//  Created by Espen Næss on 26.10.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import "ViewController.h"
#import "FargeTema.h"
#import "Alarm.h"
#import "Alarmdata.h"
#import "VanskeligMatte.h"
#import "EnkelMatte.h"

#define Font_klokke(ST) [UIFont fontWithName:@"DS-Digital" size:ST]

Alarm *_Alarm;

// datoformatterer ss / HH:mm / HH:mm:ss / ukedag / ukedagnummer / dato
NSDateFormatter *dS, *dHM, *dHMS, *dUD, *dUDN, *dD;
NSTimer *tidtaker;
NSArray *farger;
NSUserDefaults *lager;
NSDate *ntid;
UIColor *farge;
BOOL slettAlt = NO;

@implementation ViewController
@synthesize VaerLabel, VerTegn;


- (void)viewDidLoad
{
    lager = [NSUserDefaults standardUserDefaults];
    
    // sletter app innstillinger (om nødvendig)
    if (slettAlt) {
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [lager removePersistentDomainForName:appDomain];
    }
    
    farger = @[[UIColor blueColor], [UIColor redColor], [UIColor yellowColor], [UIColor greenColor], [UIColor grayColor], [UIColor purpleColor], [UIColor orangeColor]];
    MatteViews = @[@"Matte1", @"Matte2"];
    
    // Setter font på klokken
    [KlokkeLabel setFont:Font_klokke(70)];
    [bakgrunn setFont:Font_klokke(70)];
    [Dato setFont:Font_klokke(20)];
    
    // Oppretter datoformatterne
    dS = [[NSDateFormatter alloc] init];
    dHM = [[NSDateFormatter alloc] init];
    dHMS = [[NSDateFormatter alloc] init];
    dUD = [[NSDateFormatter alloc] init];
    dUDN = [[NSDateFormatter alloc] init];
    dD = [[NSDateFormatter alloc] init];
    [dS setDateFormat:@"ss"];
    [dHM setDateFormat:@"HH:mm"];
    [dHMS setDateFormat:@"HH:mm:ss"];
    [dUD setDateFormat:@"EEEE"];
    [dUDN setDateFormat:@"e"];
    [dD setDateStyle:NSDateFormatterShortStyle];
    NSDate *ntid = [NSDate date];
    
    // Setter midlertidig klokketidspunkt
    [KlokkeLabel setText:[dHMS stringFromDate:ntid]];
    [Dato setText:[dD stringFromDate:ntid]];
    [Dag setText:[[dUD stringFromDate:ntid] capitalizedString]];
    
    // Sjekker dobbeltklikk
    UITapGestureRecognizer *DobbelKlikk = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DobbelKlikk:)];
    [DobbelKlikk setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:DobbelKlikk];
    
    // Initialiserer værlabel
    UITapGestureRecognizer *KlikkVaerLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(VaerKlikk:)];
    [KlikkVaerLabel setNumberOfTapsRequired:1];
    [VaerLabel addGestureRecognizer:KlikkVaerLabel];
    [VaerLabel setUserInteractionEnabled:YES];
    
    // Initialiserer nødvendig støff
    AlarmArray = [[NSMutableArray alloc] init];
    AlarmUkeArray = [[NSMutableArray alloc] init];
    AlarmLydArray = [[NSMutableArray alloc] init];
    AlarmNavnArray = [[NSMutableArray alloc] init];
    
    // Lytter etter værmeldingsoppdateringer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OppdatererVer) name:@"OppdaterVer" object:nil];
    
    [super viewDidLoad];
}

- (void)OppdatererVer {
    // Setter værmeldingen
    [VaerLabel setText:[lager objectForKey:@"vermelding"]];
    
    // Setter værsymbolet
    int timetid = [[KlokkeLabel.text substringToIndex:2] intValue];
    if (timetid <= 20 && timetid >= 6) {
        UIImage *valgtVerIkon = [UIImage imageNamed:[[Alarmdata verSymbolerDag] objectForKey:[lager objectForKey:@"symbolvarsel"]]];
        [VerTegn setImage:valgtVerIkon];
    } else {
        UIImage *valgtVerIkon = [UIImage imageNamed:[[Alarmdata verSymbolerNatt] objectForKey:[lager objectForKey:@"symbolvarsel"]]];
        [VerTegn setImage:valgtVerIkon];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self lastOm];
}

- (void)lastOm {
    // Fjerner tidtakeren
    if (tidtaker) {
        [tidtaker invalidate];
        tidtaker = nil;
    }
    
    // Sjekker Fargeinnstillinger
    farge = [farger objectAtIndex:[lager integerForKey:@"Farge"]];
    if (farge == nil) farge = [UIColor blueColor];
    
    [KlokkeLabel setTextColor:farge];
    [Dato setTextColor:farge];
    [Dag setTextColor:farge];
    
    // Setter bakgrunnsfarge for klokken
    [self settKlokkebakgrunn:farge];
    
    // Leser inn alarmene
    NSMutableArray *alarmArray;
    NSError *feil = [Alarmdata les:&alarmArray];
    
    if ([feil code] != 0) {
        NSLog(@"Det oppstod en feil (%ld): %@", (long)[feil code], [feil description]);
    }
    
    // Tømmer Array-ene (i tilfelle de er fulle)
    [AlarmUkeArray removeAllObjects];
    [AlarmArray removeAllObjects];
    [AlarmLydArray removeAllObjects];
    [AlarmNavnArray removeAllObjects];
    
    // Fyller Array-ene
    for (NSManagedObject *obj in alarmArray) {
        if ([[obj valueForKey:@"alarmstatus"] isEqualToString:@"on"]) {
            NSString *dagerValgtString = [obj valueForKey:@"gjentagelser"];
            [AlarmUkeArray addObject:dagerValgtString];
            NSString *tidAlarm = [obj valueForKey:@"tidAlarm"];
            [AlarmArray addObject:tidAlarm];
            NSString *musikkAlarm = [obj valueForKey:@"musikkvalg"];
            [AlarmLydArray addObject:musikkAlarm];
            NSString *navnAlarm = [obj valueForKey:@"navn"];
            [AlarmNavnArray addObject:navnAlarm];
        }
    }
    
    // Lager (ny) tidtaker
    tidtaker = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(Tidsinstans:) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OppdaterVer" object:nil];
}

- (void)settKlokkebakgrunn:(UIColor *)farge {
    // Sjekker Fargeinnstillinger
    CGFloat r, g, b, a, h;
    [farge getWhite:&h alpha:&a];
    r = h; g = h; b = h;
    [farge getRed:&r green:&g blue:&b alpha:&a];
    r = r / 3; g = g / 3; b = b / 3;
    [bakgrunn setTextColor:[UIColor colorWithRed:r green:g blue:b alpha:a]];
}

- (void)Tidsinstans:(id)sender {
    ntid = [NSDate date];
    [KlokkeLabel setText:[dHMS stringFromDate:ntid]];
    
    // Ser etter alarmer (men kun pr min)
    if ([[dS stringFromDate:ntid] intValue] != 0) return;
    
    // Oppdaterer ukedag og dato
    [Dato setText:[dD stringFromDate:ntid]];
    [Dag setText:[[dUD stringFromDate:ntid] capitalizedString]];
    
    // Sjekker om det er en alarm tilstede
    for (int i = 0; i < [AlarmArray count]; i++) {
        if ([[dHM stringFromDate:ntid] isEqualToString:[AlarmArray objectAtIndex:i]]
            && ([Alarmdata iDagErValgt:[[AlarmUkeArray objectAtIndex:i] intValue]])) {
            [lager setBool:YES forKey:@"Alarm"];
            NavnForAlarmen = [AlarmNavnArray objectAtIndex:i];
            MusikkForAlarm = [AlarmLydArray objectAtIndex:i];
            kjorendeAlarm = [AlarmArray objectAtIndex:i];
            [self performSegueWithIdentifier:[MatteViews objectAtIndex:arc4random() % [MatteViews count]] sender:self];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Forbereder overgang til en alarm
    if ([[segue identifier] isEqualToString:@"Matte1"]) {
        // Enkel matte
        EnkelMatte *AlarmView = [segue destinationViewController];
        [AlarmView setMusikkForAlarmen:MusikkForAlarm];
        [AlarmView setNavnForAlarm:NavnForAlarmen];
    } else if ([[segue identifier] isEqualToString:@"Matte2"]) {
        // Vanskelig matte
        VanskeligMatte *AlarmView = [segue destinationViewController];
        [AlarmView setMusikkForAlarmen:MusikkForAlarm];
        [AlarmView setNavnForAlarm:NavnForAlarmen];
    }
}

- (void)DobbelKlikk:(id)sender {
    AVCaptureDevice *iProdukt = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([lager boolForKey:@"lommelykt"] && [iProdukt isTorchAvailable]
        && [iProdukt isTorchModeSupported:AVCaptureTorchModeOn]) {
        if ([iProdukt lockForConfiguration:nil]) {
            if (iProdukt.torchMode == AVCaptureTorchModeOn) {
                [iProdukt setTorchMode:AVCaptureTorchModeOff];
                [[self view] setBackgroundColor:[UIColor blackColor]];
                VerTegn.hidden = NO;
                [self settKlokkebakgrunn:farge];
                [KlokkeLabel setTextColor:farge];
            } else {
                [iProdukt setTorchMode:AVCaptureTorchModeOn];
                [[self view] setBackgroundColor:[UIColor whiteColor]];
                VerTegn.hidden = YES;
                [bakgrunn setTextColor:[UIColor whiteColor]];
            }
            
            [iProdukt unlockForConfiguration];
        }
    } else {
        NSLog(@"Fønka ikke");
    }
}

- (IBAction)TekstKlikk:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.kongshavn.vgs.no"]];
}

- (void)VaerKlikk:(id)sender {
    [self performSegueWithIdentifier:@"veret" sender:self];
}

- (IBAction)tilbake:(UIStoryboardSegue *)segue {
    // Funkjonen brukes bare av segues til å finne tilbake hit, ellers fullstendig unyttig
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
