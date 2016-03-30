//
//  HentVerData.m
//  Hjernevekker
//
//  Created by Espen Næss on 15.03.14.
//  Copyright (c) 2014 Espen Næss. All rights reserved.
//

#import "HentVerData.h"

NSXMLParser *parser;
NSUserDefaults *lagring;
NSString *temperatur;
NSString *vind;
NSString *symbolvarsel;

@implementation HentVerData

BOOL verStasjonFunnet = NO;

// Husk at vær fra iPhonens posisjon ikke fungerer i simulator

- (void)HentVerDataForPostnummer:(NSString *)postnummer {
    NSURL *verLenke = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.yr.no/sted/Norge/Postnummer/%@/varsel.xml", postnummer]];
    NSData *XMLData = [[NSData alloc] initWithContentsOfURL:verLenke];
    parser = [[NSXMLParser alloc] initWithData:XMLData];
    lagring = [NSUserDefaults standardUserDefaults];
    vind = nil; temperatur = nil; symbolvarsel = nil;
    [parser setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OppdaterVer" object:nil];
    
    [parser parse];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementname namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    // Henter ut meldt symbolvarsel for 5 timer
    if ([elementname isEqualToString:@"symbol"]) {
        if (!symbolvarsel) symbolvarsel = [attributeDict objectForKey:@"number"];
    }
    // Henter ut værobservasjoner fra nærmeste målestasjon
    if ([elementname isEqualToString:@"weatherstation"]) {
        verStasjonFunnet = YES;
    } if (verStasjonFunnet) {
        if ([elementname isEqualToString:@"temperature"]) {
            if (!temperatur) {temperatur = [attributeDict objectForKey:@"value"];}
        }
        if ([elementname isEqualToString:@"windSpeed"]) {
            if (!vind) {vind = [attributeDict objectForKey:@"mps"];}
        }
    }
}

- (void)GenererVerMelding {
    NSString *verMelding = [NSString stringWithFormat:@"%@°C, %@ m/s", temperatur, vind];
    
    [lagring setObject:verMelding forKey:@"vermelding"];
    [lagring setObject:symbolvarsel forKey:@"symbolvarsel"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OppdaterVer" object:nil];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"weatherstation"]) {
        verStasjonFunnet = NO;
    }
    if ([elementName isEqualToString:@"weatherdata"]) {
        [self GenererVerMelding];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    [lagring removeObjectForKey:@"vermelding"];
    [lagring removeObjectForKey:@"symbolvarsel"];
    
    NSLog(@"%@", parseError);
}

@end
