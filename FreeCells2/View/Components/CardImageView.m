//
//  CardImageView.m
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/10/2.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import "CardImageView.h"
#import "LOG.h"
#import "constants.h"

#define TAG "CardImageView"

@interface CardImageView()
{
    NSView *superView;
}
@end

@implementation CardImageView


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void) mouseDown:(NSEvent *)theEvent
{
    [NSApp sendAction:[self action] to:[self target] from:self];
}

- (void) rightMouseUp:(NSEvent *)event
{
    [NSApp sendAction:[self rightMouseUpAction] to:[self target] from:self];
}

- (void)rightMouseDown:(NSEvent *)event
{
    [NSApp sendAction:[self rightMouseDownAction] to:[self target] from:self];
}

- (void)updateView:(CGFloat) verticalGap imageStr:(nullable NSString *) imgString
{
    if (nil != imgString)
    {
         [self setImage:[NSImage imageNamed:imgString]];
    }
    if (_isCardViewOnGameBoard)
    {
        if (verticalGap != -1)
        {
            [self setFrame:CGRectMake(self.column * (card_width + gap_between_cards),
                                      game_board_height - card_height - verticalGap * self.row,
                                      card_width,
                                      card_height)];
            [self.accessibilityParent addSubview:self];
        }
//         LOG_UI(TAG, @"card image %@ row %ld colum %ld", imgString, self.row, self.column);
    }
}

- (void) updateViewFrame:(CGRect)frame
{
    LOG_UI(TAG, @"test");
    [self setFrame:frame];
    [self removeFromSuperview];
    [self->superView addSubview:self];
}

- (void) setSuperView:(NSView *)view
{
    self->superView = view;
}

@end
