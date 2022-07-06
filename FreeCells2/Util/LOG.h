//
//  LOG.h
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/10/1.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#ifndef LOG_h
#define LOG_h

#define LOG_LEVEL 0x7    // bit2  MODEL
                         // bit1  UI
                         // bit0  DELEGATE

#define LOG_MODEL_LEVEL       2
#define LOG_UI_LEVEL          1
#define LOG_DELEGATE_LEVEL    0

#define LOG_MODOLE(TAG, LOG, ...)                                                                               \
            if ((LOG_LEVEL & 1 << LOG_MODEL_LEVEL) >> LOG_MODEL_LEVEL == 1)                                     \
            {                                                                                                   \
                NSLog((@"[%s Line %d] [" TAG "] " LOG ), __FILE_NAME__, __LINE__, ##__VA_ARGS__);               \
            }

#define LOG_UI(TAG, LOG, ...)                                                                                   \
            if ((LOG_LEVEL & 1 << LOG_UI_LEVEL) >> LOG_UI_LEVEL == 1)                                           \
            {                                                                                                   \
                NSLog((@"[%s Line %d] [" TAG "] " LOG ), __FILE_NAME__, __LINE__, ##__VA_ARGS__);               \
            }

#define LOG_DELEGATE(TAG, LOG, ...)                                                                             \
            if ((LOG_LEVEL & 1 << LOG_DELEGATE_LEVEL) >> LOG_DELEGATE_LEVEL == 1)                               \
            {                                                                                                   \
                NSLog((@"[%s Line %d] [" TAG "] " LOG ), __FILE_NAME__, __LINE__, ##__VA_ARGS__);               \
            }
#endif /* LOG_h */
