//
//  Game.h
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deck.h"

NS_ASSUME_NONNULL_BEGIN

struct Coord
{
    int row;
    int column;
};

@interface Game : NSObject

- (instancetype) init;

- (void) resetGame;

- (NSArray *) getGameBoard;

- (NSString *) gameBoardToString;

- (BOOL) checkSelectionAtRow:(int) row column:(int) column;

- (NSArray *) selectCardAtRow:(int) row column:(int) column;

- (struct Coord) getSelectCoord;

- (BOOL) moveCardsToRow:(int) tRow
                    toClm:(int) tClm
                   from:(NSArray *_Nullable*_Nullable) pfArr
                     to:(NSArray *_Nullable*_Nullable) ptArr;

- (BOOL) moveCardFromFreeCellAtIndex:(int) index
                               toClm:(int) tClm
                                tRow:tRow
                                  to:(NSArray *_Nullable*_Nullable) ptArr;

- (BOOL) moveCardToFreeCellIndex:(int) index
                            from:(NSArray *_Nullable*_Nullable) pfArr;

- (Card *) getCardAtFreeCellIdx:(int) index;

- (void) selectAtFreeCellIndex:(int) index;

- (int) getSelectedFreeCellIdx;
@end

NS_ASSUME_NONNULL_END
