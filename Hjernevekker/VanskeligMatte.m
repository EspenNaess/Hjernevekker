//
//  VanskeligMatte.m
//  Hjernevekker
//
//  Created by Espen Næss on 09.12.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import "VanskeligMatte.h"
#import "Alarmdata.h"

#define Font_klokke(Tid) [UIFont fontWithName:@"DS-Digital" size:Tid]

@interface VanskeligMatte ()

@end

NSDateFormatter *DatoFormatter;
NSUserDefaults *lagring;
CLLocationManager *lokalisasjonsManager;


static int antallGrader = 0;
static int antallSpin = 0;


@implementation VanskeligMatte
@synthesize MusikkForAlarmen, NavnForAlarm;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    // Innstallerer alarmlyden
    if ([MusikkForAlarmen isEqualToString:@"-1"]) {MusikkForAlarmen = @"0";}
    NSString *ValgtMusikk = [[Alarmdata lydvalg] objectAtIndex:[MusikkForAlarmen intValue]];
    NSString *Lyd = [[NSBundle mainBundle] pathForResource:ValgtMusikk ofType:@"mp3"];
    NSURL *LydURL = [NSURL fileURLWithPath:Lyd];
    MusikkSpiller = [[AVAudioPlayer alloc] initWithContentsOfURL:LydURL error:nil];
    [MusikkSpiller setNumberOfLoops:-1];
    [MusikkSpiller play];
    
    // Innstallerer verktøylinje for tastaturet
    UIToolbar* nummerToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    nummerToolbar.barStyle = UIBarStyleBlackTranslucent;
    nummerToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithTitle:@"Avbryt" style:UIBarButtonItemStyleBordered target:self action:@selector(AvbrytMatte)], [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc]initWithTitle:@"Ferdig" style:UIBarButtonItemStyleDone target:self action:@selector(FerdigMatte)],
                           nil];
    [SvarTekstFelt setInputAccessoryView:nummerToolbar];
    [SvarTekstFelt setDelegate:self];
    [nummerToolbar sizeToFit];
    
    vibrering = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(Vibrer) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tid) userInfo:nil repeats:YES];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self InnstallererView];
    
}

- (void)InnstallererView {
    // Innstallerer klokken
    Klokke.font = Font_klokke(70.0);
    DatoFormatter = [[NSDateFormatter alloc] init];
    Mattesvar = [[NSString alloc] init];
    [DatoFormatter setDateFormat:@"HH:mm:ss"];
    [self tid];
    
    // Setter navn på alarmen
    [NavnForAlarm isEqualToString:@""] ? [Navn setText:@"God morgen!"] : [Navn setText:NavnForAlarm];
    
    // Innstaller fysisk utfordring
    FysiskeSpurningar = [[Alarmdata Fysiskordbok] allKeys];
    ValgtFysiskOppgave = [FysiskeSpurningar objectAtIndex:arc4random() % [FysiskeSpurningar count]];
    [TaskFysisk setText:[[Alarmdata Fysiskordbok] objectForKey:ValgtFysiskOppgave]];
    
    if ([ValgtFysiskOppgave isEqualToString:@"Snurr"]) {
        lokalisasjonsManager = [[CLLocationManager alloc] init];
        lokalisasjonsManager.desiredAccuracy = kCLLocationAccuracyBest;
        [lokalisasjonsManager startUpdatingHeading];
    }
    
    // Henter matteoppgave
    [self HenteMatteOppgave];
    
    // Innstallerer bakgrunnen
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Bakgrunn.png"]]];
}

- (void)HenteMatteOppgave {
    // Henter mattespørsmål og fasit
    NSString *fasitForSpurnad, *spurnadString = [Alarmdata matteSpm:&fasitForSpurnad];
    
    [Spurnad setText:spurnadString];
    Mattesvar = fasitForSpurnad;
}

- (void)tid {
    [Klokke setText:[DatoFormatter stringFromDate:[NSDate date]]];
}

- (void)FerdigMatte {
    if (!TeoretiskFerdig) {
        if ([SvarTekstFelt.text isEqualToString:Mattesvar]) {
            TeoretiskFerdig = YES;
            [TaskMatte setText:@"● Matteoppgave løst ☑"];
            [SvarTekstFelt resignFirstResponder];
            [self Sjekksvar];
        } else {
            [StatusTittel setText:@"Feil! Ny matteoppgave:"];
            [SvarTekstFelt setText:@""];
            [self HenteMatteOppgave];
        }
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ([ValgtFysiskOppgave isEqualToString:@"Shake"]) {
        if (event.subtype == UIEventSubtypeMotionShake) {
            AntallShake++;
            [TaskFysisk setText:[NSString stringWithFormat:@"● Rist telefonen 10 ganger (%i/10)", AntallShake]];
            if (AntallShake == 10) {FysiskFerdig = YES;}
            [self Sjekksvar];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (antallGrader == 0) {antallGrader = [newHeading magneticHeading];}
    
    if (antallGrader <= [newHeading magneticHeading]) {
        antallGrader = 0;
    }
    if ([ValgtFysiskOppgave isEqualToString:@"Snurr"]) {
        
        NSLog(@"Grader: %f", newHeading.magneticHeading);
        
        if (antallSpin == 5) { FysiskFerdig = YES;}
        [self Sjekksvar];
    }
}

- (void)AvbrytMatte {
    [SvarTekstFelt resignFirstResponder];
}

- (void)Vibrer {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)Sjekksvar {
    if (FysiskFerdig && TeoretiskFerdig) {
        [lagring removeObjectForKey:@"Alarm"];
        
        NSMutableArray *alarmer;
        [Alarmdata les:&alarmer];
        for (Alarm *alarmen in alarmer) {
            if ([[alarmen valueForKey:@"navn"] isEqualToString:NavnForAlarm]) {
                [alarmen setAlarmstatus:@"av"];
            }
        }
        [Alarmdata lagre];
        [MusikkSpiller stop];
        [vibrering invalidate];
        vibrering = nil;
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
