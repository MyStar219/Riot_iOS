/*
 Copyright 2015 OpenMarket Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MXKSearchTableViewCell.h"

#import "MXMediaManager.h"

#import "MXKSearchCellDataStoring.h"

@implementation MXKSearchTableViewCell

#pragma mark - Class methods

- (void)render:(MXKCellData *)cellData
{
    // Sanity check: accept only object of MXKRoomBubbleCellData classes or sub-classes
    NSParameterAssert([cellData conformsToProtocol:@protocol(MXKSearchCellDataStoring)]);
    
    id<MXKSearchCellDataStoring> searchCellData = (id<MXKSearchCellDataStoring>)cellData;
    if (searchCellData)
    {
        _title.text = searchCellData.title;
        _date.text = searchCellData.date;
        _message.text = searchCellData.message;
        
        if (_attachmentImageView)
        {
            _attachmentImageView.image = nil;
            self.attachmentImageView.defaultBackgroundColor = [UIColor clearColor];
            
            if (searchCellData.isAttachmentWithThumbnail)
            {
                // Set attached media folders
                self.attachmentImageView.mediaFolder = searchCellData.roomId;
                
                NSString *mimetype = nil;
                if (searchCellData.attachment.thumbnailInfo)
                {
                    mimetype = searchCellData.attachment.thumbnailInfo[@"mimetype"];
                }
                else if (searchCellData.attachment.contentInfo)
                {
                    mimetype = searchCellData.attachment.contentInfo[@"mimetype"];
                }
                
                NSString *url = searchCellData.attachment.thumbnailURL;
                
                UIImage *preview = searchCellData.attachment.previewImage;
                
                if (url.length || preview)
                {
                    self.attachmentImageView.enableInMemoryCache = YES;
                    [self.attachmentImageView setImageURL:url withType:mimetype andImageOrientation:searchCellData.attachment.thumbnailOrientation previewImage:preview];
                    self.attachmentImageView.defaultBackgroundColor = [UIColor whiteColor];
                }
            }
        }
        
        if (_iconImage)
        {
            _iconImage.image = searchCellData.attachmentIcon;
        }
    }
    else
    {
        _title.text = nil;
        _date.text = nil;
        _message.text = @"";
        
        _attachmentImageView.image = nil;
        _iconImage.image = nil;
    }
}

+ (CGFloat)heightForCellData:(MXKCellData *)cellData withMaximumWidth:(CGFloat)maxWidth
{
    // The height is fixed
    return 70;
}

@end
