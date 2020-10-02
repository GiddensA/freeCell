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

+ (void) ShowAlert:(enum alert_type) type
{
    NSString *message;
    NSString *info;
    NSString *buttonTitle;
    NSString *iconName;
    
    switch (type) {
        case ILLEGAL_MOVE:
            message = @"Illegal Move!";
            info = @"You cannot place card(s) here!";
            buttonTitle = @"Got you";
            iconName = @"icon";
            break;
            
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:message];
    [alert setInformativeText:info];
    [alert addButtonWithTitle:buttonTitle];
    [alert setIcon:[NSImage imageNamed:iconName]];
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:nil];
}
@end
