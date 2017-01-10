//
//  UIImage+TextDrawing.m
//  drawOnTrace
//
//  Created by Michael Roebuck on 1/10/17.
//  Copyright © 2017 Michael Roebuck. All rights reserved.
//

#import "UIImage+TextDrawing.h"

@implementation UIImage (TextDrawing)

+ (UIImage *) drawTextOnCurve:(NSString *)str
                  size:(CGSize)size
                  font:(UIFont *)font
               degrees:(CGFloat)degrees
                points:(NSArray *)points {
    //get the context for coreGraphics
    UIGraphicsBeginImageContext( size );
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    [[UIColor blackColor] setFill];
    
    for(NSInteger i = 0; i < str.length; i++) {
        
        unichar c = [str characterAtIndex:i];
        NSString * nextString = [NSString stringWithFormat:@"%c", c];
        
        NSValue * nextValue = points[i];
        CGPoint pt = [nextValue CGPointValue];
        
        CGFloat radians = [self deg2Rad:degrees];
        
        CGFloat radius = [self ellipseRadiusWithSize:size angle:radians];
        CGFloat x = (pt.x * 0.15) /*+ radius * cos(radians)*/;
        CGFloat y = (pt.y * 0.15) /*+ radius * sin(radians)*/;
        
        NSLog(@"Letter=[%@] pt=(%3.2f, %3.2f) size=(%3.2f, %3.2f) degrees=%3.2f radians=%3.2f radius=%3.2f extraSize=(%3.2f, %3.2f)",
              nextString,
              pt.x, pt.y,
              size.width, size.height, degrees, radians, radius, x, y);
        
        CGAffineTransform r = CGAffineTransformMakeRotation(radians);
        CGAffineTransform t = CGAffineTransformMakeTranslation(x, y);
        
        CGContextConcatCTM(ctx, t);
        CGContextConcatCTM(ctx, r);
        
        [nextString drawAtPoint:pt withAttributes:@{NSFontAttributeName:font}];
        
        CGContextConcatCTM(ctx, CGAffineTransformInvert(r));
        CGContextConcatCTM(ctx, CGAffineTransformInvert(t));
    }
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    return img;
}

+ (CGFloat) deg2Rad:(CGFloat)degrees {
    return degrees * M_PI / 180;
}

+ (CGFloat) rad2Deg:(CGFloat)degrees {
    return 180 / M_PI * degrees;
}

+ (CGFloat) ellipseRadiusWithSize:(CGSize)size angle:(CGFloat)angle {
    CGFloat top = size.width * size.height;
    CGFloat cosine = pow(size.height * cos(angle), 2);
    CGFloat sine = pow(size.width * sin(angle), 2);
    CGFloat bottom = sqrt(cosine + sine);
    CGFloat r = top / bottom;
    
    return r;
}

@end
