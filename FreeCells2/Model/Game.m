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
}
@end

@implementation Game

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        [self initParameters];
        
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
    [self initParameters];
    
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

- (NSArray *)getFreeCells
{
    return self->freeCells;
}

- (NSArray *) getOrderedDeck
{
    return self->orderedDeck;
}

- (void) placeCardToGameBard:(NSView *)gameboard superView:(NSView *) superView
{
    for (int i = 0; i < num_of_game_board_columns; i ++)
    {
        for (Card *card in mGameBoard[i])
        {
            [card placeCardToGameBoard:gameboard superView:superView gameDelegate:_mGameDelegate];
        }
    }
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
    int row = 0;
    while (nil != card)
    {
        for (int i = 0; i < num_of_game_board_columns; i++)
        {
            LOG_MODOLE(TAG, @"placing card %@ %@ at row %d column %d",card, [card toString], row, i);
            if (nil != card)
            {
                [card setColumn:i row:row];
                [mGameBoard[i] addObject:card];
                card = [mDeck dealCard];
                if (row > 0)
                {
                    mGameBoard[i][row - 1].nextCardInColumn = [mGameBoard[i] lastObject];
                }
               
                
            } else {
                for (int i = 0; i < num_of_game_board_columns; i ++)
                {
                    [lastRow addObject:[mGameBoard[i] lastObject]];
                }
                LOG_MODOLE(TAG, @"Board set\n%@",[self gameBoardToString]);
                break;
            }
        }
        row ++;
    }
#ifdef CHECK
    [self printLastRow];
#endif
}

- (void) moveCardsToRow:(int)tRow toClm:(int)tClm
{
    LOG_MODOLE(TAG, @"Start move selected %d,%d",selectedPos.row, selectedPos.column);
    
    int fRow = selectedPos.row;
    int fClm = selectedPos.column;
    Card *from = mGameBoard[fClm][fRow];
    Card *to = mGameBoard[tClm][tRow];
    
    // case 1: move single card
    if ([from isEqual:lastRow[fClm]])
    {
        LOG_MODOLE(TAG, @"move one card %@ %@ to %d %d", from, [from toString], tRow, tClm);
        if ([to isEmptyCard] || ([from getValue] + 1 == [to getValue] && [from getCardColor] != [to getCardColor]))
        {
            // can move
            // update gameboard
            // update lastRow
            // de-select
            // update ui
            if ([to isEmptyCard])
            {
                //[mGameBoard[tClm][tRow] makeCardToOther:from];
            }
            else
            {
                [from setColumn:tClm row:tRow + 1];
                [mGameBoard[tClm] addObject:from];
                
            }
            
//            if (fRow == 0)
//            {
//                // set the from card to empty card instead of removing from gameboard
//                [mGameBoard[fClm][fRow] makeEmptyCard];
//            }
//            else
//            {
                [from select];
                [mGameBoard[fClm] removeObjectAtIndex:fRow];
//            }
            [self updateColumn:tClm];
            [self updateColumn:fClm];
            
            lastRow[tClm] = from;
            lastRow[fClm] = [mGameBoard[fClm] lastObject];
            
            selectedPos.column = selected_pos_default_val;
            selectedPos.row = selected_pos_default_val;
           
            LOG_MODOLE(TAG, @"Board set\n%@",[self gameBoardToString]);
            [self printLastRow];
            
        }
        else
        {
            // cannot move
            // 1. reset selection
            // 2. update ui
            // 3. show alert
            [self selectCardAtRow:selectedPos.row column:selectedPos.column];
            [utils ShowAlert:ILLEGAL_MOVE];
        }
    }
    // case 2: move a column of cards
    else
    {
        // legal move
        if ([from getValue] + 1 == [to getValue] && [from getCardColor] != [to getCardColor])
        {
            int fSize = (int)mGameBoard[fClm].count;
            NSArray<Card *> *clm = [mGameBoard[fClm] subarrayWithRange:NSMakeRange(fRow, fSize - fRow)];
            BOOL enoughFreeCells = [self checkFreeCells:clm tagetColumn:tClm];
            if (enoughFreeCells)
            {
                // have enough free cells, can place cards
                for (int i = 0; i < fSize - fRow; i++)
                {
                    [clm[i] setColumn:tClm row:tRow + i + 1];
                    [clm[i] select];
                }
                [mGameBoard[tClm] addObjectsFromArray:clm];
                [mGameBoard[fClm] removeObjectsInRange:NSMakeRange(fRow, fSize - fRow)];
                lastRow[fClm] = [mGameBoard[fClm] lastObject];
                lastRow[tClm] = [mGameBoard[tClm] lastObject];
                [self updateColumn:tClm];
                [self updateColumn:fClm];
                
                selectedPos.column = selected_pos_default_val;
                selectedPos.row = selected_pos_default_val;
            }
            else
            {
                // cannot place cards without enough free cells
                // de-select cards
                [self selectCardAtRow:selectedPos.row column:selectedPos.column];
            }
            
        }
        // illegal move
        else
        {
            [self selectCardAtRow:selectedPos.row column:selectedPos.column];
            [utils ShowAlert:ILLEGAL_MOVE];
        }
    }
}

- (BOOL)moveCardFromFreeCellToClm:(int)tClm tRow:(int)tRow to:(NSArray * _Nullable __autoreleasing *)ptArr
{
    LOG_MODOLE(TAG, @"move free cell to column %d row %d", tClm, tRow);
//    Card *from = freeCells[selectedFrecellIndex];
//    Card *to = mGameBoard[tClm][tRow];
//    [from select];
//    if (tRow != mGameBoard[tClm].count - 1)
//    {
//        LOG_MODOLE(TAG, @"illegal move: not placed at the end of a column %d row %d", tClm, tRow);
//        selectedFrecellIndex = -1;
//        return NO;
//    }
//    if ([lastRow[tClm] getValue] == -1 || ([from getValue] + 1 == [to getValue] && [from getCardColor] != [to getCardColor]))
//    {
//        LOG_MODOLE(TAG, @"move to column %d", tClm);
//        [mGameBoard[tClm] addObject:from];
//        *ptArr = mGameBoard[tClm];
//        lastRow[tClm] = from;
//        freeCells[selectedFrecellIndex] = [[Card alloc] initEmptyCard];
//        freeCellCount -= 1;
//        selectedFrecellIndex = -1;
//        return YES;
//    }
//    selectedFrecellIndex = -1;
    return NO;
}

- (BOOL) checkSelectionAtRow:(int)row column:(int)column
{
    NSArray<Card *> *clm = mGameBoard[column];
    for (int i = row; i < clm.count - 1; i++)
    {
        LOG_MODOLE(TAG, @"i = %d, compare card %@ vs %@", i, [clm[i] toString], [clm[i + 1] toString]);
        if ([clm[i] getValue] != [clm[i + 1] getValue] + 1 || [clm[i] getCardColor] == [clm[i + 1] getCardColor]) return NO;
    }
    return YES;
}

- (void) selectCardAtRow:(int)row column:(int)column
{
    
    // case 1: move card from free cell to gameboard
    //         selectedPos = {free_cell_row_index, freecellIndex}
    //         row != free_cell_row_index
    if (selectedPos.row == free_cell_row_index && selectedPos.column != selected_pos_default_val && row != free_cell_row_index)
    {
        LOG_MODOLE(TAG, @"select card case 1");
    }
    // case 2: change the position in free cell
    //         selectedPos = {free_cell_row_index, freecellIndex}
    //         row == free_cell_row_index
    else if (selectedPos.row == free_cell_row_index && selectedPos.column != selected_pos_default_val && row == free_cell_row_index)
    {
        LOG_MODOLE(TAG, @"select card case 2")
    }
    // case 3: select card
    //         selectedPos == {-1, -1}
    else if (selectedPos.column == selected_pos_default_val && selectedPos.row == selected_pos_default_val && row != free_cell_row_index)
    {
        LOG_MODOLE(TAG, @"select card case 3");
        if ([mGameBoard[column][row] isEmptyCard]) return; 
        // check if can select at row clm
        // case 1: selected at the last card
        if ([mGameBoard[column][row] isEqual:lastRow[column]])
        {
            [mGameBoard[column][row] select];
            selectedPos.row = row;
            selectedPos.column = column;
        }
        // case 2: select a column
        else
        {
            NSArray<Card *> *clm = mGameBoard[column];
            BOOL flag = [self checkSelectionAtRow:row column:column];
            int size = (int)clm.count;
            if (flag)
            {
                for(int i = row; i < size; i ++)
                {
                    [clm[i] select];
                }
                selectedPos.row = row;
                selectedPos.column = column;
                
            }
        }
    }
    // case 4: deselect card
    //         selectedPos == {row, column}
    else if (selectedPos.row == row && selectedPos.column == column)
    {
        LOG_MODOLE(TAG, @"select card case 4");
        int size = (int) mGameBoard[column].count;
        for (int i = row; i < size; i++)
        {
             [mGameBoard[column][i] select];
        }
        selectedPos.row = -1;
        selectedPos.column = -1;
    }
    // case 5: move card in game board
    //         selectedPos.row != free_cell_row_index
    //         selectedPos != {default, default}
    else if (selectedPos.column >= 0 && selectedPos.row >= 0 && row != free_cell_row_index)
    {
        LOG_MODOLE(TAG, @"seelect card case 5");
        [self moveCardsToRow:row toClm:column];
    }
    // case 6: move card to free cells
    //         selectedPos.row != free_cell_row_index
    //         selectedPos != {default, default}
    //         row == free_cell_column_index
    else if (selectedPos.column >= 0 && selectedPos.row >= 0 && row == free_cell_row_index)
    {
        LOG_MODOLE(TAG, @"select card case 6");
        // place card to free cell if the cell is empty
        // and only one card is selected
        Card *from = mGameBoard[selectedPos.column][selectedPos.row];
        if ([freeCells[column] isEmptyCard] && [lastRow[selectedPos.column] isEqual:from])
        {
            [self moveCardToFreeCellIndex:column from:selectedPos.column];
            selectedPos.column = selected_pos_default_val;
            selectedPos.row = selected_pos_default_val;
        }
        else
        {
            [self selectCardAtRow:selectedPos.row column:selectedPos.column];
            [utils ShowAlert:ILLEGAL_MOVE];
        }
        
        selectedPos.column = selected_pos_default_val;
        selectedPos.row = selected_pos_default_val;
    }
    // case 7: select card in free cell
    //         row == free_cell_column_index
    //         selectedPos == {default, default}
    else if (selectedPos.column == selected_pos_default_val && selectedPos.row == selected_pos_default_val && row == free_cell_row_index)
    {
       LOG_MODOLE(TAG, @"select card case 7")
    }
}

- (void)selectAtFreeCellIndex:(int)index
{
//    if ([freeCells[index] getValue] != -1)
//    {
//        [freeCells[index] select];
//        selectedFrecellIndex = [freeCells[index] isSelected] ? index : -1;
//    }
//    LOG_MODOLE(TAG, @"selected free cell index = %d", selectedFrecellIndex);
}

- (void)moveCardToFreeCellIndex:(int)index from:(int) fClm
{
    Card *from = [mGameBoard[fClm] lastObject];
    freeCells[index] = from;
    [from setColumn:index row:free_cell_row_index];
    [from select];
    [mGameBoard[fClm] removeLastObject];
    
    [self updateColumn:fClm];
    [from placeCardToFreeCell:index];
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
    return 1;//self->selectedFrecellIndex;
}

- (void) printLastRow
{
    NSMutableString *print = [NSMutableString stringWithString:@"last row = [\n"];
    for (int i = 0; i < num_of_game_board_columns; i++)
    {
        [print appendFormat:@"%@ %@\n",lastRow[i], [lastRow[i] toString]];
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

- (BOOL) placeAtFreeCellIndex:(int)index board:(NSMutableArray<NSArray<Card *> *> *__autoreleasing *)board
{
    return YES;
}

- (void) initParameters
{
    selectedPos.row = selected_pos_default_val;
    selectedPos.column = selected_pos_default_val;
    freeCellCount = 4;
}

- (void) updateColumn:(int) clm
{
    NSInteger count = mGameBoard[clm].count;
    for (Card *card in mGameBoard[clm])
    {
        [card updateCardPositionWithColumnSize:count];
    }
}
@end
