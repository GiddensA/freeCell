//
//  Card.m
//  FreeCellsV2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import "Card.h"


@interface Card()
{
    enum card_suit suit;
    enum card_color color;
    int value;
    BOOL isSelected;

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
    return !self->isSelected ? [NSString stringWithFormat:@"card_%d_%d", self->value, self->suit] : [NSString stringWithFormat:@"card_%d_%d_highlight", self->value, self->suit];
}

- (void) select {
    self->isSelected = !self->isSelected;
}

- (BOOL)isSelected
{
    return self->isSelected;
}

@end
