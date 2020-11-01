//
//  Card.h
//  FreeCellsV2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardImageView.h"
#import "GameDelegate.h"
#import "utils.h"

NS_ASSUME_NONNULL_BEGIN

@interface Card : NSObject
@property Card * nextCardInColumn;

- (instancetype) initWithValue:(int) value
                          suit:(enum card_suit) suit;

- (instancetype) initEmptyCard;

- (enum card_suit) getSuit;

- (enum card_color) getCardColor;

- (int) getValue;

- (NSString *) toString;

- (NSString *) getCardImageString;

- (void) makeEmptyCard;

- (void) makeCardToOther:(Card *) card;

- (void) select;

- (BOOL) isSelected;

- (BOOL) isEqual:(Card *)otherCard;

- (BOOL) isEmptyCard;

- (void) setColumn:(int) clm row:(int) row;

- (struct Coord) getCoordInBoard;

- (void) placeCardToGameBoard:(NSView *) gameboard superView:(NSView *) view gameDelegate:(id<GameDelegate>) delegate;

- (void) updateCardPositionWithColumnSize:(NSInteger) size;

- (void) placeCardToFreeCell:(int) index;

- (void) moveOutFromGameboard;

- (CardImageView *) getCardView;

- (void) resetCard;
@end

NS_ASSUME_NONNULL_END
