//
//  ViewController.m
//  drawOnTrace
//
//  Created by Michael Roebuck on 9/7/16.
//  Copyright © 2016 Michael Roebuck. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, copy) NSString * text;
@property (strong, nonatomic) UIFont * font;
@property (strong, nonatomic) NSMutableArray * mutableArray;
@property (weak, nonatomic) IBOutlet UIView *layerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.mutableArray = @[].mutableCopy;
    
    self.text = self.textField.text;
    
    self.font = [UIFont fontWithName:@"Helvetica"  size:32];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    self.mutableArray = @[].mutableCopy;
    
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint pt = [touch locationInView:self.view];

    if(CGRectContainsPoint(self.imageView.frame, pt)) {
        CGPoint converted = [self.view convertPoint:pt toView:self.imageView];
        [self.mutableArray addObject:[NSValue valueWithCGPoint:converted]];
        
        NSLog(@"%s: new pt=(%3.2f, %3.2f) converted=(%3.2f, %3.2f)", __PRETTY_FUNCTION__, pt.x, pt.y,
              converted.x, converted.y);
    }
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self drawText:self.text];
}

- (UIImage *) drawText:(NSString *)str
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

- (void) layerText:(NSString *)str
                  size:(CGSize)size
                  font:(UIFont *)font
               degrees:(CGFloat)degrees
                points:(NSArray *)points {
    
    [self.layerView.layer removeAllAnimations];
    
    while(self.layerView.layer.sublayers.count > 0) {
        CALayer * layer = self.layerView.layer.sublayers.lastObject;
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
        [self.layerView.layer addSublayer:textLayer];
        
        lastPt = CGPointMake(x, y);
    }
}

- (CGFloat) deg2Rad:(CGFloat)degrees {
    return degrees * M_PI / 180;
}

- (CGFloat) rad2Deg:(CGFloat)degrees {
    return 180 / M_PI * degrees;
}

- (CGFloat) circleRadiusWithSize:(CGSize)size {
    return (size.height * 0.5f) + (pow(size.width, 2) / (8 * size.height));
}

- (CGFloat) ellipseRadiusWithSize:(CGSize)size angle:(CGFloat)angle {
    CGFloat top = size.width * size.height;
    CGFloat cosine = pow(size.height * cos(angle), 2);
    CGFloat sine = pow(size.width * sin(angle), 2);
    CGFloat bottom = sqrt(cosine + sine);
    CGFloat r = top / bottom;
    
    return r;
}

#pragma mark - UITextFieldDelegate Protocol

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Event Actions

- (IBAction)onTextChanged:(id)sender {
    
    UITextField * textField = sender;
    self.text = textField.text;
    [self drawText:self.text];
}

- (void) drawText:(NSString *)text {
    
    NSMutableArray * mutableArray = @[].mutableCopy;
    
    if(self.text.length < self.mutableArray.count) {
        
        NSString * textWithPadding = [NSString stringWithFormat:@" %@ ", text];
        
        for(NSInteger i = 0; i < textWithPadding.length; i++) {
            CGFloat percent = ((CGFloat)i/(CGFloat)textWithPadding.length);
            NSInteger index = (NSInteger)(percent * (CGFloat)self.mutableArray.count);
            [mutableArray addObject:self.mutableArray[index]];
            
            NSValue * nextValue = self.mutableArray[index];
            CGPoint pt = [nextValue CGPointValue];
            NSLog(@"%s: total=[%ld] percent=[%3.2f] index=[%ld] pt=(%3.2f, %3.2f)", __PRETTY_FUNCTION__, self.mutableArray.count, percent, index, pt.x, pt.y);
        }
        
        [self layerText:textWithPadding
                   size:self.imageView.frame.size
                   font:self.font
                degrees:0
                 points:mutableArray];
        
//        UIImage * image = [self drawText:self.text
//                                    size:self.imageView.frame.size
//                                    font:self.font
//                                 degrees:0
//                                  points:mutableArray];
//        
//        self.imageView.image = image;
//        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

@end
