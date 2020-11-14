//
//  constants.h
//  FreeCellsV2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#ifndef constants_h
#define constants_h

#define CHECK

static const CGFloat window_width = 1200.f;
static const CGFloat window_height = 700.f;

static const int num_of_decks = 1;
static const int num_of_cards_per_suit = 13;
static const int num_of_suits = 4;
static const int num_of_free_cells = 4;
static const int num_of_ordered_cells = 4;
static const int num_of_cards_per_deck = num_of_cards_per_suit * num_of_suits;
static const int num_of_game_board_columns = 8;
static const int max_length_card_string = 20;
const static int max_num_of_cards_per_column = 7;
const static int max_fixd_card_per_column = 8;
const static int free_cell_row_index = -1;
const static int ordered_cell_row_index = -2;
const static int selected_pos_default_val = -100;

const static NSInteger move_a_card_code = 1001;
const static NSInteger move_a_column_code = 1000;

const static CGFloat top_cell_area_height = 218; //do not change this unless storyboard is changed.

const static CGFloat gap_between_top_cell = 4.0f;
const static CGFloat top_cell_bound_diff = 4.0f;

const static CGFloat indicatitor_size = 48.0f;
const static CGFloat game_board_width = 1010.f;
const static CGFloat game_board_height = 452.0f;
const static CGFloat card_horizontal_margin = 20.0f;
const static CGFloat card_vertical_overlap_gap = 35;
const static CGFloat card_size_ratio = 0.7f;
const static CGFloat card_image_width = 165.0f;
const static CGFloat card_image_height = 250.0f;
const static CGFloat card_width = card_image_width * card_size_ratio;
const static CGFloat card_height = card_image_height * card_size_ratio;
const static CGFloat choicePickerViewWidth = 330.0f;
const static CGFloat choicePickerViewHeight = 150.0f;
const static CGFloat gap_between_cards = (game_board_width - (card_width * num_of_game_board_columns)) * 1.0f / ((num_of_game_board_columns - 1) * 1.0f);

const static CGFloat free_cell_y = 512.0f;
const static CGFloat free_cell_x[4] = {42.0f, 164.0f, 286.0f, 408.0f};
const static CGFloat free_cell_width = 111.0f;
const static CGFloat free_cell_height = 166.0f;

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

enum alert_type {
    ILLEGAL_MOVE,
    MOVE_CARD,
};

struct Coord
{
    int row;
    int column;
};

#endif /* constants_h */
