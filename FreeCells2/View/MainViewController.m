//
//  ViewController.m
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import "MainViewController.h"
#import "utils.h"
#import "LOG.h"
#import "CardImageView.h"

#import "Game.h"

#define TAG "MainVC"

enum card_view_type
{
    FREE_CELL_VIEW,
    ORDERED_VIEW,
    EMPTY_CARD_VIEW,
    CARD_VIEW,
    TYPE_MAX,
};

@interface MainViewController()
{
    IBOutlet NSButton *mIndoicator;
    IBOutlet CardImageView *mFreeCell0;
    IBOutlet CardImageView *mFreeCell1;
    IBOutlet CardImageView *mFreeCell2;
    IBOutlet CardImageView *mFreeCell3;
    IBOutlet CardImageView *mOrderedDeck0;
    IBOutlet CardImageView *mOrderedDeck1;
    IBOutlet CardImageView *mOrderedDeck2;
    IBOutlet CardImageView *mOrderedDeck3;
    IBOutlet NSView *mGameBoardView;
    
    NSTrackingArea *mTrackingArea;
    
    Game *mGame;
    NSMutableArray<NSArray <Card *> *> *mBoard;
    NSMutableArray<NSMutableArray<CardImageView *> *> *mCardViewArr;
    
    CGFloat gap_between_cards;
    
}
@end
@implementation MainViewController

- (instancetype) initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        mTrackingArea = [[NSTrackingArea alloc] initWithRect:CGRectMake(0, 0, window_width, window_height)
                                                     options:(NSTrackingMouseMoved|NSTrackingActiveInKeyWindow)
                                                       owner:self
                                                    userInfo:nil];
        
        mGame = [[Game alloc] init];
        mBoard = [NSMutableArray arrayWithArray:[mGame getGameBoard]];
        
        mCardViewArr = [NSMutableArray array];
        
        gap_between_cards = (game_board_width - (card_width * num_of_game_board_columns)) * 1.0f / ((num_of_game_board_columns - 1) * 1.0f);
    }
    return self;
}

- (void)viewDidLoad {
    [self.view addTrackingArea:mTrackingArea];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupBoard];
    
}

- (void) mouseMoved:(NSEvent *)event
{
    CGPoint mousePoint = [event locationInWindow];
    if (mousePoint.x < window_width / 2)
    {
        [mIndoicator setImage:[NSImage imageNamed:@"indicator_left"]];
    } else
    {
        [mIndoicator setImage:[NSImage imageNamed:@"indicator_right"]];
    }
}

- (void) setupBoard
{
    // setup empty card first
    LOG_UI(TAG, @"gap between cards = %f", gap_between_cards);
    
    for (int i = 0; i < num_of_game_board_columns; i ++)
    {
        CardImageView *emptyCardView = [CardImageView imageViewWithImage:[NSImage imageNamed:@"cardCell"]];
        [emptyCardView setFrame:CGRectMake(i * (card_width + gap_between_cards),
                                           game_board_height - card_height,
                                           card_width,
                                           card_height)];
        emptyCardView.index = i;
        [emptyCardView setTarget:self];
        [emptyCardView setAction:@selector(onEmptyCardClicked:)];
        
        [mGameBoardView addSubview:emptyCardView];
    }
    [self layoutCards];
}

- (void) layoutCards
{
    for(int i = 0; i < num_of_game_board_columns; i ++)
    {
        NSArray <Card *> *column = mBoard[i];
        NSMutableArray<CardImageView *> *cardViewColumn = [NSMutableArray array];
        
        CGFloat start_x = i * (card_width + gap_between_cards);
        CGFloat start_y = game_board_height - card_height;
        
        int row = 0;
        for (Card *card in column)
        {
            CardImageView *viewCard = [CardImageView imageViewWithImage:[NSImage imageNamed:[card getCardImageString]]];
            [viewCard setFrame:CGRectMake(start_x,
                                          start_y - card_vertical_overlap_gap * row,
                                          card_width,
                                          card_height)];
            viewCard.row = row;
            viewCard.column = i;
            viewCard.canRightClick = YES;
            viewCard.target = self;
            viewCard.action = @selector(onCardClicked:);
            viewCard.rightMouseDownAction = @selector(onCardRightClickedDown:);
            viewCard.rightMouseUpAction = @selector(onCardRightClickedUp:);
            [mGameBoardView addSubview:viewCard];
            [cardViewColumn addObject:viewCard];
            row ++;
        }
        [mCardViewArr addObject:cardViewColumn];
    }
}

- (IBAction)onIndicatorClicked:(NSButton *)sender {
    [self removeAllCardViews];
    
    [mGame resetGame];
    mBoard = [NSMutableArray arrayWithArray:[mGame getGameBoard]];
    mCardViewArr = [NSMutableArray array];
    [self layoutCards];
    
    [mFreeCell0 setImage:[NSImage imageNamed:@"cardCell"]];
    [mFreeCell1 setImage:[NSImage imageNamed:@"cardCell"]];
    [mFreeCell2 setImage:[NSImage imageNamed:@"cardCell"]];
    [mFreeCell3 setImage:[NSImage imageNamed:@"cardCell"]];
    
    [mOrderedDeck0 setImage:[NSImage imageNamed:@"cardCell"]];
    [mOrderedDeck1 setImage:[NSImage imageNamed:@"cardCell"]];
    [mOrderedDeck2 setImage:[NSImage imageNamed:@"cardCell"]];
    [mOrderedDeck3 setImage:[NSImage imageNamed:@"cardCell"]];
}

- (IBAction)onFreeCellClicked:(CardImageView *)sender {
    int index = (int)sender.index;
    LOG_UI(TAG, @"clicked on free cell %d", index);
    int fClm = [mGame getSelectCoord].column;
    int fRow = [mGame getSelectCoord].row;
    
    if (fClm == -1 && fRow == -1)
    {
        // select card in free cell
        [mGame selectAtFreeCellIndex:index];
        if ([[mGame getCardAtFreeCellIdx:index] getValue] != -1)
        {
            [sender setImage:[NSImage imageNamed:[[mGame getCardAtFreeCellIdx:index] getCardImageString]]];
        }
    }
    else
    {
        // move card to free cell
        NSArray *from = mBoard[fClm];
        BOOL canPlace = [mGame moveCardToFreeCellIndex:index from:&from];
        mBoard[fClm] = from;
        if (canPlace)
        {
            [sender setImage:[NSImage imageNamed:[[mGame getCardAtFreeCellIdx:index] getCardImageString]]];
            [[mCardViewArr[fClm] lastObject] removeFromSuperview];
            [mCardViewArr[fClm] removeLastObject];
            
            if (mCardViewArr[fClm].count > max_fixd_card_per_column)
            {
                [self realignCards:mCardViewArr[fClm]];
            } else if ((int)mCardViewArr[fClm].count == max_fixd_card_per_column)
            {
                [self realignCardsToNormalGap:mCardViewArr[fClm]];
            }
        } else
        {
            [self selectCardAtRow:fRow column:fClm];
            [utils ShowAlert:ILLEGAL_MOVE];
        }
    }
}

- (IBAction)onOrderedDeckClicked:(CardImageView *)sender {
}


- (void) onEmptyCardClicked:(CardImageView *) emptyCardView
{
    int index = (int)emptyCardView.index;
    LOG_UI(TAG, @"clicked on empty card %d", index);
}

- (void) onCardClicked:(CardImageView *) card
{
    int row = (int)card.row;
    int column = (int)card.column;
    LOG_UI(TAG, @"clicked on card %d %d", row, column);
    
    if (![mGame checkSelectionAtRow:row column:column])
    {
        int selectedFreeCellIndex = [mGame getSelectedFreeCellIdx];
        int fClm = [mGame getSelectCoord].column;
        int fRow = [mGame getSelectCoord].row;
        LOG_UI(TAG, @"selected free cell index %d, selected card = %d,%d", selectedFreeCellIndex, fRow, fClm);
        // nothing selected, skip
        if (selectedFreeCellIndex == -1 && (fClm == -1 || fRow == -1) )
        {
            return;
        } else if (selectedFreeCellIndex != -1)
        {
            [[self getCardView:FREE_CELL_VIEW index:selectedFreeCellIndex] setImage:[NSImage imageNamed:[[mGame getCardAtFreeCellIdx:selectedFreeCellIndex] getCardImageString]]];
            [utils ShowAlert:ILLEGAL_MOVE];
            return;
        }
        
        // move card
        NSArray *from = mBoard[fClm];
        NSArray *to = mBoard[column];
                       
        BOOL canMove = [mGame moveCardsToRow:row toClm:column from:&from to:&to];
        mBoard[fClm] = from;
        mBoard[column] = to;
#ifdef CHECK
        for (Card *c in mBoard[fClm])
        {
            LOG_UI(TAG, @"%@\n isSelected = %d", [c toString], [c isSelected]);
        }
        //LOG_UI(TAG, @"=================");
        for (Card *c in  mBoard[column])
        {
            LOG_UI(TAG, @"%@\n isSelected = %d", [c toString], [c isSelected]);
        }
#endif
        if (canMove)
        {
            [self moveCardViewsFromRow:fRow fromColumn:fClm toRow:row toColumn:column];
            [self selectCardAtRow:row column:column];
        } else {
            [self selectCardAtRow:fRow column:fClm];
            [utils ShowAlert:ILLEGAL_MOVE];
        }
        return;
    } else {
        // select card(s)
        mBoard[column] = [mGame selectCardAtRow:row column:column];
        [self selectCardAtRow:row column:column];
    }
}

- (void) onCardRightClickedDown:(CardImageView *) card
{
    int row = (int)card.row;
    int column = (int)card.column;
    LOG_UI(TAG, @"right clicked down on card %d %d", row, column);
    
    if (row < mCardViewArr[column].count - 1) {
        CardImageView *view = mCardViewArr[column][row];
        [mGameBoardView addSubview:view];
        [view becomeFirstResponder];
    }
}

- (void) onCardRightClickedUp:(CardImageView *) card
{
    int row = (int)card.row;
    int column = (int)card.column;
    LOG_UI(TAG, @"right clicked up on card %d %d", row, column);
    
    if (row < mCardViewArr[column].count - 1) {
        CardImageView *view = mCardViewArr[column][row];
        [view removeFromSuperview];
        [mGameBoardView addSubview:view positioned:NSWindowBelow relativeTo:mCardViewArr[column][row + 1]];
        
    }
}

- (void) selectCardAtRow:(int) row column:(int) column
{
    for (int i = row; i < mBoard[column].count; i++)
    {
        [mCardViewArr[column][i] setImage:[NSImage imageNamed:[mBoard[column][i] getCardImageString]]];
    }
}

- (void) moveCardViewsFromRow:(int)fRow fromColumn:(int) fClm toRow:(int) tRow toColumn:(int) tClm
{
    NSMutableArray<CardImageView *> *fromViews = mCardViewArr[fClm];
    NSMutableArray<CardImageView *> *toViews = mCardViewArr[tClm];
    int originalToCount = (int)toViews.count;
    for (int i = fRow; i < fromViews.count; i++)
    {
        fromViews[i].column = tClm;
        fromViews[i].row = (int)toViews.count;
        
        [toViews addObject:fromViews[i]];
    }
    
    [fromViews removeObjectsInRange:NSMakeRange(fRow, fromViews.count - fRow)];
    
    
    if (fromViews.count > max_fixd_card_per_column)
    {
        [self realignCards:fromViews];
    }
    else if (fromViews.count ==  max_fixd_card_per_column)
    {
        [self realignCardsToNormalGap:fromViews];
    }
    
    if (toViews.count > max_fixd_card_per_column)
    {
        [self realignCards:toViews];
    } else
    {
        CGFloat start_x = (gap_between_cards + card_width) * tClm;
        CGFloat start_y = game_board_height - card_height - ((originalToCount - 1)* card_vertical_overlap_gap);
        for (int i = originalToCount; i < toViews.count; i++)
        {
            [toViews[i] setFrame:CGRectMake(start_x,
                                            start_y - card_vertical_overlap_gap,
                                            card_width,
                                            card_height)];
            [mGameBoardView addSubview:toViews[i]];
            [toViews[i] becomeFirstResponder];
            start_y -= card_vertical_overlap_gap;
        }
    }
        
    mCardViewArr[fClm] = fromViews;
    mCardViewArr[tClm] = toViews;
}

- (void) realignCards:(NSMutableArray<CardImageView *> *) cards
{
    CGFloat verticalGap = ((game_board_height - card_height) * 1.0f) / cards.count;
    CGFloat start_x = cards[0].frame.origin.x;
    CGFloat start_y = game_board_height - card_height;
    LOG_UI(TAG, @"re-align cards with vertical gap = %f", verticalGap);
    
    for (CardImageView *view in cards)
    {
        [view setFrame:CGRectMake(start_x,
                                  start_y - view.row * verticalGap,
                                  card_width,
                                  card_height)];
        [mGameBoardView addSubview:view];
    }
    
}

- (void) realignCardsToNormalGap:(NSMutableArray<CardImageView *> *) cards
{
    LOG_UI(TAG, @"re-align cards to normal cap");
    int start_x = cards[0].frame.origin.x;
    int start_y = game_board_height - card_height;
    for (CardImageView *view in cards)
    {
        [view setFrame:CGRectMake(start_x,
                                  start_y - view.row * card_vertical_overlap_gap,
                                  card_width,
                                  card_height)];
    }
}

- (void) removeAllCardViews
{
    for (NSMutableArray <CardImageView *> *arr in mCardViewArr)
    {
        for (CardImageView *view in arr)
        {
            [view removeFromSuperview];
        }
    }
}

- (CardImageView *) getCardView:(enum card_view_type) type
                          index:(int) idx
{
    switch (type) {
        case FREE_CELL_VIEW:
            switch (idx) {
                case 0:
                    return mFreeCell0;
                case 1:
                    return mFreeCell1;
                case 2:
                    return mFreeCell2;
                case 3:
                    return mFreeCell3;
                default:
                    return nil;
            }
        case ORDERED_VIEW:
            switch (idx) {
                case 0:
                    return mOrderedDeck0;
                case 1:
                    return mOrderedDeck1;
                case 2:
                    return mOrderedDeck2;
                case 3:
                    return mOrderedDeck3;
                default:
                    return nil;
            }
        default:
            return nil;
    }
}

@end
