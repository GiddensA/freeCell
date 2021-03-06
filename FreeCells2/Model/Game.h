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

- (NSString *) printColumn:(int) clm;

- (void) selectCardAtRow:(int) row column:(int) column;

- (void) placeCardToGameBard:(NSView *) gameboard superView:(NSView *) superView orderedCells:(NSMutableArray *) cells;

- (void) autoFinish;

@end

NS_ASSUME_NONNULL_END
