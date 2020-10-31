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
#import "GameDelegate.h"


#define TAG "MainVC"

enum card_view_type
{
    FREE_CELL_VIEW,
    ORDERED_VIEW,
    EMPTY_CARD_VIEW,
    CARD_VIEW,
    TYPE_MAX,
};

@interface MainViewController()<GameDelegate>
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
    NSMutableArray<CardImageView *> *mFreeCells;
    NSMutableArray<CardImageView *> *mOrderedCells;
    
    
    
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
        mGame.mGameDelegate = self;
        mBoard = [NSMutableArray arrayWithArray:[mGame getGameBoard]];
        
        mCardViewArr = [NSMutableArray array];
        
    }
    return self;
}

- (void)viewDidLoad {
    [self.view addTrackingArea:mTrackingArea];
    mFreeCells = [NSMutableArray arrayWithObjects:mFreeCell0, mFreeCell1, mFreeCell2, mFreeCell3, nil];    
    mOrderedCells = [NSMutableArray arrayWithObjects:mOrderedDeck0, mOrderedDeck1, mOrderedDeck2, mOrderedDeck3, nil];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self layoutCards];
    
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

- (void) layoutCards
{

    /*NSArray <Card *> *freeCells = [mGame getFreeCells];
    NSArray <Card *> *orderedCells = [mGame getOrderedDeck];
    
    for (int i = 0; i < num_of_free_cells; i++)
    {
        mFreeCells[i].mCard = freeCells[i];
        mFreeCells[i].isCardViewOnGameBoard = NO;
        [mFreeCells[i] updateView:0];
    }
    
    for (int i = 0; i < num_of_suits; i++)
    {
        mOrderedCells[i].mCard = orderedCells[i];
        mOrderedCells[i].isCardViewOnGameBoard = NO;
        [mOrderedCells[i] updateView:0];
    }
    
    for(int i = 0; i < num_of_game_board_columns; i ++)
    {
        NSArray<NSArray <Card *> *> *board = [mGame getGameBoard];
        NSArray<Card *> *column = board[i];
        NSMutableArray<CardImageView *> *cardViewColumn = [NSMutableArray array];
        
        int row = 0;
        for (Card *card in column)
        {
            LOG_UI(TAG, @"clm %d %@", i, card);
            CardImageView *viewCard = [[CardImageView alloc] init];
            viewCard.mCard = card;
            viewCard.isCardViewOnGameBoard = YES;
            [viewCard updateView:card_vertical_overlap_gap];
            
            viewCard.canRightClick = YES;
            viewCard.target = self;
            viewCard.action = @selector(onCardClicked:);
            viewCard.rightMouseDownAction = @selector(onCardRightClickedDown:);
            viewCard.rightMouseUpAction = @selector(onCardRightClickedUp:);
            [mGameBoardView addSubview:viewCard];
            [cardViewColumn addObject:viewCard];
            row ++;
        }
        if (mCardViewArr != nil)
        {
            mCardViewArr[i] = cardViewColumn;
        } else {
            [mCardViewArr addObject:cardViewColumn];
        }
    }*/
    
    [mGame placeCardToGameBard:self->mGameBoardView superView:self.view];
}

- (IBAction)onIndicatorClicked:(NSButton *)sender {
    [self removeAllCardViews];
    
    [mGame resetGame];
    [self layoutCards];

}

- (IBAction)onFreeCellClicked:(CardImageView *)sender {
    int index = (int)sender.index;
    LOG_UI(TAG, @"clicked on free cell %d", index);
    [mGame selectCardAtRow:free_cell_row_index column:index];
}

- (IBAction)onOrderedDeckClicked:(CardImageView *)sender {
}

- (void) onCardClicked:(CardImageView *) card
{
    int row = (int)card.row;
    int column = (int)card.column;
    LOG_UI(TAG, @"clicked on card %d %d", row, column);
    
    [mGame selectCardAtRow:row column:column];
}

- (void) onCardRightClickedDown:(CardImageView *) card
{
    int row = (int)card.row;
    int column = (int)card.column;
    LOG_UI(TAG, @"right clicked down on card %d %d", row, column);
    
    [mGameBoardView addSubview:card];
    [card becomeFirstResponder];
   
}

- (void) onCardRightClickedUp:(CardImageView *) card nextCardView:(CardImageView *)nextCard
{
    int row = (int)card.row;
    int column = (int)card.column;
    LOG_UI(TAG, @"right clicked up on card %d %d next card %@", row, column, nextCard);
    
    if (nil != nextCard) {
        [card removeFromSuperview];
        [mGameBoardView addSubview:card positioned:NSWindowBelow relativeTo:nextCard];
        
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

- (void)updateGameBoardAtColumn:(int)clm row:(int)row columnSize:(int)size
{
    LOG_UI(TAG, @"update %d %d size %d",clm, row, size);
//    for (int i = row; i < size; i ++)
//    {
//        [mCardViewArr[clm][i] updateView:-1];
//    }
}

- (void)moveCardFromColumn:(int)fClm fromRow:(int)fRow columnSize:(int) size toColumn:(int)tClm toRow:(int)tRow
{
//    LOG_UI(TAG, @"move card from row %d column %d size %d to row %d column %d", fRow, fClm, size, tRow, tClm);
//    NSArray<CardImageView *> *from = [mCardViewArr[fClm] subarrayWithRange:NSMakeRange(fRow, size-fRow)];
//    LOG_UI(TAG, @"from size = %ld", from.count);
//    if (tRow > 0)
//    {
//        [mCardViewArr[tClm] addObjectsFromArray:from];
//    }
//    if (size > 1)
//    {
//        [mCardViewArr[fClm] removeObjectsInRange:NSMakeRange(fRow, size-fRow)];
//    }
//    
//    // calculate gap
//    int tSize = (int)mCardViewArr[tClm].count;
//    CGFloat verticalGap = card_vertical_overlap_gap;
//    if (tSize > max_fixd_card_per_column)
//    {
//        verticalGap = (game_board_height - card_width) / (tSize * 1.0f);
//    }
//    LOG_UI(TAG, @"vertical gap = %f", verticalGap);
//    for (CardImageView *view in mCardViewArr[tClm])
//    {
//        [view updateView:verticalGap];
//        [mGameBoardView addSubview:view];
//    }
//    
//    if (size == 1)
//    {
//        [from[0] updateView:verticalGap];
//    }
}

@end
