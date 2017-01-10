//
//  UIView+Extras.m
//  drawOnTrace
//
//  Created by Michael Roebuck on 1/10/17.
//  Copyright © 2017 Michael Roebuck. All rights reserved.
//

#import "UIView+Extras.h"

@implementation UIView (Extras)

- (void) layerText:(NSString *)str
              size:(CGSize)size
              font:(UIFont *)font
           degrees:(CGFloat)degrees
            points:(NSArray *)points {
    
    [self.layer removeAllAnimations];
    
    while(self.layer.sublayers.count > 0) {
        CALayer * layer = self.layer.sublayers.lastObject;
        [layer removeFromSuperlayer];
    }
    
    CGPoint lastPt = CGPointZero;
    
    for(NSInteger i = 0; i < str.length; i++) {
        
        unichar c = [str characterAtIndex:i];
        NSString * nextString = [NSString stringWithFormat:@"%c", c];
        
        NSValue * nextValue = points[i];
        CGPoint pt = [nextValue CGPointValue];
        
        CGFloat x = pt.x;
        CGFloat y = pt.y;
        CGFloat radiansToRotate = 0;
        
        CGSize textSize = [nextString sizeWithAttributes:@{NSFontAttributeName : font}];
        
        //Find the angle between two points
        if(!CGPointEqualToPoint(pt, CGPointZero)) {
            CGPoint H = CGPointMake(pt.x, lastPt.y);
            CGFloat a = sqrt(pow((H.x - lastPt.x), 2) + pow((H.y - lastPt.y), 2));
            CGFloat b = sqrt(pow((H.x - pt.x), 2) + pow((H.y - pt.y), 2));
            CGFloat c = sqrt(pow((pt.x - lastPt.x), 2) + pow((pt.y - lastPt.y), 2));
            
            //law of cosines
            CGFloat A = acos((pow(b, 2) + pow(c, 2) - pow(a, 2)) / (2 * b * c));
            CGFloat B = acos((pow(c, 2) + pow(a, 2) - pow(b, 2)) / (2 * c * a));
            CGFloat C = acos((pow(a, 2) + pow(b, 2) - pow(c, 2)) / (2 * a * b));
            
            radiansToRotate = B;
            
            NSLog(@"%s: a=[%3.2f] b=[%3.2f] c=[%3.2f]  A=[%3.2f] B=[%3.2f] C=[%3.2f]", __PRETTY_FUNCTION__, a, b, c, A, B, C);
        }
        
        CATextLayer *textLayer = [CATextLayer layer];
        // set the string
        textLayer.string = nextString;
        textLayer.backgroundColor = [UIColor clearColor].CGColor;
        textLayer.foregroundColor = [UIColor blackColor].CGColor;
        textLayer.frame = CGRectMake(x, y, textSize.width, textSize.height);
        textLayer.transform = CATransform3DMakeRotation((pt.x > size.width * 0.5 ? radiansToRotate : -radiansToRotate), 0, 0, 1.0);
        [self.layer addSublayer:textLayer];
        
        lastPt = CGPointMake(x, y);
    }
}

- (void) layerTextOnLine:(NSString *)str
                    size:(CGSize)size
                    font:(UIFont *)font
                 degrees:(CGFloat)degrees
              textPoints:(NSArray *)textPoints
            bezierPoints:(NSArray *)bezierPoints {
    
    printf("\n\n");
    
    [self.layer removeAllAnimations];
    
    while(self.layer.sublayers.count > 0) {
        CALayer * layer = self.layer.sublayers.lastObject;
        [layer removeFromSuperlayer];
    }
    
    CAShapeLayer * shapeLayer = [CAShapeLayer new];
    shapeLayer.frame = CGRectMake(0, 0, size.width, size.height);
    shapeLayer.lineWidth = 2.0;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    
    UIBezierPath * bezierPath = [UIBezierPath new];
    __block CGPoint lastPt = CGPointZero;
    
    [bezierPoints enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //Draw the line
        NSValue * nextValue = obj;
        CGPoint pt = [nextValue CGPointValue];
        NSInteger indexOfPoint = [textPoints indexOfObject:nextValue];
        
        printf("\t index found=[%ld]\n", indexOfPoint);
        
        //If we get inside of this scope, we've found where to draw the next letter
        if(indexOfPoint > -1 && indexOfPoint < textPoints.count) {
            unichar c = [str characterAtIndex:indexOfPoint];
            NSString * nextString = [NSString stringWithFormat:@"%c", c];
            
            CGFloat x = pt.x;
            CGFloat y = pt.y;
            CGFloat radiansToRotate = 0;
            
            CGSize textSize = [nextString sizeWithAttributes:@{NSFontAttributeName : font}];
            
            //Find the angle between two points
            if(!CGPointEqualToPoint(pt, CGPointZero)) {
                CGPoint H = CGPointMake(pt.x, lastPt.y);
                CGFloat a = sqrt(pow((H.x - lastPt.x), 2) + pow((H.y - lastPt.y), 2));
                CGFloat b = sqrt(pow((H.x - pt.x), 2) + pow((H.y - pt.y), 2));
                CGFloat c = sqrt(pow((pt.x - lastPt.x), 2) + pow((pt.y - lastPt.y), 2));
                
                //law of cosines
                CGFloat A = acos((pow(b, 2) + pow(c, 2) - pow(a, 2)) / (2 * b * c));
                CGFloat B = acos((pow(c, 2) + pow(a, 2) - pow(b, 2)) / (2 * c * a));
                CGFloat C = acos((pow(a, 2) + pow(b, 2) - pow(c, 2)) / (2 * a * b));
                
                radiansToRotate = B;
                
                NSLog(@"next: a=[%3.2f]\tb=[%3.2f]\tc=[%3.2f]\tA=[%3.2f]\tB=[%3.2f]\tC=[%3.2f]\trotation=[%3.2f]", a, b, c, A, B, C, radiansToRotate);
            }
            
            //Draw the text
            CATextLayer *textLayer = [CATextLayer layer];
            textLayer.string = nextString;
            textLayer.backgroundColor = [UIColor clearColor].CGColor;
            textLayer.foregroundColor = [UIColor blackColor].CGColor;
            textLayer.frame = CGRectMake(x, y, textSize.width, textSize.height);
            textLayer.transform = CATransform3DMakeRotation((pt.x > size.width * 0.5 ? radiansToRotate : -radiansToRotate), 0, 0, 1.0);
            [self.layer addSublayer:textLayer];
            
            lastPt = CGPointMake(x, y);
        }
        
        if(idx == 0) {
            [bezierPath moveToPoint:pt];
        }
        else {
            [bezierPath addLineToPoint:pt];
        }
    }];
    
    shapeLayer.path = bezierPath.CGPath;
    [self.layer addSublayer:shapeLayer];
}

@end
