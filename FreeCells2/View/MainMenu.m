//
//  MainMenu.m
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/11/17.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import "MainMenu.h"
#import "AppDelegate.h"
#import "Game.h"

@implementation MainMenu

- (IBAction)onMenuNewGameClicked:(NSMenuItem *)sender {
    [((AppDelegate *)[NSApplication sharedApplication].delegate).mGame.mGameDelegate onGameReset];
}

- (IBAction)onMenuAutoFinishClicked:(NSMenuItem *)sender {
    [((AppDelegate *)[NSApplication sharedApplication].delegate).mGame autoFinish];
}

@end
