//
//  Game.m
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import "Game.h"
#import "LOG.h"
#import "Deck.h"

#define TAG "Game"

@interface Game()
{
    Deck *mDeck;
    NSMutableArray<NSMutableArray<Card *> *> *mGameBoard; // array of rows
    NSMutableArray<Card *> *freeCells;
    NSMutableArray<Card *> *orderedDeck;
    NSMutableArray<Card *> *lastRow;
}
@end

@implementation Game

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        mDeck = [[Deck alloc] init];
        [mDeck shuffle];
        
        [self setupGameBoard: YES];
        
        freeCells = [NSMutableArray array];
        orderedDeck = [NSMutableArray array];
        lastRow = [NSMutableArray array];
        
    }
    return self;
}

- (void) resetGame
{
    [mDeck resetDeck];
    [mDeck shuffle];
    
    [self setupGameBoard: NO];
    
    freeCells = [NSMutableArray array];
    orderedDeck = [NSMutableArray array];
    lastRow = [NSMutableArray array];
}

- (NSArray *) getGameBoard
{
    return mGameBoard;
}

- (NSString *) gameBoardToString
{
    NSMutableString *toReturn = [NSMutableString string];
    int row = 0;
    while(YES)
    {
        int emptyCellCount = 0;
        for (int i = 0; i < num_of_game_board_columns; i++)
        {
            if (mGameBoard[i].count  - 1 == row)
            {
                // last row
                emptyCellCount ++;
                [toReturn appendFormat:@"%@|", [utils GetSpaces:[mGameBoard[i][row] toString]]];
            }
            else if (mGameBoard[i].count  - 1  < row)
            {
                // out of bound
                emptyCellCount ++;
                [toReturn appendFormat:@"%@|", [utils GetSpaces:@""]];
            }
            else{
                [toReturn appendFormat:@"%@|", [utils GetSpaces:[mGameBoard[i][row] toString]]];
            }
        }
        [toReturn appendString:@"\n"];
        if (emptyCellCount == num_of_game_board_columns)
        {
            break;
        }
        else
        {
            row ++;
        }
    }
    return toReturn;
}

- (void) setupGameBoard:(BOOL) needInitBoard
{
    // init game board if needed
    if (needInitBoard)
    {
        mGameBoard = [[NSMutableArray alloc] init];
        for (int i = 0; i < num_of_game_board_columns; i++)
        {
            NSMutableArray<Card *> *column = [[NSMutableArray alloc] init];
            [mGameBoard addObject:column];
        }
    }
    else
    {
        for (int i = 0; i < num_of_game_board_columns; i++)
        {
            [mGameBoard[i] removeAllObjects];
        }
    }
    
    // fill up game board
    Card *card = [mDeck dealCard];
    while (nil != card)
    {
        for (int i = 0; i < num_of_game_board_columns; i++)
        {
            if (nil != card)
            {
                [mGameBoard[i] addObject:card];
                card = [mDeck dealCard];
            } else {
                LOG_MODOLE(TAG, @"Board set\n%@",[self gameBoardToString]);
                return;
            }
        }
    }
}


@end
