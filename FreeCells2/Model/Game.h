//
//  Game.h
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deck.h"
#import "GameDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface Game : NSObject

@property id<GameDelegate> mGameDelegate;

- (instancetype) init;

- (void) resetGame;

- (NSArray *) getGameBoard;

- (NSArray *) getFreeCells;

- (NSArray *) getOrderedDeck;

- (NSString *) gameBoardToString;

- (void) selectCardAtRow:(int) row column:(int) column;

- (void) selectAtFreeCellIndex:(int) index;

- (void) placeCardToOrderedDeckAtIndex:(int) index;

- (void) placeCardToGameBard:(NSView *) gameboard;

@end

NS_ASSUME_NONNULL_END
