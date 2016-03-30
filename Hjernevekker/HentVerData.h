//
//  HentVerData.h
//  Hjernevekker
//
//  Created by Espen Næss on 15.03.14.
//  Copyright (c) 2014 Espen Næss. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HentVerData : NSObject <NSXMLParserDelegate>

- (void)HentVerDataForPostnummer:(NSString *)postnummer;

@end
