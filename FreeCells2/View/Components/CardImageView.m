//
//  CardImageView.m
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/10/2.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import "CardImageView.h"

@implementation CardImageView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


- (void) mouseDown:(NSEvent *)theEvent
{
    [NSApp sendAction:[self action] to:[self target] from:self];
}

@end
