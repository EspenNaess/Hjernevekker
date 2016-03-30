//
//  EnkelMatte.m
//  Hjernevekker
//
//  Created by Espen Næss on 01.02.14.
//  Copyright (c) 2014 Espen Næss. All rights reserved.
//

#import "EnkelMatte.h"
#import "Alarmdata.h"

#define Font_klokke(Tid) [UIFont fontWithName:@"DS-Digital" size:Tid]

@interface EnkelMatte ()

@end

NSDateFormatter *DatoFormatter;
CLLocationManager *lokalisasjonsManager;
NSUserDefaults *lager;
NSArray *Knapper;

static int antallShake = 0;
static int antallGrader = 0;
static int antallSpin = 0;

NSTimer *vibrering;

@implementation EnkelMatte
@synthesize MusikkForAlarmen, NavnForAlarm;

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
    // Installerer alarmlyden
    
    if ([MusikkForAlarmen isEqualToString:@"-1"]) {MusikkForAlarmen = @"0";}
    NSString *ValgtMusikk = [[Alarmdata lydvalg] objectAtIndex:[MusikkForAlarmen intValue]];
    NSString *Lyd = [[NSBundle mainBundle] pathForResource:ValgtMusikk ofType:@"mp3"];
    NSURL *LydURL = [NSURL fileURLWithPath:Lyd];
    MusikkSpiller = [[AVAudioPlayer alloc] initWithContentsOfURL:LydURL error:nil];
    [MusikkSpiller setNumberOfLoops:-1];
    [MusikkSpiller play];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(Tid) userInfo:nil repeats:YES];
    vibrering = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(Vibrer) userInfo:nil repeats:YES];
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
    MatteAlternativer = [[NSMutableArray alloc] init];
    Mattesvar = [[NSString alloc] init];
    [DatoFormatter setDateFormat:@"HH:mm:ss"];
    [self Tid];
    
    // Fjerner utfordringsoversikt
    [TaskFysisk setAlpha:0];
    [TaskTeoretisk setAlpha:0];
    
    // Innstallerer arrays
    Knapper = @[Alternativ1, Alternativ2, Alternativ3, Alternativ4];
    
    // Setter navn på alarmen
    [NavnForAlarm isEqualToString:@""] ? [Navn setText:@"God morgen!"] : [Navn setText:NavnForAlarm];
    
    // Henter matteoppgave
    [self HenteMatteOppgave];
    
    // Innstallerer bakgrunnen
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Bakgrunn.png"]]];
}

- (void)GenererMatteAlternativer:(UIButton *)knapp {
    NSString *Tekst = [MatteAlternativer objectAtIndex:arc4random() % [MatteAlternativer count]];
    [knapp setTitle:Tekst forState:UIControlStateNormal];
    [MatteAlternativer removeObject:Tekst];
}

- (IBAction)KnappKlikket:(UIButton *)knapp {
    if ([knapp.currentTitle isEqual:Mattesvar]) {
        [self LasteFysiskUtfordring];
    } else {
        [Status setText:@"Feil svar! Ny oppgave:"];
        [self HenteMatteOppgave];
    }
}

- (void)LasteFysiskUtfordring {
    // Fjerner ting fra forrige utfordring
    [UIView animateWithDuration:1 animations:^{
        for (int i = 0; i<4; i++) {
            UIButton *knapp = [Knapper objectAtIndex:i];
            [knapp setAlpha:0];
        }
        [Spurnad setFont:[UIFont boldSystemFontOfSize:17]];
        [Spurnad setText:@"Utfordringer som er igjen:"];
        [Status setAlpha:0];
        [Spurnad setAlpha:0];
    }];
    
    // Laster inn fysisk utfordring
    
    FysiskeSpurningar = [[Alarmdata Fysiskordbok] allKeys];
    ValgtFysiskOppgave = [FysiskeSpurningar objectAtIndex:arc4random() % [FysiskeSpurningar count]];
    
    if ([ValgtFysiskOppgave isEqualToString:@"Snurr"]) {
        lokalisasjonsManager = [[CLLocationManager alloc] init];
        lokalisasjonsManager.desiredAccuracy = kCLLocationAccuracyBest;
        [lokalisasjonsManager startUpdatingHeading];
    }
    
    [TaskFysisk setText:[[Alarmdata Fysiskordbok] objectForKey:ValgtFysiskOppgave]];
    [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [TaskFysisk setAlpha:1];
        [TaskTeoretisk setAlpha:1];
        [Spurnad setAlpha:1];
    } completion:nil];
}

- (void)HenteMatteOppgave {
    // Henter spørsmål og svar
    NSString *fasitForSpurnad, *spurnadString = [Alarmdata matteSpm:&fasitForSpurnad];
    [Spurnad setText:spurnadString];
    Mattesvar = fasitForSpurnad;
    
    // Setter mattespørsmål og svar
    [MatteAlternativer removeAllObjects];
    
    for (int i = 0; i<3; i++) {
        int mattesvarint = [Mattesvar intValue];
        i == 1 ? [MatteAlternativer addObject:[NSString stringWithFormat:@"%i", mattesvarint+1]] :
        i == 2 ? [MatteAlternativer addObject:[NSString stringWithFormat:@"%i", mattesvarint-1]] :
        [MatteAlternativer addObject:[NSString stringWithFormat:@"%i", mattesvarint-2]];
    }
    [MatteAlternativer addObject:Mattesvar];
    
    for (int i = 0; i<4; i++) {
        [self GenererMatteAlternativer:[Knapper objectAtIndex:i]];
    }
}

- (void)Tid {
    [Klokke setText:[DatoFormatter stringFromDate:[NSDate date]]];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ([ValgtFysiskOppgave isEqualToString:@"Shake"]) {
        if (event.subtype == UIEventSubtypeMotionShake) {
            antallShake++;
            [TaskFysisk setText:[NSString stringWithFormat:@"● Rist telefonen 10 ganger (%i/10)", antallShake]];
            if (antallShake == 10) {
                [lager removeObjectForKey:@"Alarm"];
                
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
                [self dismissViewControllerAnimated:YES completion:nil];
            }
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
        
        if (antallSpin == 5) {[self dismissViewControllerAnimated:YES completion:nil];}
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)Vibrer {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
