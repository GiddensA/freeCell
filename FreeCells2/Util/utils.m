//
//  utils.m
//  FreeCellsV2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import "utils.h"
#import <AppKit/AppKit.h>


@implementation utils
+ (enum card_color) GetCardColor:(enum card_suit) suit
{
    switch (suit) {
        case SUIT_SPADE:
        case SUIT_CLUB:
            return CARD_COLOR_BLACK;
        case SUIT_HEART:
        case SUIT_DIOMAND:
            return CARD_COLOR_RED;
        default:
            return CARD_COLOR_MAX;
    }
}

+ (int) GetRandomIntFrom:(int)from to:(int)to
{
     return (int)(from + arc4random() % (to-from+1));
}

+ (NSString *) GetSpaces:(NSString *)str
{
    int length = (int)str.length;
    int spaceCount = max_length_card_string - length;
    NSMutableString *space = [NSMutableString string];
    for (int i = 0; i < spaceCount; i ++)
    {
        [space appendString:@" "];
    }
    return [NSString stringWithFormat:@"%@%@", str, space];
}

+ (void) ShowAlert:(enum alert_type) type delegate:(nullable id<AlertDelegate>) delegate
{
    NSString *message;
    NSString *info;
    NSArray <NSString *> *btns;
    NSString *iconName;
    
    
    switch (type) {
        case ILLEGAL_MOVE:
            message = @"Illegal Move!";
            info = @"You cannot place card(s) here!";
            btns = [NSArray arrayWithObject: @"Got you"];
            iconName = @"icon";
            break;
        case MOVE_CARD:
            message = @"Move Cards:";
            info = @"Please choose the amount of cards to move!";
            btns = [NSArray arrayWithObjects:@"A column", @"A card", nil];
            iconName = @"icon";
            break;
        case GAME_WIN:
            message = @"Congratulations!";
            info = @"You win the game!";
            btns = [NSArray arrayWithObject:@"Cheer!"];
            iconName = @"icon";
            break;
        case GAME_LOST:
            message = @"Dead End!";
            info = @"You are in a dead End!";
            btns = [NSArray arrayWithObject:@"Re-start!"];
            iconName = @"icon";
            break;
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:message];
    [alert setInformativeText:info];
    for (NSString *title in btns)
    {
        [alert addButtonWithTitle:title];
    }
    [alert setIcon:[NSImage imageNamed:iconName]];
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow
                  completionHandler:^(NSModalResponse returnCode) {
        if (delegate != nil)
        {
            [delegate alertDidEnd:returnCode type:type];
        }
    }];
    
   
}

+ (CGFloat) GetOverlapSizeWithColumnSize:(NSInteger)size
{
    if (size <= max_fixd_card_per_column)
    {
        return card_vertical_overlap_gap;
    }
    return (game_board_height - card_height) / (size * 1.0f);
}
@end
