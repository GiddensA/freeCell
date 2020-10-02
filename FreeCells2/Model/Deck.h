//
//  Deck.h
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

NS_ASSUME_NONNULL_BEGIN

@interface Deck : NSObject

- (instancetype) init;

- (void) shuffle;

- (Card *) dealCard;

- (void) resetDeck;

- (void) printDeck;

@end

NS_ASSUME_NONNULL_END
