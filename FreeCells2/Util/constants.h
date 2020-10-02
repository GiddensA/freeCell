//
//  constants.h
//  FreeCellsV2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#ifndef constants_h
#define constants_h

static const int num_of_decks = 1;
static const int num_of_cards_per_suit = 13;
static const int num_of_suits = 4;
static const int num_of_cards_per_deck = num_of_cards_per_suit * num_of_suits;
static const int num_of_game_board_columns = 8;
static const int max_length_card_string = 20;

enum card_suit {
    SUIT_SPADE,
    SUIT_HEART,
    SUIT_CLUB,
    SUIT_DIOMAND,
    SUIT_MAX,
};

enum card_color {
    CARD_COLOR_RED,
    CARD_COLOR_BLACK,
    CARD_COLOR_MAX,
};

#endif /* constants_h */
