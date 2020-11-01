//
//  Card.m
//  FreeCellsV2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import "Card.h"

#define TAG "Card"

@interface Card()
{
    enum card_suit suit;
    enum card_color color;
    int value;
    BOOL isSelected;
    struct Coord coordInBoard;
    
    CardImageView *mCardView;

    id<GameDelegate> mCardDelegate;
}
@end
@implementation Card

- (instancetype) initWithValue:(int) value
                          suit:(enum card_suit) suit
{
    self = [super init];
    if (self)
    {
        self->suit = suit;
        self->value = value;
        self->isSelected = NO;
        
        self->color = [utils GetCardColor:self->suit];
        
        self->coordInBoard.column = -1;
        self->coordInBoard.row = -1;
        
        mCardView = [CardImageView imageViewWithImage:[NSImage imageNamed:[self getCardImageString]]];
        [mCardView setImageScaling:NSImageScaleAxesIndependently];
        [mCardView setFrameSize:CGSizeMake(card_width, card_height)];
    }
    return self;
}

- (instancetype) initEmptyCard
{
    self = [super init];
    if (self)
    {
        self->suit = -1;
        self->value = -1;
        self->isSelected = NO;
        self->color = [utils GetCardColor:self->suit];
        
        self->coordInBoard.column = -1;
        self->coordInBoard.row = -1;
    }
    return self;
}

- (enum card_suit) getSuit
{
    return self->suit;
}

- (int) getValue
{
    return self->value;
}

-(enum card_color) getCardColor
{
    return self->color;
}

- (NSString *) toString
{
    NSString *value = [self getValueString:self->value];
    NSString *suit = [self getSuitString:self->suit];
    return [NSString stringWithFormat:@"%@ of %@", suit, value];
}

- (NSString *) getValueString:(int) value
{
    if (value > 1 && value < 11)
    {
        return [NSString stringWithFormat:@"%d", value];
    }
    else if (value == 1)
    {
        return @"Ace";
    }
    else if (value == 11)
    {
        return @"Jack";
    }
    else if (value == 12)
    {
        return @"Queen";
    }
    else if (value == 13)
    {
        return @"King";
    }
    return @"";
}

-(NSString *) getSuitString:(enum card_suit) suit
{
    switch (suit) {
        case SUIT_DIOMAND:
            return @"Diamond";
        case SUIT_HEART:
            return @"Heart";
        case SUIT_CLUB:
            return @"Club";
        case SUIT_SPADE:
            return @"Spade";
        default:
            return @"";
    }
}

- (NSString *)getCardImageString
{
    return self->value == -1 ? @"cardCell" : !self->isSelected ? [NSString stringWithFormat:@"card_%d_%d", self->value, self->suit] : [NSString stringWithFormat:@"card_%d_%d_highlight", self->value, self->suit];
}

- (void) select {
    self->isSelected = !self->isSelected;
    [mCardView setImage:[NSImage imageNamed:[self getCardImageString]]];
}

- (BOOL)isSelected
{
    return self->isSelected;
}

- (BOOL)isEqual:(Card *)otherCard
{
    return self->suit == [otherCard getSuit] && self->value == [otherCard getValue];
}

- (BOOL)isEmptyCard
{
    return self->value == -1;
}

- (void) makeEmptyCard
{
    self->value = self->suit = -1;
    self->color = [utils GetCardColor:self->suit];
    
    isSelected = NO;
    
    [mCardView setImage:[NSImage imageNamed:[self getCardImageString]]];
}

- (void) makeCardToOther:(Card *)card
{
    self->suit = [card getSuit];
    self->value = [card getValue];
    self->color = [utils GetCardColor:self->suit];
    
    self->isSelected = NO;
}

- (void)setColumn:(int)clm row:(int)row
{
    self->coordInBoard.column = clm;
    self->mCardView.column = clm;
    self->coordInBoard.row = row;
    self->mCardView.row = row;
}

- (struct Coord)getCoordInBoard
{
    return self->coordInBoard;
}

- (CardImageView *) getCardView
{
    return mCardView;
}

- (void)updateCardPositionWithColumnSize:(NSInteger)size
{
    [self->mCardView updateView:[utils GetOverlapSizeWithColumnSize:size] imageStr:nil];
}

- (void) placeCardToGameBoard:(NSView *)gameboard superView:(NSView *) view gameDelegate:(id<GameDelegate>) delegate
{
    [gameboard addSubview:self->mCardView];
    self->mCardDelegate = delegate;
    self->mCardView.accessibilityParent = gameboard;
    [self->mCardView setSuperView:view];
    self->mCardView.target = self;
    self->mCardView.action = @selector(onCardClicked:);
    self->mCardView.rightMouseUpAction = @selector(onCardRightClickedUp:);
    self->mCardView.rightMouseDownAction = @selector(onCardRightClickedDown:);
    self->mCardView.isCardViewOnGameBoard = YES;
    [self->mCardView updateView:card_vertical_overlap_gap imageStr:[self getCardImageString]];
}

- (void) placeCardToFreeCell:(int)index
{
    LOG_UI(TAG, @"frame = {(%f, %f) (%f %f)}", free_cell_x[index], free_cell_y, free_cell_width, free_cell_height);
    CGRect rect = CGRectMake(free_cell_x[index], free_cell_y, free_cell_width, free_cell_height);
    [self->mCardView updateViewFrame:rect];
}

- (void) moveOutFromGameboard
{
    [self->mCardView removeFromSuperview];
}

- (void) onCardClicked:(CardImageView *) cardView
{
    [self->mCardDelegate onCardClicked:cardView];
}

- (void) onCardRightClickedUp:(CardImageView *) cardView
{
    [self->mCardDelegate onCardRightClickedUp:cardView nextCardView:[_nextCardInColumn getCardView]];
}

- (void) onCardRightClickedDown:(CardImageView *) cardView
{
    [self->mCardDelegate onCardRightClickedDown:cardView];
}
@end
