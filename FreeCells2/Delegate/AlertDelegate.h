//
//  AlertDelegate.h
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/11/14.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#ifndef AlertDelegate_h
#define AlertDelegate_h
@protocol AlertDelegate <NSObject>

- (void)alertDidEnd:(NSInteger)returnCode type:(enum alert_type) type;

@end
#endif /* AlertDelegate_h */
