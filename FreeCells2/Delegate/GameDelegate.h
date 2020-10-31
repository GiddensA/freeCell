//
//  GameDelegate.h
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/10/8.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#ifndef GameDelegate_h
#define GameDelegate_h

@protocol GameDelegate <NSObject>

- (void) onCardClicked:(CardImageView *) card;

- (void) onCardRightClickedDown:(CardImageView *) card;

- (void) onCardRightClickedUp:(CardImageView *) card nextCardView:(CardImageView *)nextCard;
 
@end

#endif /* GameDelegate_h */
