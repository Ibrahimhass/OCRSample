//
//  CIContext+Workaround.m
//  LoveInASnap
//
//  Created by Md Ibrahim Hassan on 30/07/17.
//  Copyright © 2017 Lyndsey Scott. All rights reserved.
//

#import "CIContext+Workaround.h"

@implementation CIContext (Workaround)

+ (CIContext *)yourprefix_contextWithOptions:(NSDictionary<NSString *, id> *)options {
  return [CIContext contextWithOptions:options];
}

@end
