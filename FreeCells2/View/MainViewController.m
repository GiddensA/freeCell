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
    CGFloat gap_between_cards = (game_board_width - (card_width * num_of_game_board_columns)) * 1.0f / ((num_of_game_board_columns - 1) * 1.0f);
    LOG_UI(TAG, @"gap between cards = %f", gap_between_cards);
    
    for (int i = 0; i < num_of_game_board_columns; i ++)
    {
        CardImageView *emptyCardView = [CardImageView imageViewWithImage:[NSImage imageNamed:@"cardCell"]];
        [emptyCardView setFrame:CGRectMake(0 + i * (card_width + gap_between_cards),
                                           game_board_height - card_height,
                                           card_width,
                                           card_height)];
        emptyCardView.index = i;
        [emptyCardView setTarget:self];
        [emptyCardView setAction:@selector(onEmptyCardClicked:)];
        
        [mGameBoardView addSubview:emptyCardView];
    }
}

- (IBAction)onIndicatorClicked:(NSButton *)sender {
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

@end
