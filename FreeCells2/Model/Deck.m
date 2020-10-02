//
//  Deck.m
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import "Deck.h"

#define TAG "Deck"

@interface Deck()
{
    NSMutableArray<Card *> *deck;
    BOOL isShuffled;
}
@end
@implementation Deck

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        [self resetDeck];
    }
    return self;
}

- (void) shuffle
{
    self->isShuffled = YES;
}

- (Card *)dealCard
{
    if (self->deck.count == 0) return nil;
    int index = isShuffled ? [utils GetRandomIntFrom:0 to:(int) self->deck.count - 1] : 0;
    Card *card = self->deck[index];
    LOG_MODOLE(TAG, @"deal card at current index %d, with deck size = %ld, card %@", index, self->deck.count, [card toString]);
    [self->deck removeObjectAtIndex:index];
    return card;
}

- (void) printDeck
{
    for (Card *card in self->deck)
    {
        NSLog(@"%@", [card toString]);
    }
}

- (void) resetDeck
{
    self->deck = [NSMutableArray array];
    int suit = 0;
    for (int i = 0; i < num_of_cards_per_deck; i++)
    {
        int value = i % num_of_cards_per_suit + 1;
        [self->deck addObject:[[Card alloc] initWithValue:value suit: suit]];
        if (value == num_of_cards_per_suit)
        {
            suit ++;
        }
    }
    self->isShuffled = NO;
}


@end
