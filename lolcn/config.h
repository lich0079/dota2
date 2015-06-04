/*
 *  config.h
 *  XANImageBrowser
 *
 *  Created by Chen Xian'an on 1/3/11.
 *  Copyright 2011 lazyapps.com. All rights reserved.
 *
 */

#define ISPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kThumbSize (ISPAD ? CGSizeMake(128.0, 128.0) : (CGSizeMake(64.0, 64.0)))
#define kSpacing (ISPAD ? 18.0 : 12.0)
#define kCapacityOfThumbsInARowPortrait (ISPAD ? 5 : 4)
#define kCapacityOfThumbsInARowLandscape (ISPAD ? 7 : 6)
#define PAGE_GAP 20.0