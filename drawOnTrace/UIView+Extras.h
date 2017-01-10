//
//  UIView+Extras.h
//  drawOnTrace
//
//  Created by Michael Roebuck on 1/10/17.
//  Copyright © 2017 Michael Roebuck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extras)

- (void) layerText:(NSString *)str
              size:(CGSize)size
              font:(UIFont *)font
           degrees:(CGFloat)degrees
            points:(NSArray *)points;

- (void) layerTextOnLine:(NSString *)str
                    size:(CGSize)size
                    font:(UIFont *)font
                 degrees:(CGFloat)degrees
              textPoints:(NSArray *)textPoints
            bezierPoints:(NSArray *)bezierPoints;

@end
