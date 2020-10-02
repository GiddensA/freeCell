//
//  Game.h
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

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
                     from:(NSArray **) fArr
                       to:(NSArray **) tArr;
@end

NS_ASSUME_NONNULL_END
