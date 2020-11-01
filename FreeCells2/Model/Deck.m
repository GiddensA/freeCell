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
    NSMutableArray<NSNumber *> *index;
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
    if (self->index.count == 0) return nil;
    int idx = isShuffled ? [utils GetRandomIntFrom:0 to:(int) self->index.count - 1] : 0;
    Card *card = self->deck[[self->index[idx] intValue]];
//    LOG_MODOLE(TAG, @"deal card at current index %d, with deck size = %ld, card %@", idx, self->index.count, [card toString]);
    [self->index removeObjectAtIndex:idx];
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
    if (deck == nil)
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
    }
    self->index = [NSMutableArray array];
    for (int i = 0; i < num_of_cards_per_deck; i++)
    {
        [self->index addObject:[NSNumber numberWithInt:i]];
        [self->deck[i] resetCard];
    }
    self->isShuffled = NO;
}


@end
