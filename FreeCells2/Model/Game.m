//
//  Game.m
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import "Game.h"
#import "LOG.h"
#import "../Delegate/AlertDelegate.h"

#define TAG "Game"

@interface Game()<AlertDelegate>
{
    Deck *mDeck;
    NSMutableArray<NSMutableArray<Card *> *> *mGameBoard; // array of rows
    NSMutableArray<Card *> *freeCells;
    NSMutableArray<Card *> *orderedDeck;
    NSMutableArray<Card *> *lastRow;
    
    NSMutableArray<CardImageView *> *orderedCells;
    
    struct Coord selectedPos;
    struct Coord holdPos;
    
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

    for (int i = 0; i < num_of_ordered_cells; i++)
    {
        [orderedCells[i] setImage:[NSImage imageNamed:[orderedDeck[i] getCardImageString]]];
    }
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

- (void) placeCardToGameBard:(NSView *)gameboard superView:(NSView *) superView orderedCells:(NSMutableArray<CardImageView *> *)cells
{
    for (int i = 0; i < num_of_game_board_columns; i ++)
    {
        for (Card *card in mGameBoard[i])
        {
            [card placeCardToGameBoard:gameboard superView:superView gameDelegate:_mGameDelegate];
        }
    }
    
    orderedCells = cells;
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
            if ((int)mGameBoard[i].count  - 1 == row)
            {
                // last row
                emptyCellCount ++;
                [toReturn appendFormat:@"%@|", [utils GetSpaces:[mGameBoard[i][row] toString]]];
            }
            else if ((int)mGameBoard[i].count  - 1  < row)
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
    LOG_MODOLE(TAG, @"Start move selected %d,%d to %d,%d",selectedPos.row, selectedPos.column, tRow, tClm);
    
    int fRow = selectedPos.row;
    int fClm = selectedPos.column;
    Card *from = mGameBoard[fClm][fRow];
    Card *to = lastRow[tClm];
    
    // case 1: move single card
    if ([from isEqual:lastRow[fClm]])
    {
        LOG_MODOLE(TAG, @"move one card %@ %@ to %d %d", from, [from toString], tRow, tClm);
        if ([to isEmptyCard] || [self canPlaceCard:from toCard:to])
        {
            // can move
            // update gameboard
            // update lastRow
            // de-select
            // update ui
            [from setColumn:tClm row: [to isEmptyCard] ? 0 : tRow + 1];
            [mGameBoard[tClm] addObject:from];
            [from select];
            [mGameBoard[fClm] removeObjectAtIndex:fRow];
            
            [self updateColumn:tClm];
            [self updateColumn:fClm];
            
            lastRow[tClm] = from;
            lastRow[fClm] =  [self isColumnEmpty:fClm] ?  [[Card alloc] initEmptyCard] : [mGameBoard[fClm] lastObject];
            
            selectedPos.column = selected_pos_default_val;
            selectedPos.row = selected_pos_default_val;
            
        }
        else
        {
            // cannot move
            // 1. reset selection
            // 2. update ui
            // 3. show alert
            [self selectCardAtRow:selectedPos.row column:selectedPos.column];
            [utils ShowAlert:ILLEGAL_MOVE delegate:nil];
        }
    }
    // case 2: move a column of cards
    else
    {
        // move a column of card to an empty column
        if ([to isEmptyCard])
        {
            holdPos.row = tRow;
            holdPos.column = tClm;
            [utils ShowAlert:MOVE_CARD delegate:self];
        }
        // legal move
        else if ([self canPlaceCard:from toCard:to])
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
                lastRow[fClm] = [self isColumnEmpty:fClm] ? [[Card alloc] initEmptyCard] : [mGameBoard[fClm] lastObject];
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
            [utils ShowAlert:ILLEGAL_MOVE delegate:nil];
        }
    }
}

- (void)moveCardFromFreeCellToClm:(int)tClm tRow:(int)tRow
{
    LOG_MODOLE(TAG, @"move free cell to column %d row %d", tClm, tRow);
    int index = selectedPos.column;
    int count = (int)mGameBoard[tClm].count;
    Card  *from = freeCells[index];
    [from select];
    [from setColumn:tClm row: count == 0 ? 0 : tRow + 1];
    [mGameBoard[tClm] addObject:from];
    lastRow[tClm] = from;
    freeCells[index] = [[Card alloc] initEmptyCard];
    
    [self updateColumn:tClm];
    
    freeCellCount += 1;
    
}

- (BOOL) checkSelectionAtRow:(int)row column:(int)column
{
    NSArray<Card *> *clm = mGameBoard[column];
    for (int i = row; i < clm.count - 1; i++)
    {
        LOG_MODOLE(TAG, @"i = %d, compare card %@ vs %@", i, [clm[i] toString], [clm[i + 1] toString]);
        if (![self canPlaceCard:clm[i + 1] toCard:clm[i]]) return NO;
    }
    return YES;
}

- (void) selectCardAtRow:(int)row column:(int)column
{
    
    // case 1: move card from free cell to gameboard
    //         selectedPos = {free_cell_row_index, freecellIndex}
    //         row != free_cell_row_index
    if (selectedPos.row == free_cell_row_index && selectedPos.column != selected_pos_default_val && row != free_cell_row_index && row != ordered_cell_row_index)
    {
        LOG_MODOLE(TAG, @"select card case 1");
        // show alert if is not clicked at the last row
        // or cannot move
        Card *from = freeCells[selectedPos.column];
        Card *temp = [mGameBoard[column] lastObject];
        LOG_MODOLE(TAG, @"COUNT = %ld %d", mGameBoard[column].count, row);
        if ( mGameBoard[column].count > 0 && (row != mGameBoard[column].count - 1 ||
            ![self canPlaceCard:from toCard:temp]))
        {
            [freeCells[selectedPos.column] select];
            [utils ShowAlert:ILLEGAL_MOVE delegate:nil];
            
        }
        else
        {
            [self moveCardFromFreeCellToClm:column tRow:row];
            [self autoFinish:auto_finish_card_value_threshold];
            
            LOG_MODOLE(TAG, @"Board set\n%@",[self gameBoardToString]);
            [self printLastRow];
        }
        
        selectedPos.column = selected_pos_default_val;
        selectedPos.row = selected_pos_default_val;
    }
    // case 2: change the position in free cell
    //         selectedPos = {free_cell_row_index, freecellIndex}
    //         row == free_cell_row_index
    else if (selectedPos.row == free_cell_row_index && selectedPos.column != selected_pos_default_val
             && selectedPos.column != column && row == free_cell_row_index)
    {
        LOG_MODOLE(TAG, @"select card case 2");
        if ([freeCells[column] isEmptyCard])
        {
            // exchange position if clicked free cell is available
            int fClm = selectedPos.column;
            Card *from = freeCells[fClm];
            freeCells[column] = from;
            [from setColumn:column row:free_cell_row_index];
            freeCells[fClm] = [[Card alloc] initEmptyCard];
            [from select];
            [from placeCardToFreeCell:column];
            
            selectedPos.column = selected_pos_default_val;
            selectedPos.row = selected_pos_default_val;
        }
        else
        {
            // change the selection
            [freeCells[selectedPos.column] select];
            [freeCells[column] select];
            
            selectedPos.column = column;
        }
    }
    // case 3: select card
    //         selectedPos == {-1, -1}
    else if (selectedPos.column == selected_pos_default_val && selectedPos.row == selected_pos_default_val && row != free_cell_row_index && row != ordered_cell_row_index)
    {
        LOG_MODOLE(TAG, @"select card case 3");
        if ([self isColumnEmpty:column]) return;
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
    // case 4: deselect card on board
    //         selectedPos == {row, column}
    else if (selectedPos.row == row && selectedPos.column == column && row != free_cell_row_index && row != ordered_cell_row_index)
    {
        LOG_MODOLE(TAG, @"select card case 4");
        int size = (int) mGameBoard[column].count;
        for (int i = row; i < size; i++)
        {
             [mGameBoard[column][i] select];
        }
        selectedPos.row = selected_pos_default_val;
        selectedPos.column = selected_pos_default_val;
    }
    // case 5: move card in game board
    //         selectedPos.row != free_cell_row_index
    //         selectedPos != {default, default}
    else if (selectedPos.column >= 0 && selectedPos.row >= 0 && row != free_cell_row_index && row != ordered_cell_row_index)
    {
        LOG_MODOLE(TAG, @"select card case 5");
        [self moveCardsToRow:row toClm:column];
        [self autoFinish:auto_finish_card_value_threshold];
        
        LOG_MODOLE(TAG, @"Board set\n%@",[self gameBoardToString]);
        [self printLastRow];
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
            [self autoFinish:auto_finish_card_value_threshold];
        }
        else
        {
            [self selectCardAtRow:selectedPos.row column:selectedPos.column];
            [utils ShowAlert:ILLEGAL_MOVE delegate:nil];
        }
        
        selectedPos.column = selected_pos_default_val;
        selectedPos.row = selected_pos_default_val;
        
        LOG_MODOLE(TAG, @"Board set\n%@",[self gameBoardToString]);
        [self printLastRow];
    }
    // case 7: select card in free cell
    //         row == free_cell_column_index
    //         selectedPos == {default, default}
    else if (selectedPos.column == selected_pos_default_val && selectedPos.row == selected_pos_default_val && row == free_cell_row_index)
    {
        LOG_MODOLE(TAG, @"select card case 7");
        [freeCells[column] select];
        selectedPos.column = column;
        selectedPos.row = free_cell_row_index;
    }
    // case 8: deselect card in free cell
    //         row == free_cell_column_index
    //         selectpos = {free_cell_index, column}
    else if (selectedPos.column == column && selectedPos.row == free_cell_row_index && row == free_cell_row_index)
    {
        LOG_MODOLE(TAG, @"select card case 8");
        [freeCells[column] select];
        selectedPos.column = selected_pos_default_val;
        selectedPos.row = selected_pos_default_val;
    }
    // case 9: move card to ordered cell from gameboard
    //         row == ordered_cell_row_index
    //         selectedPos != {default, default}
    else if (selectedPos.column != selected_pos_default_val && selectedPos.row >= 0 && row == ordered_cell_row_index)
    {
        LOG_MODOLE(TAG, @"select card case 9");
        if ([self isSelectedAtLastRow])
        {
            [self moveCardToOrderedCell:column from:selectedPos.column];
            [self autoFinish:auto_finish_card_value_threshold];
        }
    }
    // case 10: move card to ordered cell from free cell
    //          row == ordered_cell_row_index
    // 
    else if (selectedPos.column != selected_pos_default_val && selectedPos.row == free_cell_row_index && row == ordered_cell_row_index)
    {
        LOG_MODOLE(TAG, @"select card case 10");

        Card *from = freeCells[selectedPos.column];
        Card *target = orderedDeck[column];
        
        if ([self canOrderCard:from toCard:target])
        {
            orderedDeck[column] = from;
            [from select];
            
            [orderedCells[column] setImage:[NSImage imageNamed:[from getCardImageString]]];
            
            freeCells[selectedPos.column] = [[Card alloc] initEmptyCard];
            [from moveOutFromGameboard];
            
            freeCellCount += 1;
        }
        else
        {
            [from select];
        }
        
        selectedPos.column = selected_pos_default_val;
        selectedPos.row = selected_pos_default_val;
    }
    
    if ([self isLost])
    {
        [utils ShowAlert:GAME_LOST delegate:self];
    }
    if ([self isWin])
    {
        [utils ShowAlert:GAME_WIN delegate:nil];
    }
}

- (void)moveCardToFreeCellIndex:(int)index from:(int) fClm
{
    Card *from = [mGameBoard[fClm] lastObject];
    freeCells[index] = from;
    [from setColumn:index row:free_cell_row_index];
    [from select];
    [mGameBoard[fClm] removeLastObject];
    lastRow[fClm] = [self isColumnEmpty:fClm] ? [[Card alloc] initEmptyCard] : [mGameBoard[fClm] lastObject];
    
    [self updateColumn:fClm];
    [from placeCardToFreeCell:index];
     
    freeCellCount -= 1;
}

- (void) moveCardToOrderedCell:(int) index from:(int) fClm
{
    Card *from = [mGameBoard[fClm] lastObject];
    Card *target = orderedDeck[index];
    
    if ([self canOrderCard:from toCard:target])
    {
        orderedDeck[index] = from;
        [from select];
        
        [orderedCells[index] setImage:[NSImage imageNamed:[from getCardImageString]]];
        
        [mGameBoard[fClm] removeLastObject];
        lastRow[fClm] = [self isColumnEmpty:fClm] ? [[Card alloc] initEmptyCard] : [mGameBoard[fClm] lastObject];
        [from moveOutFromGameboard];
        
        [self updateColumn:fClm];
        
        selectedPos.column = selected_pos_default_val;
        selectedPos.row = selected_pos_default_val;
    }
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
    return [self countFreeCells:clm targetClm:column] >= (int)clm.count - 1;
}

- (int) countFreeCells:(NSArray<Card *> *) column targetClm:(int) clm
{
    int clmCount = (int)column.count;
    int count = 0;
    
    NSMutableArray<Card *> *tempLastRow = [NSMutableArray arrayWithArray:lastRow];
    int index = 0;
    int checked = 0;
    
    while(index < clmCount && checked < num_of_game_board_columns - 1)
    {
        checked = 0;
        Card *card = column[clmCount - index - 1];
        LOG_MODOLE(TAG, @"counting at card index = %d card = %@, count = %d", index, [card toString], count);
        for (int i = 0; i < tempLastRow.count; i++)
        {
            if (i == clm)
            {
                continue;
            }
            Card *lastCard = tempLastRow[i];
            if ([self canPlaceCard:card toCard:lastCard] || [lastCard isEmptyCard])
            {
                count ++;
                index ++;
                break;
            }
            else
            {
                checked ++;
            }
        }
    }
    LOG_MODOLE(TAG, @"free cells = %d", count + freeCellCount);
    return count + freeCellCount;
}

- (void) initParameters
{
    selectedPos.row = selected_pos_default_val;
    selectedPos.column = selected_pos_default_val;
    holdPos.row = selected_pos_default_val;
    holdPos.column = selected_pos_default_val;
    freeCellCount = 4;
}

- (void) updateColumn:(int) clm
{
    
    NSInteger count = mGameBoard[clm].count;

    if (count == 0) return;
    for (Card *card in mGameBoard[clm])
    {
        [card updateCardPositionWithColumnSize:count];
    }
}

- (BOOL) isSelectedAtLastRow
{
    return selectedPos.row == ((int)mGameBoard[selectedPos.column].count) - 1;
}

- (BOOL) isColumnEmpty:(int) clm
{
    return (int)(mGameBoard[clm].count) == 0;
}

- (void)alertDidEnd:(NSInteger)returnCode type:(enum alert_type) type
{
    LOG_MODOLE(TAG, @"return code = %ld alert type = %d", returnCode, type);
    if (type == MOVE_CARD)
    {
        int fRow = selectedPos.row;
        int fClm = selectedPos.column;
        int tClm = holdPos.column;
        int tRow = holdPos.row;
        NSArray<Card *> *column = mGameBoard[fClm];
           
        switch (returnCode) {
            case move_a_card_code:
            {
                LOG_MODOLE(TAG, @"move one card from %d,%d to  %d,%d", fRow, fClm, tRow, tClm);
                Card *moveCard = [column lastObject];
                [moveCard setColumn:tClm row:tRow];
                   
                int index = 0;
                for (Card *card in column)
                {
                    if (index >= fRow)
                    {
                        [card select];
                    }
                    int c = (int)[card getCoordInBoard].column;
                    [card updateCardPositionWithColumnSize:mGameBoard[c].count];
                    index ++;
                }
                   
                [mGameBoard[fClm] removeLastObject];
                [mGameBoard[tClm] addObject:moveCard];
                
                break;
            }
            case move_a_column_code:
            {
                LOG_MODOLE(TAG, @"move a column of card from %d,%d to  %d,%d", fRow, fClm, tRow, tClm);
                int cardToMove = (int)column.count - fRow;
                int freeCells = [self countFreeCells: column targetClm:tClm] ;
                int cardCanMove =  freeCells >= cardToMove ? cardToMove : freeCells + 1;
                int startIndex = (int)column.count - cardCanMove;
                int index = 0;
                for (int i = 0; i < column.count; i++)
                {
                    if (i >= fRow)
                    {
                        [column[i] select];
                    }
                    if (i >= startIndex)
                    {
                        [column[i] setColumn:tClm row:index];
                           index ++;
                           [mGameBoard[tClm] addObject:column[i]];
                       }
                }
                   
                [mGameBoard[fClm] removeObjectsInRange:NSMakeRange(startIndex, cardCanMove)];
                   
                [self updateColumn:fClm];
                [self updateColumn:tClm];
                   
                break;
            }
            default:
                break;
        }
        lastRow[tClm] = [mGameBoard[fClm] lastObject];
        lastRow[fClm] = [self isColumnEmpty:fClm] ? [[Card alloc] initEmptyCard] : [column lastObject];
           
        selectedPos.row = selected_pos_default_val;
        selectedPos.column = selected_pos_default_val;
        holdPos.row = selected_pos_default_val;
        holdPos.column = selected_pos_default_val;
           
        LOG_MODOLE(TAG, @"Board set\n%@",[self gameBoardToString]);
        [self printLastRow];
    }
    else if (type == GAME_LOST)
    {
        [_mGameDelegate onGameReset];
    }
   
}

- (BOOL) canPlaceCard:(Card *) from toCard:(Card *) to
{
    return ([from getCardColor] != [to getCardColor] && [from getValue] + 1 == [to getValue]) || [to isEmptyCard];
}

- (BOOL) canOrderCard:(Card *) from toCard:(Card *) to
{
    return ([from getSuit] == [to getSuit] && [from getValue] == [to getValue] + 1) || ([from getValue] == 1 && [to isEmptyCard]);
}

- (BOOL) isWin
{
    int ordered = 0;
    for (Card *card in orderedDeck)
    {
        if([card getValue] == 13)
        {
            ordered ++;
        }
    }
    LOG_MODOLE(TAG, @"card ordered = %d", ordered);
    return ordered == num_of_suits;
}

- (BOOL) isLost
{
    LOG_MODOLE(TAG, @"freeCellCount = %d", freeCellCount);
    if (freeCellCount > 0)
    {
        return NO;
    }
    else
    {
        // check if there is a card can be moved on game board
        for (int i = 0; i < num_of_game_board_columns; i++)
        {
            for (int j = 0; j < num_of_game_board_columns; j++)
            {
                if (i != j)
                {
                    Card *from = lastRow[i];
                    Card *to = lastRow[j];
                    if ([self canPlaceCard:from toCard:to])
                    {
                        return NO;
                    }
                }
            }
        }
        // check if there is a card in the free cells can be moved to game board
        for (int i = 0; i < num_of_free_cells; i ++)
        {
            for (int j = 0; j < num_of_game_board_columns; j++)
            {
                Card *from = freeCells[i];
                Card *to = lastRow[j];
                if ([self canPlaceCard:from toCard:to])
                {
                    return NO;
                }
            }
        }
        // check if there is a card on the game board that can be collected into ordered deck
        for (int i = 0; i < num_of_game_board_columns; i++)
        {
            for (int j = 0; j < num_of_ordered_cells; j++)
            {
                Card *from = lastRow[i];
                Card *to = orderedDeck[j];
                if ([self canOrderCard:from toCard:to])
                {
                    return NO;
                }
            }
        }
        // check if there is a card in free cells that can be collected into ordered deck
        for (int i = 0; i < num_of_free_cells; i++)
        {
            for (int j = 0; j < num_of_ordered_cells; j++)
            {
                Card *from = freeCells[i];
                Card *to = orderedDeck[j];
                if ([self canOrderCard:from toCard:to])
                {
                    return NO;
                }
            }
        }
        return YES;
    }
}

- (void) autoFinish:(int) maxLimit
{
    for (int i = 0; i < num_of_game_board_columns; i ++)
    {
        Card *from = lastRow[i];
        LOG_MODOLE(TAG, @"from card = %@", [from toString]);
        if ([from getValue] > maxLimit || [from isEmptyCard])
        {
            continue;
        }
        else
        {
            for (int j = 0; j < num_of_ordered_cells; j++)
            {
                Card *to = orderedDeck[j];
                if ([self canOrderCard:from toCard:to])
                {
                    orderedDeck[j] = from;
                    
                    [orderedCells[j] setImage:[NSImage imageNamed:[from getCardImageString]]];
                    
                    [mGameBoard[i] removeLastObject];
                    lastRow[i] = [self isColumnEmpty:i] ? [[Card alloc] initEmptyCard] : [mGameBoard[i] lastObject];
                    [from moveOutFromGameboard];
                    
                    [self updateColumn:i];
                    LOG_MODOLE(TAG, @"Board set\n%@",[self gameBoardToString]);
                    [self printLastRow];
                    [self autoFinish:maxLimit];
                    break;
                }
            }
            
        }
    }
}
@end
