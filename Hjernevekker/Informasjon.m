//
//  Informasjon.m
//  Hjernevekker
//
//  Created by Espen Næss on 14.12.13.
//  Copyright (c) 2013 Espen Næss. All rights reserved.
//

#import "Informasjon.h"

@interface Informasjon ()

@end

@implementation Informasjon

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
    [Tabbar setSelectedSegmentIndex:0];
    [Tabbar addTarget:self action:@selector(TabBarKlikk) forControlEvents:UIControlEventAllEvents
     ];
    [KlikkeHer addTarget:self action:@selector(KlikkHer) forControlEvents:UIControlEventAllTouchEvents];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Bakgrunn.png"]];
    [super viewDidLoad];
}

- (void)TabBarKlikk {
    if (Tabbar.selectedSegmentIndex == 0) {
        [Tekstboks1 setText:@"Applikasjonen er utviklet av elever fra Kongshavn videregående skole i Oslo som del av et skoleprosjekt i faget entreprenørskap hvor vi skal realisere, markedsføre og selge et produkt. Kongshavn er en pionerskole innenfor gründervirksomhet. Vil du vite mer?"];
        [Tekstboks2 setText:@"Om du av ulike grunner ønsker å kontakte oss vedrørende applikasjonen kan du kontakte oss på mail:"];
        [label1 setText:@"Informasjon om applikasjonen"];
        [label2 setText:@"Ønsker du å kontakte oss?"];
        [KlikkeHer setAlpha:1];
    }
    else {
        [label1 setText:@"Viktige huskeregler"];
        [Tekstboks1 setText:@"Når du har laget en alarm er det viktig at du ikke har aktivert innstillinger som forhindrer applikasjonen fra å vekke deg. Sørg derfor for at du har:                  ● Ikke satt telefonen på lydløs          ● Ikke har deaktivert oss i varselsinnstillingene                            ● Koplet til lader om du har under 50% batteri igjen ● Tidssoneinstillinger er bestemt av telefonen"];
        [label2 setText:@"Fortsatt problemer?"];
        [Tekstboks2 setText:@"Om dette ikke løste problemet ditt, er du hjertelig velkommen til å sende oss en mail på følgende emailadresse:"];
        [KlikkeHer setAlpha:0];
    }
}

- (void)KlikkHer {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.kongshavn.vgs.no"]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
