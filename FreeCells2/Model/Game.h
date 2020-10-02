//
//  Game.h
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Game : NSObject

- (instancetype) init;

- (void) resetGame;

- (NSArray *) getGameBoard;

- (NSString *) gameBoardToString;

- (BOOL) checkSelectionAtRow:(int) row column:(int) column;

- (NSArray *) selectCardAtRow:(int) row column:(int) column;
@end

NS_ASSUME_NONNULL_END
