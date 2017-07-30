//
//  CIContext+Workaround.h
//  LoveInASnap
//
//  Created by Md Ibrahim Hassan on 30/07/17.
//  Copyright © 2017 Lyndsey Scott. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface CIContext (Workaround)
+ (CIContext *)yourprefix_contextWithOptions:(NSDictionary<NSString *, id> *)options;

@end
