//
//  QMTableRowView.m
//  QMCleaner
//

//  Copyright (c) 2013年 Tencent. All rights reserved.
//

#import "QMResultTableRowView.h"
#import <QuartzCore/QuartzCore.h>
#import "BigCleanParaentCellView.h"
#import "CategoryCellView.h"
#import "SubCategoryCellView.h"
#import <Masonry/Masonry.h>
#import <QMUICommon/LMAppThemeHelper.h>

@implementation QMResultTableRowView

- (id)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        m_selectedColor = [LMAppThemeHelper getTableViewRowSelectedColor];
    }
    return self;
}

- (void)addSubview:(NSView *)aView;
{
    [super addSubview:aView];
    if ([aView isKindOfClass:[CategoryCellView class]] ||[aView isKindOfClass:[SubCategoryCellView class]])
    {
        BigCleanParaentCellView * tableCell = (BigCleanParaentCellView *)aView;
        
        // 使用masonry。直接设置frame，滚动的时候会闪sizeLabel，理论上应该是兼容11
        float left = tableCell.frame.origin.x;
        float width = self.frame.size.width - left;
        float height = tableCell.frame.size.height;
        if (@available(macOS 12.0, *)) {
            [tableCell mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(left);
                make.width.mas_equalTo(width);
                make.height.mas_equalTo(height);
                make.centerY.equalTo(self);
            }];
        } else {
            [tableCell setFrameSize:NSMakeSize(width, height)];
        }
    }
    if ([aView isKindOfClass:[NSButton class]])
    {
        NSImage * _triangleImage = [NSImage imageNamed:@"triangleButton"];
        NSImage * _triangleAlternateImage = [NSImage imageNamed:@"triangleButtonSelected"];
        [(NSButton*)aView setImage:_triangleImage];
        [(NSButton*)aView setAlternateImage:_triangleAlternateImage];
        if (@available(macOS 12.0, *)) {
            [aView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(13);
                make.height.mas_equalTo(30);
                make.right.equalTo(self.mas_right).offset(-70);
                make.centerY.equalTo(self);
            }];
        } else {
            [aView setFrameOrigin:NSMakePoint(919, aView.frame.origin.y)];
        }
        //        NSLog(@"width position = %f", self.frame.size.width - aView.frame.size.width - 62);
    }
    [self moveExpandButtonToFront];
}

// 当 outlineView reloadItem 时, 会触发 outlineView viewForTableColumn 重新调用,并重新调用 tableView 的 addSubView 方法. 这时会触发 expand button 位于 cellView 后面的问题.
// 如果不移动 expand button 没事(cell view 和 expand view 没有重合) 但移动 expand button 后就会有button 被遮挡的问题. 造成 button 无法响应事件.
// rowViw 可能会重新添加 cellView, 这时需要将 expand Button 置于最前面.

- (void)moveExpandButtonToFront {
    [self sortSubviewsUsingFunction:(NSComparisonResult (*)(id, id, void *)) compareViews context:nil];
}

NSComparisonResult compareViews(id firstView, id secondView, void *context) {
    
    if ([firstView isKindOfClass:NSButton.class]) {
        return NSOrderedDescending;
    } else {
        return NSOrderedAscending;
    }
}

-(void)didAddSubview:(NSView *)subview
{
    [super didAddSubview:subview];
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
    NSBezierPath* path = [NSBezierPath bezierPathWithRect:self.bounds];
    [[LMAppThemeHelper getMainBgColor] set];
    [path fill];
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    NSBezierPath * path = [NSBezierPath bezierPathWithRect:self.bounds];
    [m_selectedColor set];
    [path fill];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if ([[self subviews] count] > 0)
    {
        BigCleanParaentCellView * cellView =  [self viewAtColumn:0];
        [cellView setHightLightStyle:selected];
    }
}



@end
