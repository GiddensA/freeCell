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
    
    struct Coord selectedPos;
}
@end

@implementation Game

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        selectedPos.row = -1;
        selectedPos.column = -1;
        freeCells = [NSMutableArray array];
        orderedDeck = [NSMutableArray array];
        lastRow = [NSMutableArray array];
        
        mDeck = [[Deck alloc] init];
        [mDeck shuffle];
        
        [self setupGameBoard: YES];
    }
    return self;
}

- (void) resetGame
{
    selectedPos.row = -1;
    selectedPos.column = -1;
    freeCells = [NSMutableArray array];
    orderedDeck = [NSMutableArray array];
    lastRow = [NSMutableArray array];
    
    [mDeck resetDeck];
    [mDeck shuffle];
    
    [self setupGameBoard: NO];
    
    
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
                for (int i = 0; i < num_of_game_board_columns; i ++)
                {
                    [lastRow addObject:[mGameBoard[i] lastObject]];
                }
                LOG_MODOLE(TAG, @"Board set\n%@",[self gameBoardToString]);
                break;
            }
        }
    }
#ifdef CHECK
    [self printLastRow];
#endif
}

- (BOOL)moveCardsToRow:(int)tRow toClm:(int)tClm from:(NSArray *__autoreleasing *)fArr to:(NSArray *__autoreleasing *)tArr
{
    LOG_MODOLE(TAG, @"Start move");
    if (selectedPos.row == -1 && selectedPos.column == -1)
    {
        LOG_MODOLE(TAG, @"Cannot move");
        return NO;
    }
    else
    {
        int fRow = selectedPos.row;
        int fClm = selectedPos.column;
        Card *from = mGameBoard[fClm][fRow];
        Card *to = mGameBoard[tClm][tRow];
        if ([from isEqual:lastRow[fClm]])
        {
            LOG_MODOLE(TAG, @"move one card from (%d %d) to (%d %d)", fRow, fClm, tRow, tClm);
            // move one card
            if ([from getValue] + 1 == [to getValue] && [from getCardColor] != [to getCardColor])
            {
                // can move
                [self selectCardAtRow:fRow column:fClm];
                [mGameBoard[fClm] removeObject:from];
                *fArr = mGameBoard[fClm];
                lastRow[fClm] = [mGameBoard[fClm] lastObject];
                
                [mGameBoard[tClm] addObject:from];
                *tArr = mGameBoard[tClm];
                lastRow[tClm] = from;
#ifdef CHECK
                [self printLastRow];
                LOG_MODOLE(TAG, @"Board\n%@",[self gameBoardToString]);
#endif
                return YES;
            }
            else
            {
                [self selectCardAtRow:fRow column:fClm];
                return NO;
            }
        } else {
            // move a column of cards
            
        }
    }
    return NO;
}

- (BOOL) checkSelectionAtRow:(int)row column:(int)column
{
    return (selectedPos.row == -1 && selectedPos.column == -1) || (selectedPos.row == row && selectedPos.column == column);
}

- (NSArray *) selectCardAtRow:(int)row column:(int)column
{
    
    for (int i = row; i < mGameBoard[column].count; i++)
    {
        [(Card *)(mGameBoard[column][i]) select];
        LOG_MODOLE(TAG, @"select card %@ at %d,%d isSelected = %d", [(Card *)(mGameBoard[column][i]) toString], row, column, [(Card *)(mGameBoard[column][i]) isSelected])
    }
    selectedPos.row = [(Card *)(mGameBoard[column][row]) isSelected] ? row : -1;
    selectedPos.column = [(Card *)(mGameBoard[column][row]) isSelected] ? column : -1;
    return mGameBoard[column];
}

- (struct Coord) getSelectCoord
{
    return selectedPos;
}

- (void) printLastRow
{
    NSMutableString *print = [NSMutableString stringWithString:@"last row = [\n"];
    for (int i = 0; i < num_of_game_board_columns; i++)
    {
        [print appendFormat:@"%@\n", [lastRow[i] toString]];
    }
    LOG_MODOLE(TAG, @"%@]", print);
}
@end
