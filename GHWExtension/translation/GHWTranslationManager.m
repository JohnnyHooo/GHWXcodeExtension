//
//  GHWTranslationManager.m
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/9/15.
//  Copyright © 2019 Jingyao. All rights reserved.
//

#import "GHWTranslationManager.h"
#import "GHWExtensionConst.h"
#import "FYIServiceManager.h"
#import "NSString+FYIHumpString.h"

@implementation GHWTranslationManager

+ (GHWTranslationManager *)sharedInstane {
    static dispatch_once_t predicate;
    static GHWTranslationManager * sharedInstane;
    dispatch_once(&predicate, ^{
        sharedInstane = [[GHWTranslationManager alloc] init];
    });
    return sharedInstane;
}

- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
    if (![invocation.buffer.selections count]) {
        return;
    }
    
    XCSourceTextRange *selectRange = invocation.buffer.selections[0];
    NSInteger startLine = selectRange.start.line;
    NSInteger endLine = selectRange.end.line;
    NSInteger startColumn = selectRange.start.column;
    NSInteger endColumn = selectRange.end.column;
    
    if (startLine != endLine || startColumn == endColumn) {
        return;
    }
    
    NSString *selectLineStr = invocation.buffer.lines[startLine];
    NSString *selectContentStr = [[selectLineStr substringWithRange:NSMakeRange(startColumn, endColumn - startColumn)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];


//    invocation.buffer.lines[startLine] = [selectContentStr stringByReplacingCharactersInRange:NSMakeRange(startColumn, endColumn - startColumn) withString:[NSString stringWithFormat:@"结果"]];
    NSLog(@"---> %@",@"开始翻译了");

    __block NSString *outStr = @"";
    [FYIServiceManager requestDataWithTextString:selectContentStr data:^(id response) {
        outStr = [response firstObject];
        if (!outStr.length) {
            outStr = @"翻译错误";
        }
        outStr = [NSString commonStringToHumpString:outStr];
//        invocation.buffer.lines[startLine] = [invocation.buffer.lines[startLine] stringByReplacingCharactersInRange:NSMakeRange(startColumn, endColumn - startColumn) withString:outStr];
        [self changeTextWithRange:NSMakeRange(startColumn, endColumn - startColumn) withString:outStr invocation:invocation startLine:startLine];
    }];
  
    
}

- (void)changeTextWithRange:(NSRange)range withString:(NSString *)replacement invocation:(XCSourceEditorCommandInvocation *)invocation startLine:(NSInteger)startLine
{
    invocation.buffer.lines[startLine] = [invocation.buffer.lines[startLine] stringByReplacingCharactersInRange:range withString:replacement];

}


@end
