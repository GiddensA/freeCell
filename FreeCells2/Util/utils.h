//
//  utils.h
//  FreeCellsV2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"
#import "LOG.h"

NS_ASSUME_NONNULL_BEGIN

@interface utils : NSObject

+ (enum card_color) GetCardColor:(enum card_suit) suit;

+ (int) GetRandomIntFrom:(int) from to:(int) to;

+ (NSString *) GetSpaces:(NSString *) str;

+ (void) ShowAlert:(enum alert_type) type;

+ (CGFloat) GetOverlapSizeWithColumnSize:(NSInteger) size;
@end

NS_ASSUME_NONNULL_END
