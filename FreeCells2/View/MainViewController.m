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
#import "Card.h"

#define TAG "MainVC"

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
        // move card
        return;
    } else {
        // select card(s)
        mBoard[column] = [mGame selectCardAtRow:row column:column];
        for (int i = row; i < mBoard[column].count; i++)
        {
            [mCardViewArr[column][i] setImage:[NSImage imageNamed:[mBoard[column][i] getCardImageString]]];
        }
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
@end
