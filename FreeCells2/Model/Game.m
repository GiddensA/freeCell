//
//  Game.m
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import "Game.h"
#import "LOG.h"

#define TAG "Game"

@interface Game()
{
    Deck *mDeck;
    NSMutableArray<NSMutableArray<Card *> *> *mGameBoard; // array of rows
    NSMutableArray<Card *> *freeCells;
    NSMutableArray<Card *> *orderedDeck;
    NSMutableArray<Card *> *lastRow;
    
    struct Coord selectedPos;
    
    int freeCellCount;
    int selectedFrecellIndex;
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
        freeCellCount = 4;
        selectedFrecellIndex = -1;
        freeCells = [NSMutableArray arrayWithObjects:[[Card alloc] initEmptyCard], [[Card alloc] initEmptyCard],[[Card alloc] initEmptyCard],[[Card alloc] initEmptyCard], nil];
        orderedDeck = [NSMutableArray arrayWithObjects:[[Card alloc] initEmptyCard], [[Card alloc] initEmptyCard],[[Card alloc] initEmptyCard],[[Card alloc] initEmptyCard], nil];
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
    freeCellCount = 4;
    selectedFrecellIndex = -1;
    freeCells = [NSMutableArray arrayWithObjects:[[Card alloc] initEmptyCard], [[Card alloc] initEmptyCard],[[Card alloc] initEmptyCard],[[Card alloc] initEmptyCard], nil];
    orderedDeck = [NSMutableArray arrayWithObjects:[[Card alloc] initEmptyCard], [[Card alloc] initEmptyCard],[[Card alloc] initEmptyCard],[[Card alloc] initEmptyCard], nil];
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

- (BOOL)moveCardsToRow:(int)tRow toClm:(int)tClm from:(NSArray **)fArr to:(NSArray  **)tArr
{
    LOG_MODOLE(TAG, @"Start move selected %d,%d",selectedPos.row, selectedPos.column);
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
            LOG_MODOLE(TAG, @"move cards from (%d %d) to (%d %d)", fRow, fClm, tRow, tClm);
            // move a column of cards
            if ([from getValue] + 1 == [to getValue] && [from getCardColor] != [to getCardColor])
            {
                NSArray *subClm = [mGameBoard[fClm] subarrayWithRange:NSMakeRange(fRow, mGameBoard[fClm].count - fRow)];
                BOOL hasFreeCell = [self checkFreeCells:subClm tagetColumn:fClm];
                if (hasFreeCell)
                {
                    
                    [mGameBoard[tClm] addObjectsFromArray:subClm];
                    lastRow[tClm] = [mGameBoard[tClm] lastObject];
                    [mGameBoard[fClm] removeObjectsInArray:subClm];
                    lastRow[fClm] = [mGameBoard[fClm] lastObject];
                    
                    [self selectCardAtRow:tRow + 1 column:tClm];
#ifdef CHECK
                    [self printLastRow];
                    LOG_MODOLE(TAG, @"Board\n%@",[self gameBoardToString]);
#endif
                    return YES;
                }
                return NO;
            }
            else
            {
                [self selectCardAtRow:fRow column:fClm];
                return NO;
            }
        }
    }
    return NO;
}

- (BOOL)moveCardFromFreeCellAtIndex:(int)index toClm:(int)tClm tRow:(id)tRow to:(NSArray * _Nullable __autoreleasing *)ptArr
{
    return NO;
}

- (BOOL) checkSelectionAtRow:(int)row column:(int)column
{
    if (selectedFrecellIndex != -1)
    {
        return NO;
    }
    if (![mGameBoard[column][row] isEqual:lastRow[column]]) {
        NSArray<Card *> *clm = mGameBoard[column];
        for (int i = row; i < clm.count - 1; i++)
        {
            LOG_MODOLE(TAG, @"i = %d, compare card %@ vs %@", i, [clm[i] toString], [clm[i + 1] toString]);
            if ([clm[i] getValue] != [clm[i + 1] getValue] + 1 || [clm[i] getCardColor] == [clm[i + 1] getCardColor]) return NO;
        }
        return YES;
    }
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

- (void)selectAtFreeCellIndex:(int)index
{
    if ([freeCells[index] getValue] != -1)
    {
        [freeCells[index] select];
        selectedFrecellIndex = [freeCells[index] isSelected] ? index : -1;
    }
    LOG_MODOLE(TAG, @"selected free cell index = %d", selectedFrecellIndex);
}

- (BOOL)moveCardToFreeCellIndex:(int)index from:(NSArray **)pfArr
{
    int fRow = selectedPos.row;
    int fClm = selectedPos.column;
    if (fRow != -1 && fClm != -1)
    {
        if ([mGameBoard[fClm][fRow] isEqual:lastRow[fClm]] && [freeCells[index] getValue] == -1){
            freeCells[index] = [mGameBoard[fClm] lastObject];
            [self selectCardAtRow:fRow column:fClm];
            [mGameBoard[fClm] removeLastObject];
            lastRow[fClm] = [mGameBoard[fClm] lastObject];
            *pfArr = mGameBoard[fClm];
            freeCellCount -= 1;
            selectedFrecellIndex = -1;
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
    }
    [self selectCardAtRow:fRow column:fClm];
    return YES;
}

- (struct Coord) getSelectCoord
{
    return selectedPos;
}

- (Card *)getCardAtFreeCellIdx:(int)index
{
    return freeCells[index];
}

- (int)getSelectedFreeCellIdx
{
    return self->selectedFrecellIndex;
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

- (BOOL) checkFreeCells:(NSArray<Card *> *) clm tagetColumn:(int) column
{
    if (freeCellCount >= clm.count - 1)
    {
        // have enough free cells
        LOG_MODOLE(TAG, @"has enough free cells %d move size = %d", freeCellCount, (int)clm.count);
        return YES;
    } else {
        int cardNeedToPlace = (int)clm.count - freeCellCount - 1;
        LOG_MODOLE(TAG, @"cards need to be placed %d", cardNeedToPlace);
        NSMutableArray <Card *> *tmpLastRow = lastRow;
        for (int i = 0; i < cardNeedToPlace; i ++)
        {
            Card *last = clm[clm.count - 1 - i];
            LOG_MODOLE(TAG, @"check last card %@", [last toString]);
            BOOL f = NO;
            for (int j = 0; j < num_of_game_board_columns; j ++)
            {
                if ([tmpLastRow[j] getValue] == [last getValue] + 1 && [tmpLastRow[j] getCardColor] != [last getCardColor])
                {
                    f = YES;
                    tmpLastRow[j] = last;
                    break;
                }
            }
            if (!f)
            {
                return NO;
            }
        }
    }
    return YES;
}
@end
