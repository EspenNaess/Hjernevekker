//
//  Verinnstillinger.m
//  Hjernevekker
//
//  Created by Espen Næss on 23.01.14.
//  Copyright (c) 2014 Espen Næss. All rights reserved.
//

#import "Verinnstillinger.h"
#import "HentVerData.h"

@interface Verinnstillinger ()

@end

@implementation Verinnstillinger

NSUserDefaults *lager;

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
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *celle = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"verinnstillinger"];
    
    [[celle textLabel] setText:@"Postnummer: "];
    postnummerfelt = [[UITextField alloc] initWithFrame:CGRectMake(130, 8, 375, 30)];
    [postnummerfelt setPlaceholder:@"Skriv postnummer her.."];
    [postnummerfelt setTextColor:[UIColor grayColor]];
    [postnummerfelt setKeyboardType:UIKeyboardTypeNumberPad];
    [[celle contentView] addSubview:postnummerfelt];
    
    // Innstallerer en ferdigknapp for tastaturet
    UIToolbar* ferdigKnapp = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    ferdigKnapp.barStyle = UIBarStyleBlackTranslucent;
    ferdigKnapp.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],[[UIBarButtonItem alloc]initWithTitle:@"Ferdig" style:UIBarButtonItemStyleDone target:self action:@selector(Ferdig)],nil];
    
    [ferdigKnapp sizeToFit];
    [postnummerfelt setInputAccessoryView:ferdigKnapp];
    [postnummerfelt setDelegate:self];
    
    NSString *postnummer = [lager objectForKey:@"postnummer"];
    if (postnummer) {
        [postnummerfelt setText:postnummer];
    }
    
    return celle;
}

- (void)Ferdig {
    [postnummerfelt resignFirstResponder];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"Fyll inn dette feltet om du heller ønsker og få værvarsel fra et postnummer i stedet fra mobilens nåværende posisjon. Dette kan spare batteri.";
}


- (void)Tilbake:(id)sender {
    if (![postnummerfelt text]  || [[postnummerfelt text] isEqualToString:@""]) {
        [lager removeObjectForKey:@"postnummer"];
    } else {
        [lager setObject:[postnummerfelt text] forKey:@"postnummer"];
        [[HentVerData alloc] HentVerDataForPostnummer:[postnummerfelt text]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
