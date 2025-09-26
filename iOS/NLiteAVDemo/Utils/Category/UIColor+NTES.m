// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "UIColor+NTES.h"

@implementation UIColor (NTES)

+ (UIColor *)colorWithHexString:(NSString *)hexString {
  NSString *cString =
      [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
          uppercaseString];

  // String should be 6 or 8 characters
  if ([cString length] < 6) {
    return [UIColor clearColor];
  }

  // strip 0X if it appears
  if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
  if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
  if ([cString length] != 6) return [UIColor clearColor];

  // Separate into r, g, b substrings
  NSRange range;
  range.location = 0;
  range.length = 2;

  // r
  NSString *rString = [cString substringWithRange:range];

  // g
  range.location = 2;
  NSString *gString = [cString substringWithRange:range];

  // b
  range.location = 4;
  NSString *bString = [cString substringWithRange:range];

  // Scan values
  unsigned int r, g, b;
  [[NSScanner scannerWithString:rString] scanHexInt:&r];
  [[NSScanner scannerWithString:gString] scanHexInt:&g];
  [[NSScanner scannerWithString:bString] scanHexInt:&b];
  NSLog(@"%lf", (float)r);
  NSLog(@"%lf", (float)g);
  NSLog(@"%lf", (float)b);
  return [UIColor colorWithRed:((float)r / 255.0f)
                         green:((float)g / 255.0f)
                          blue:((float)b / 255.0f)
                         alpha:1.0f];
}

@end
