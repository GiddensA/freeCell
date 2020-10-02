//
//  Card.h
//  FreeCellsV2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "utils.h"

NS_ASSUME_NONNULL_BEGIN

@interface Card : NSObject

- (instancetype) initWithValue:(int) value
                          suit:(enum card_suit) suit;

- (instancetype) initEmptyCard;

- (enum card_suit) getSuit;

- (enum card_color) getCardColor;

- (int) getValue;

- (NSString *) toString;

- (NSString *) getCardImageString;

- (void) select;

- (BOOL) isSelected;

- (BOOL) isEqual:(Card *)otherCard;
@end

NS_ASSUME_NONNULL_END
