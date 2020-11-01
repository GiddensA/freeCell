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
    CGFloat start_x = card_width + gap_between_cards;
    CGFloat start_y = game_board_height - card_height;
    for (int i = 0; i < num_of_game_board_columns; i++)
    {
        CardImageView *emptyCard = [CardImageView imageViewWithImage:[NSImage imageNamed:@"cardCell"]];
        [emptyCard setFrame:NSMakeRect(i * start_x, start_y, card_width, card_height)];
        [emptyCard setTarget:self];
        [emptyCard setAction:@selector(onEmptyCardClicked:)];
        emptyCard.index = i;
        
        [self->mGameBoardView addSubview:emptyCard];
    }
    
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
    [mGame placeCardToGameBard:self->mGameBoardView superView:self.view orderedCells:mOrderedCells];
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
    int index = (int)sender.index;
    LOG_UI(TAG, @"clicked on ordered cell %d", index);
    [mGame selectCardAtRow:ordered_cell_row_index column:index];
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

- (void) onEmptyCardClicked:(CardImageView *) sender
{
    int index = (int)sender.index;
    LOG_UI(TAG, @"clicked on empty card %d", index);
    [mGame selectCardAtRow:0 column:index];
}


@end
