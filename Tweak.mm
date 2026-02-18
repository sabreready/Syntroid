// ═══════════════════════════════════════════════════════════════════════════════
// SYNTROID — Single File Tweak
// Built from scratch — no skid ✓
// Spawns items by writing animal-company-config.json directly
// Dark red aggressive theme
// ═══════════════════════════════════════════════════════════════════════════════

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <substrate.h>

// ─── Config path (game reads this file for item/slot data) ────────────────────
// The game stores this in its Documents folder — we find it at runtime
static NSString *SYNConfigPath() {
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [docs.firstObject stringByAppendingPathComponent:@"animal-company-config.json"];
}

// ─── Colors ───────────────────────────────────────────────────────────────────
#define SYN_BG          [UIColor colorWithRed:0.06 green:0.04 blue:0.04 alpha:0.97]
#define SYN_BG2         [UIColor colorWithRed:0.11 green:0.07 blue:0.07 alpha:1.0]
#define SYN_BG3         [UIColor colorWithRed:0.15 green:0.09 blue:0.09 alpha:1.0]
#define SYN_RED         [UIColor colorWithRed:0.90 green:0.15 blue:0.15 alpha:1.0]
#define SYN_RED_DIM     [UIColor colorWithRed:0.90 green:0.15 blue:0.15 alpha:0.18]
#define SYN_RED_GLOW    [UIColor colorWithRed:1.00 green:0.20 blue:0.10 alpha:1.0]
#define SYN_ORANGE      [UIColor colorWithRed:1.00 green:0.50 blue:0.10 alpha:1.0]
#define SYN_TEXT        [UIColor colorWithRed:0.95 green:0.88 blue:0.85 alpha:1.0]
#define SYN_TEXT_DIM    [UIColor colorWithRed:0.55 green:0.40 blue:0.38 alpha:1.0]
#define SYN_BORDER      [UIColor colorWithRed:0.85 green:0.12 blue:0.12 alpha:0.40].CGColor
#define SYN_DIVIDER     [UIColor colorWithRed:0.85 green:0.12 blue:0.12 alpha:0.18]

// ─── Glow helper ─────────────────────────────────────────────────────────────
static void SYNGlow(CALayer *l, UIColor *c, CGFloat r) {
    l.shadowColor = c.CGColor; l.shadowRadius = r;
    l.shadowOpacity = 0.85f; l.shadowOffset = CGSizeZero;
}

// ─── All items extracted from real game configs ───────────────────────────────
static NSArray<NSString*>* SYNAllItems() {
    return @[
        // Weapons & Tools
        @"item_alphablade",       @"item_arena_pistol",      @"item_arena_shotgun",
        @"item_axe",              @"item_bat",               @"item_bow",
        @"item_crossbow",         @"item_dagger",            @"item_dynamite",
        @"item_grenade",          @"item_anti_gravity_grenade", @"item_hammer",
        @"item_jetpack",          @"item_machete",           @"item_pickaxe",
        @"item_pistol",           @"item_rpg",               @"item_rpg_ammo",
        @"item_shotgun",          @"item_shovel",            @"item_smg",
        @"item_sniper",           @"item_staff",             @"item_stash_grenade",
        @"item_sword",            @"item_wand",              @"item_torch",
        @"item_flashlight",       @"item_lantern",
        // Valuables
        @"item_goldbar",          @"item_cash_mega_pile",    @"item_coin",
        @"item_gem_blue",         @"item_gem_green",         @"item_gem_red",
        @"item_ruby",             @"item_crown",             @"item_trophy",
        @"item_key",              @"item_diamond",
        // Gear
        @"item_backpack_large_base", @"item_quiver",         @"item_shield",
        @"item_vest",             @"item_medkit",            @"item_potion_health",
        @"item_potion_speed",     @"item_collar",            @"item_football",
        // Fishing
        @"item_fishing_rod",      @"item_fishing_rod_pro",
        @"item_bait_firefly",     @"item_bait_glowworm",     @"item_bait_minnow",
        @"item_fish_bass",        @"item_fish_catfish",      @"item_fish_crab",
        @"item_fish_eel",         @"item_fish_goldfish",     @"item_fish_piranha",
        @"item_fish_salmon",      @"item_fish_shark",        @"item_fish_trout",
        // Food
        @"item_apple",            @"item_banana",            @"item_bread",
        @"item_carrot",           @"item_cheese",            @"item_mushroom",
        @"item_egg",              @"item_water",             @"item_bone",
        @"item_turkey_whole",     @"item_turkey_leg",        @"item_heartchocolatebox",
        @"item_stinky_cheese",    @"item_company_ration",    @"item_cracker",
        @"item_radioactive_broccoli", @"item_campfire",
    ];
}

static NSArray<NSString*>* SYNCategoryItems(NSInteger cat) {
    switch(cat) {
        case 1: return @[@"item_fishing_rod",@"item_fishing_rod_pro"];
        case 2: return @[@"item_fish_bass",@"item_fish_catfish",@"item_fish_crab",
                         @"item_fish_eel",@"item_fish_goldfish",@"item_fish_piranha",
                         @"item_fish_salmon",@"item_fish_shark",@"item_fish_trout"];
        case 3: return @[@"item_bait_firefly",@"item_bait_glowworm",@"item_bait_minnow"];
        case 4: return @[@"item_alphablade",@"item_arena_pistol",@"item_arena_shotgun",
                         @"item_axe",@"item_bat",@"item_bow",@"item_crossbow",@"item_dagger",
                         @"item_dynamite",@"item_grenade",@"item_anti_gravity_grenade",
                         @"item_hammer",@"item_jetpack",@"item_machete",@"item_pickaxe",
                         @"item_pistol",@"item_rpg",@"item_rpg_ammo",@"item_shotgun",
                         @"item_shovel",@"item_smg",@"item_sniper",@"item_staff",
                         @"item_stash_grenade",@"item_sword",@"item_wand"];
        case 5: return @[@"item_goldbar",@"item_cash_mega_pile",@"item_coin",
                         @"item_gem_blue",@"item_gem_green",@"item_gem_red",
                         @"item_ruby",@"item_crown",@"item_trophy",@"item_diamond"];
        case 6: return @[@"item_apple",@"item_banana",@"item_bread",@"item_carrot",
                         @"item_cheese",@"item_mushroom",@"item_egg",@"item_water",
                         @"item_bone",@"item_turkey_whole",@"item_turkey_leg",
                         @"item_heartchocolatebox",@"item_stinky_cheese",
                         @"item_company_ration",@"item_cracker",@"item_radioactive_broccoli"];
        default: return SYNAllItems();
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: — JSON Config Writer
// ═══════════════════════════════════════════════════════════════════════════════

static NSDictionary* SYNMakeItemNode(NSString *itemID, NSInteger hue, NSInteger sat,
                                      NSInteger scale, NSInteger count, NSArray *children) {
    NSMutableDictionary *node = [@{
        @"itemID": itemID,
        @"colorHue": @(hue),
        @"colorSaturation": @(sat),
        @"scaleModifier": @(scale),
        @"state": @(0),
        @"count": @(count),
    } mutableCopy];
    if (children.count > 0) node[@"children"] = children;
    return node;
}

static BOOL SYNWriteConfig(NSString *slot, NSString *itemID,
                            NSInteger hue, NSInteger sat,
                            NSInteger scale, NSInteger count,
                            NSArray *children) {
    NSString *path = SYNConfigPath();

    // Load existing config or start fresh
    NSMutableDictionary *config = [@{
        @"leftHand":  [NSMutableDictionary dictionary],
        @"rightHand": [NSMutableDictionary dictionary],
        @"leftHip":   [NSMutableDictionary dictionary],
        @"rightHip":  [NSMutableDictionary dictionary],
        @"back":      [NSMutableDictionary dictionary],
    } mutableCopy];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *existing = [NSData dataWithContentsOfFile:path];
        NSDictionary *parsed = [NSJSONSerialization JSONObjectWithData:existing options:0 error:nil];
        if (parsed) config = [parsed mutableCopy];
    }

    // Build item node with optional children (for multi-spawn)
    NSMutableArray *childNodes = [NSMutableArray array];
    if (children) [childNodes addObjectsFromArray:children];

    // For count > 1, duplicate as children
    if (count > 1 && children == nil) {
        for (NSInteger i = 1; i < count; i++) {
            [childNodes addObject:SYNMakeItemNode(itemID, hue, sat, 0, 1, nil)];
        }
    }

    NSDictionary *node = SYNMakeItemNode(itemID, hue, sat, scale, 1,
                                          childNodes.count > 0 ? childNodes : nil);
    config[slot] = node;

    NSData *data = [NSJSONSerialization dataWithJSONObject:config
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    return [data writeToFile:path atomically:YES];
}

static void SYNClearSlot(NSString *slot) {
    NSString *path = SYNConfigPath();
    NSMutableDictionary *config = [@{
        @"leftHand":@{}, @"rightHand":@{}, @"leftHip":@{},
        @"rightHip":@{}, @"back":@{}
    } mutableCopy];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *d = [NSData dataWithContentsOfFile:path];
        NSDictionary *p = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
        if (p) config = [p mutableCopy];
    }
    config[slot] = [NSMutableDictionary dictionary];
    NSData *data = [NSJSONSerialization dataWithJSONObject:config
                                                   options:NSJSONWritingPrettyPrinted error:nil];
    [data writeToFile:path atomically:YES];
}

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: — Toast
// ═══════════════════════════════════════════════════════════════════════════════

static void SYNToast(NSString *msg, BOOL success) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        UILabel *t = [[UILabel alloc] init];
        t.text = [NSString stringWithFormat:@" %@  %@ ", success ? @"✓" : @"✕", msg];
        t.font = [UIFont boldSystemFontOfSize:12];
        t.textColor = SYN_TEXT;
        t.backgroundColor = success ? [UIColor colorWithRed:0.08 green:0.12 blue:0.08 alpha:0.96]
                                     : [UIColor colorWithRed:0.12 green:0.05 blue:0.05 alpha:0.96];
        t.layer.cornerRadius = 10;
        t.layer.borderWidth = 1.2;
        t.layer.borderColor = success ?
            [UIColor colorWithRed:0.2 green:0.8 blue:0.3 alpha:0.5].CGColor : SYN_BORDER;
        t.clipsToBounds = YES;
        t.textAlignment = NSTextAlignmentCenter;
        CGSize sz = [msg sizeWithAttributes:@{NSFontAttributeName:t.font}];
        t.frame = CGRectMake((win.bounds.size.width - sz.width - 60)/2,
                              win.bounds.size.height - 110, sz.width + 60, 32);
        t.alpha = 0; t.transform = CGAffineTransformMakeTranslation(0, 10);
        [win addSubview:t];
        [UIView animateWithDuration:0.25 animations:^{ t.alpha=1; t.transform=CGAffineTransformIdentity; }
                         completion:^(BOOL d){
            [UIView animateWithDuration:0.25 delay:1.8 options:0
                             animations:^{ t.alpha=0; t.transform=CGAffineTransformMakeTranslation(0,6); }
                             completion:^(BOOL d2){ [t removeFromSuperview]; }];
        }];
    });
}

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: — Syntroid Menu
// ═══════════════════════════════════════════════════════════════════════════════

@interface SyntroidMenu : UIView <UITextFieldDelegate>

@property (nonatomic, assign) NSInteger selectedTab;       // 0=Items 1=Settings
@property (nonatomic, assign) NSInteger selectedCategory;  // 0-6
@property (nonatomic, strong) NSString  *selectedItem;
@property (nonatomic, strong) NSString  *selectedSlot;
@property (nonatomic, assign) NSInteger colorHue;
@property (nonatomic, assign) NSInteger colorSat;
@property (nonatomic, assign) NSInteger scaleVal;
@property (nonatomic, assign) NSInteger quantity;
@property (nonatomic, assign) BOOL      spinEnabled;

// UI refs
@property (nonatomic, strong) UIView       *itemsPage;
@property (nonatomic, strong) UIView       *settingsPage;
@property (nonatomic, strong) UIScrollView *itemList;
@property (nonatomic, strong) UITextField  *searchField;
@property (nonatomic, strong) UILabel      *selectedItemLabel;
@property (nonatomic, strong) UILabel      *qtyLabel;
@property (nonatomic, strong) UILabel      *hueLabel;
@property (nonatomic, strong) UILabel      *satLabel;
@property (nonatomic, strong) UILabel      *scaleLabel;
@property (nonatomic, strong) UILabel      *slotLabel;
@property (nonatomic, strong) UILabel      *countLabel;
@property (nonatomic, strong) NSArray      *currentItems;
@property (nonatomic, strong) NSMutableArray *rowViews;
@property (nonatomic, strong) UIView       *selectedRowHighlight;

@end

@implementation SyntroidMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _selectedTab = 0;
    _selectedCategory = 0;
    _selectedSlot = @"leftHand";
    _colorHue = 159;
    _colorSat = 120;
    _scaleVal = 0;
    _quantity = 1;
    _currentItems = SYNAllItems();
    _rowViews = [NSMutableArray array];
    [self buildUI];
    return self;
}

// ─── Build entire UI ──────────────────────────────────────────────────────────
- (void)buildUI {
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;

    // Panel
    self.backgroundColor = SYN_BG;
    self.layer.cornerRadius = 16;
    self.layer.borderWidth = 1.5;
    self.layer.borderColor = SYN_BORDER;
    SYNGlow(self.layer, SYN_RED, 22);
    self.clipsToBounds = NO;

    UIView *clip = [[UIView alloc] initWithFrame:self.bounds];
    clip.layer.cornerRadius = 16;
    clip.clipsToBounds = YES;
    [self addSubview:clip];

    // Red top stripe
    UIView *stripe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 3)];
    stripe.backgroundColor = SYN_RED;
    SYNGlow(stripe.layer, SYN_RED_GLOW, 8);
    [clip addSubview:stripe];

    // Header bg
    UIView *hdrBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 50)];
    hdrBg.backgroundColor = SYN_BG2;
    [clip insertSubview:hdrBg atIndex:0];

    // Drag on header
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    [hdrBg addGestureRecognizer:pan];

    // Close button
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(8, 12, 28, 28)];
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:SYN_RED forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    closeBtn.backgroundColor = SYN_RED_DIM;
    closeBtn.layer.cornerRadius = 14;
    closeBtn.layer.borderWidth = 1; closeBtn.layer.borderColor = SYN_BORDER;
    [clip addSubview:closeBtn];
    UITapGestureRecognizer *ct = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
    [ct addTarget:^(id s){ [self dismiss]; } withObject:nil];
    [closeBtn addGestureRecognizer:ct];

    // Title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, w, 24)];
    title.text = @"SYNTROID";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = SYN_RED;
    title.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:18] ?: [UIFont boldSystemFontOfSize:18];
    SYNGlow(title.layer, SYN_RED_GLOW, 10);
    [clip addSubview:title];

    // Tab bar
    [clip addSubview:[self buildTabBarAtY:52 width:w]];

    // Divider
    UIView *div = [[UIView alloc] initWithFrame:CGRectMake(10, 92, w-20, 1)];
    div.backgroundColor = SYN_DIVIDER;
    [clip addSubview:div];

    // Pages
    CGRect pageFrame = CGRectMake(0, 96, w, h-96);
    _itemsPage    = [[UIView alloc] initWithFrame:pageFrame];
    _settingsPage = [[UIView alloc] initWithFrame:pageFrame];
    _settingsPage.hidden = YES;
    _itemsPage.backgroundColor = [UIColor clearColor];
    _settingsPage.backgroundColor = [UIColor clearColor];
    [clip addSubview:_itemsPage];
    [clip addSubview:_settingsPage];

    [self buildItemsPage];
    [self buildSettingsPage];
}

// ─── Tab Bar ──────────────────────────────────────────────────────────────────
- (UIView *)buildTabBarAtY:(CGFloat)y width:(CGFloat)w {
    UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(10, y, w-20, 36)];
    bar.backgroundColor = SYN_BG2;
    bar.layer.cornerRadius = 10;
    bar.layer.borderWidth = 1; bar.layer.borderColor = SYN_BORDER;

    NSArray *tabs = @[@"Items", @"Settings"];
    CGFloat tw = (w-20)/tabs.count;
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(2, 2, tw-4, 32)];
    indicator.backgroundColor = SYN_RED_DIM;
    indicator.layer.cornerRadius = 8;
    indicator.layer.borderWidth = 1; indicator.layer.borderColor = SYN_BORDER;
    SYNGlow(indicator.layer, SYN_RED, 6);
    indicator.tag = 9001;
    [bar addSubview:indicator];

    for (NSInteger i = 0; i < tabs.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(tw*i+2, 2, tw-4, 32)];
        [btn setTitle:tabs[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [btn setTitleColor:(i==0 ? SYN_TEXT : SYN_TEXT_DIM) forState:UIControlStateNormal];
        btn.tag = 8000+i;
        UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
        NSInteger capturedI = i; UIView *capturedBar = bar;
        [t addTarget:^(id s){
            [self switchToTab:capturedI bar:capturedBar tabW:tw];
        } withObject:nil];
        [btn addGestureRecognizer:t];
        [bar addSubview:btn];
    }
    return bar;
}

- (void)switchToTab:(NSInteger)idx bar:(UIView*)bar tabW:(CGFloat)tw {
    _selectedTab = idx;
    _itemsPage.hidden    = (idx != 0);
    _settingsPage.hidden = (idx != 1);
    UIView *ind = [bar viewWithTag:9001];
    [UIView animateWithDuration:0.22 delay:0 usingSpringWithDamping:0.75
          initialSpringVelocity:0.5 options:0 animations:^{
        ind.frame = CGRectMake(tw*idx+2, 2, tw-4, 32);
    } completion:nil];
    for (NSInteger i = 0; i < 2; i++) {
        UIButton *b = (UIButton*)[bar viewWithTag:8000+i];
        [b setTitleColor:(i==idx ? SYN_TEXT : SYN_TEXT_DIM) forState:UIControlStateNormal];
    }
}

// ─── Items Page ───────────────────────────────────────────────────────────────
- (void)buildItemsPage {
    CGFloat w = _itemsPage.bounds.size.width;
    CGFloat h = _itemsPage.bounds.size.height;

    // Category scroll
    UIScrollView *catScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 4, w, 38)];
    catScroll.showsHorizontalScrollIndicator = NO;
    catScroll.backgroundColor = [UIColor clearColor];
    NSArray *cats = @[@"All",@"Rods",@"Fish",@"Baits",@"Weapons",@"Valuables",@"Food"];
    CGFloat cx = 8;
    for (NSInteger i = 0; i < cats.count; i++) {
        CGFloat pw = [cats[i] sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11]}].width + 22;
        UIButton *pill = [[UIButton alloc] initWithFrame:CGRectMake(cx, 4, pw, 28)];
        [pill setTitle:cats[i] forState:UIControlStateNormal];
        pill.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        pill.layer.cornerRadius = 14;
        pill.layer.borderWidth = 1.2;
        BOOL active = (i == 0);
        pill.backgroundColor = active ? SYN_RED_DIM : [UIColor colorWithWhite:1 alpha:0.04];
        [pill setTitleColor:active ? SYN_RED : SYN_TEXT_DIM forState:UIControlStateNormal];
        pill.layer.borderColor = active ? SYN_BORDER : [UIColor colorWithWhite:1 alpha:0.08].CGColor;
        pill.tag = 7000+i;
        UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
        NSInteger capturedI = i; UIScrollView *capturedScroll = catScroll;
        [t addTarget:^(id s){ [self selectCategory:capturedI scroll:capturedScroll]; } withObject:nil];
        [pill addGestureRecognizer:t];
        [catScroll addSubview:pill];
        cx += pw + 6;
    }
    catScroll.contentSize = CGSizeMake(cx+8, 38);
    [_itemsPage addSubview:catScroll];

    // Search
    UIView *sw = [[UIView alloc] initWithFrame:CGRectMake(10, 46, w-20, 32)];
    sw.backgroundColor = SYN_BG2; sw.layer.cornerRadius = 8;
    sw.layer.borderWidth = 1; sw.layer.borderColor = SYN_BORDER;
    [_itemsPage addSubview:sw];
    UILabel *gl = [[UILabel alloc] initWithFrame:CGRectMake(8,0,22,32)];
    gl.text = @"🔍"; gl.font = [UIFont systemFontOfSize:12];
    [sw addSubview:gl];
    _searchField = [[UITextField alloc] initWithFrame:CGRectMake(30, 2, w-62, 28)];
    _searchField.placeholder = @"Search items...";
    _searchField.font = [UIFont systemFontOfSize:12];
    _searchField.textColor = SYN_TEXT;
    [_searchField setValue:SYN_TEXT_DIM forKeyPath:@"_placeholderLabel.textColor"];
    _searchField.backgroundColor = [UIColor clearColor];
    _searchField.delegate = self;
    [_searchField addTarget:self action:@selector(searchChanged) forControlEvents:UIControlEventEditingChanged];
    [sw addSubview:_searchField];

    // Header row
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(w-80, 82, 70, 16)];
    _countLabel.text = [NSString stringWithFormat:@"%lu items", (unsigned long)SYNAllItems().count];
    _countLabel.font = [UIFont systemFontOfSize:10]; _countLabel.textColor = SYN_RED;
    _countLabel.textAlignment = NSTextAlignmentRight;
    [_itemsPage addSubview:_countLabel];
    UILabel *iHdr = [[UILabel alloc] initWithFrame:CGRectMake(12, 82, 150, 16)];
    iHdr.text = @"ITEM SPAWNER"; iHdr.font = [UIFont boldSystemFontOfSize:10];
    iHdr.textColor = SYN_TEXT_DIM;
    [_itemsPage addSubview:iHdr];

    // Selected item display
    UIView *selWrap = [[UIView alloc] initWithFrame:CGRectMake(10, 101, w-20, 26)];
    selWrap.backgroundColor = SYN_RED_DIM; selWrap.layer.cornerRadius = 6;
    selWrap.layer.borderWidth = 1; selWrap.layer.borderColor = SYN_BORDER;
    [_itemsPage addSubview:selWrap];
    _selectedItemLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,0,w-40,26)];
    _selectedItemLabel.text = @"tap an item to select...";
    _selectedItemLabel.font = [UIFont fontWithName:@"Menlo" size:10] ?: [UIFont systemFontOfSize:10];
    _selectedItemLabel.textColor = SYN_TEXT_DIM;
    [selWrap addSubview:_selectedItemLabel];

    // Item list
    CGFloat listH = h - 282;
    _itemList = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 131, w-20, listH)];
    _itemList.backgroundColor = SYN_BG2;
    _itemList.layer.cornerRadius = 10;
    _itemList.layer.borderWidth = 1; _itemList.layer.borderColor = SYN_BORDER;
    [_itemsPage addSubview:_itemList];
    [self reloadItemList];

    // Bottom controls
    CGFloat by = 131 + listH + 8;

    // Quantity row
    [_itemsPage addSubview:[self makeLabel:@"Qty:" font:[UIFont boldSystemFontOfSize:11]
                                    color:SYN_TEXT_DIM frame:CGRectMake(12, by, 30, 28)]];
    _qtyLabel = [self makeLabel:@"1" font:[UIFont boldSystemFontOfSize:15]
                          color:SYN_ORANGE frame:CGRectMake(44, by, 36, 28)];
    _qtyLabel.textAlignment = NSTextAlignmentCenter;
    [_itemsPage addSubview:_qtyLabel];
    [_itemsPage addSubview:[self makeStepperMinus:CGRectMake(82, by+2, 28, 24) action:@selector(qtyMinus)]];
    [_itemsPage addSubview:[self makeStepperPlus:CGRectMake(112, by+2, 28, 24) action:@selector(qtyPlus)]];

    // Slot row
    [_itemsPage addSubview:[self makeLabel:@"Slot:" font:[UIFont boldSystemFontOfSize:11]
                                    color:SYN_TEXT_DIM frame:CGRectMake(w/2, by, 36, 28)]];
    _slotLabel = [self makeLabel:@"leftHand" font:[UIFont boldSystemFontOfSize:10]
                           color:SYN_RED frame:CGRectMake(w/2+38, by, 90, 28)];
    [_itemsPage addSubview:_slotLabel];
    UIButton *slotBtn = [[UIButton alloc] initWithFrame:CGRectMake(w-46, by, 36, 28)];
    slotBtn.backgroundColor = SYN_BG2; slotBtn.layer.cornerRadius = 7;
    slotBtn.layer.borderWidth = 1; slotBtn.layer.borderColor = SYN_BORDER;
    [slotBtn setTitle:@"⇄" forState:UIControlStateNormal];
    [slotBtn setTitleColor:SYN_RED forState:UIControlStateNormal];
    slotBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    UITapGestureRecognizer *slotT = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
    [slotT addTarget:^(id s){ [self cycleSlot]; } withObject:nil];
    [slotBtn addGestureRecognizer:slotT];
    [_itemsPage addSubview:slotBtn];

    // Divider
    UIView *d2 = [[UIView alloc] initWithFrame:CGRectMake(10, by+32, w-20, 1)];
    d2.backgroundColor = SYN_DIVIDER; [_itemsPage addSubview:d2];

    // Spawn + Clear buttons
    UIButton *spawn = [[UIButton alloc] initWithFrame:CGRectMake(10, by+38, w-20-56, 38)];
    spawn.backgroundColor = SYN_RED; spawn.layer.cornerRadius = 10;
    [spawn setTitle:@"▶  SPAWN" forState:UIControlStateNormal];
    [spawn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    spawn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    SYNGlow(spawn.layer, SYN_RED_GLOW, 12);
    UITapGestureRecognizer *spawnT = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
    [spawnT addTarget:^(id s){ [self doSpawn]; } withObject:nil];
    [spawn addGestureRecognizer:spawnT];
    [_itemsPage addSubview:spawn];

    UIButton *clear = [[UIButton alloc] initWithFrame:CGRectMake(w-52, by+38, 42, 38)];
    clear.backgroundColor = SYN_BG3; clear.layer.cornerRadius = 10;
    clear.layer.borderWidth = 1; clear.layer.borderColor = SYN_BORDER;
    [clear setTitle:@"🗑" forState:UIControlStateNormal];
    clear.titleLabel.font = [UIFont systemFontOfSize:16];
    UITapGestureRecognizer *clearT = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
    [clearT addTarget:^(id s){ [self doClear]; } withObject:nil];
    [clear addGestureRecognizer:clearT];
    [_itemsPage addSubview:clear];
}

// ─── Settings Page ────────────────────────────────────────────────────────────
- (void)buildSettingsPage {
    CGFloat w = _settingsPage.bounds.size.width;

    [_settingsPage addSubview:[self makeLabel:@"APPEARANCE" font:[UIFont boldSystemFontOfSize:10]
                                       color:SYN_TEXT_DIM frame:CGRectMake(12,8,w,16)]];
    UIView *d = [[UIView alloc] initWithFrame:CGRectMake(10,27,w-20,1)];
    d.backgroundColor = SYN_DIVIDER; [_settingsPage addSubview:d];

    // Hue slider
    [self addSliderRow:@"Color Hue" value:159 min:0 max:360 y:34
                 label:&_hueLabel action:@selector(hueChanged:) inView:_settingsPage];
    // Sat slider
    [self addSliderRow:@"Color Sat" value:120 min:0 max:255 y:82
                 label:&_satLabel action:@selector(satChanged:) inView:_settingsPage];
    // Scale slider
    [self addSliderRow:@"Scale" value:0 min:-100 max:200 y:130
                 label:&_scaleLabel action:@selector(scaleChanged:) inView:_settingsPage];

    UIView *d2 = [[UIView alloc] initWithFrame:CGRectMake(10,178,w-20,1)];
    d2.backgroundColor = SYN_DIVIDER; [_settingsPage addSubview:d2];

    [_settingsPage addSubview:[self makeLabel:@"FEATURES" font:[UIFont boldSystemFontOfSize:10]
                                       color:SYN_TEXT_DIM frame:CGRectMake(12,184,w,16)]];

    [self addToggleRow:@"Spin Items" subtitle:@"Items rotate in hand" y:200 inView:_settingsPage action:@selector(toggleSpin:)];
    [self addToggleRow:@"God Mode"   subtitle:@"Infinite health"      y:250 inView:_settingsPage action:@selector(toggleGod:)];
    [self addToggleRow:@"No Clip"    subtitle:@"Walk through walls"   y:300 inView:_settingsPage action:@selector(toggleClip:)];

    // Config path info
    UILabel *pathLbl = [[UILabel alloc] initWithFrame:CGRectMake(12, 358, w-24, 30)];
    pathLbl.text = [NSString stringWithFormat:@"📁 %@", SYNConfigPath()];
    pathLbl.font = [UIFont fontWithName:@"Menlo" size:8] ?: [UIFont systemFontOfSize:8];
    pathLbl.textColor = SYN_TEXT_DIM;
    pathLbl.numberOfLines = 2;
    [_settingsPage addSubview:pathLbl];
}

- (void)addSliderRow:(NSString*)name value:(CGFloat)val min:(CGFloat)mn max:(CGFloat)mx
                   y:(CGFloat)y label:(UILabel**)lbl action:(SEL)action inView:(UIView*)v {
    CGFloat w = v.bounds.size.width;
    [v addSubview:[self makeLabel:name font:[UIFont boldSystemFontOfSize:11]
                            color:SYN_TEXT frame:CGRectMake(12,y,100,18)]];
    UILabel *valLbl = [self makeLabel:[NSString stringWithFormat:@"%.0f", val]
                                 font:[UIFont boldSystemFontOfSize:11]
                                color:SYN_ORANGE frame:CGRectMake(w-50,y,40,18)];
    valLbl.textAlignment = NSTextAlignmentRight;
    [v addSubview:valLbl];
    if (lbl) *lbl = valLbl;

    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(12, y+20, w-24, 22)];
    slider.minimumValue = mn; slider.maximumValue = mx; slider.value = val;
    slider.minimumTrackTintColor = SYN_RED;
    slider.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.1];
    slider.thumbTintColor = [UIColor whiteColor];
    [slider addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [v addSubview:slider];
}

- (void)addToggleRow:(NSString*)title subtitle:(NSString*)sub y:(CGFloat)y inView:(UIView*)v action:(SEL)action {
    CGFloat w = v.bounds.size.width;
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(10, y, w-20, 44)];
    row.backgroundColor = SYN_BG2; row.layer.cornerRadius = 10;
    row.layer.borderWidth = 1; row.layer.borderColor = SYN_BORDER;
    [v addSubview:row];
    [row addSubview:[self makeLabel:title font:[UIFont boldSystemFontOfSize:12]
                              color:SYN_TEXT frame:CGRectMake(12,5,w-80,18)]];
    [row addSubview:[self makeLabel:sub font:[UIFont systemFontOfSize:10]
                              color:SYN_TEXT_DIM frame:CGRectMake(12,22,w-80,16)]];
    UISwitch *sw = [[UISwitch alloc] init];
    sw.onTintColor = SYN_RED;
    sw.transform = CGAffineTransformMakeScale(0.78, 0.78);
    sw.frame = CGRectMake(w-68, 8, 51, 31);
    [sw addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [row addSubview:sw];
}

// ─── Item List ────────────────────────────────────────────────────────────────
- (void)reloadItemList {
    for (UIView *r in _rowViews) [r removeFromSuperview];
    [_rowViews removeAllObjects];

    NSArray *items = _currentItems;
    NSString *q = _searchField.text;
    if (q.length > 0) {
        items = [items filteredArrayUsingPredicate:
                 [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", q]];
    }

    CGFloat rh = 36;
    for (NSInteger i = 0; i < items.count; i++) {
        NSString *name = items[i];
        UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, i*rh, _itemList.bounds.size.width, rh)];
        row.backgroundColor = (i%2==0) ? [UIColor clearColor] : [UIColor colorWithWhite:1 alpha:0.02];

        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, _itemList.bounds.size.width-20, rh)];
        lbl.text = name;
        lbl.font = [UIFont fontWithName:@"Menlo" size:11] ?: [UIFont systemFontOfSize:11];
        lbl.textColor = [name isEqualToString:_selectedItem] ? SYN_RED : SYN_TEXT;
        lbl.adjustsFontSizeToFitWidth = YES;
        [row addSubview:lbl];

        if ([name isEqualToString:_selectedItem]) {
            row.backgroundColor = SYN_RED_DIM;
            SYNGlow(row.layer, SYN_RED, 4);
        }

        UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
        UIView *cr = row; NSString *cn = name;
        [t addTarget:^(id s){ [self selectItemNamed:cn row:cr]; } withObject:nil];
        [row addGestureRecognizer:t];
        [_itemList addSubview:row];
        [_rowViews addObject:row];
    }
    _itemList.contentSize = CGSizeMake(_itemList.bounds.size.width, items.count * rh);
    _countLabel.text = [NSString stringWithFormat:@"%lu items", (unsigned long)items.count];
}

- (void)selectItemNamed:(NSString*)name row:(UIView*)row {
    _selectedItem = name;
    _selectedItemLabel.text = name;
    _selectedItemLabel.textColor = SYN_TEXT;
    [self reloadItemList];
}

- (void)selectCategory:(NSInteger)idx scroll:(UIScrollView*)scroll {
    _selectedCategory = idx;
    _currentItems = SYNCategoryItems(idx);
    _searchField.text = @"";
    [self reloadItemList];
    // Update pill styles
    for (UIView *sub in scroll.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            UIButton *b = (UIButton*)sub;
            NSInteger bi = b.tag - 7000;
            BOOL active = (bi == idx);
            b.backgroundColor = active ? SYN_RED_DIM : [UIColor colorWithWhite:1 alpha:0.04];
            [b setTitleColor:active ? SYN_RED : SYN_TEXT_DIM forState:UIControlStateNormal];
            b.layer.borderColor = active ? SYN_BORDER : [UIColor colorWithWhite:1 alpha:0.08].CGColor;
            if (active) SYNGlow(b.layer, SYN_RED, 5);
            else b.layer.shadowOpacity = 0;
        }
    }
}

- (void)searchChanged { [self reloadItemList]; }

// ─── Actions ──────────────────────────────────────────────────────────────────
- (void)qtyMinus { if (_quantity > 1)   { _quantity--;  _qtyLabel.text = @(_quantity).stringValue; } }
- (void)qtyPlus  { if (_quantity < 500) { _quantity++;  _qtyLabel.text = @(_quantity).stringValue; } }

- (void)cycleSlot {
    NSArray *slots = @[@"leftHand", @"rightHand", @"leftHip", @"rightHip", @"back"];
    NSInteger idx = [slots indexOfObject:_selectedSlot];
    _selectedSlot = slots[(idx+1) % slots.count];
    _slotLabel.text = _selectedSlot;
}

- (void)hueChanged:(UISlider*)s   { _colorHue = (NSInteger)s.value; _hueLabel.text   = @(_colorHue).stringValue; }
- (void)satChanged:(UISlider*)s   { _colorSat = (NSInteger)s.value; _satLabel.text   = @(_colorSat).stringValue; }
- (void)scaleChanged:(UISlider*)s { _scaleVal  = (NSInteger)s.value; _scaleLabel.text = @(_scaleVal).stringValue; }
- (void)toggleSpin:(UISwitch*)s   { _spinEnabled = s.on; NSLog(@"[Syntroid] Spin: %d", s.on); }
- (void)toggleGod:(UISwitch*)s    { NSLog(@"[Syntroid] God: %d", s.on); }
- (void)toggleClip:(UISwitch*)s   { NSLog(@"[Syntroid] NoClip: %d", s.on); }

- (void)doSpawn {
    if (!_selectedItem) { SYNToast(@"Select an item first", NO); return; }

    // Build children array for quantity > 1
    NSMutableArray *children = nil;
    if (_quantity > 1) {
        children = [NSMutableArray array];
        for (NSInteger i = 1; i < _quantity; i++) {
            [children addObject:SYNMakeItemNode(_selectedItem, _colorHue, _colorSat, 0, 1, nil)];
        }
    }

    BOOL ok = SYNWriteConfig(_selectedSlot, _selectedItem, _colorHue, _colorSat,
                              _scaleVal, _quantity, children);
    if (ok) SYNToast([NSString stringWithFormat:@"Spawned %@ x%ld in %@",
                      _selectedItem, (long)_quantity, _selectedSlot], YES);
    else SYNToast(@"Failed to write config", NO);
}

- (void)doClear {
    SYNClearSlot(_selectedSlot);
    SYNToast([NSString stringWithFormat:@"Cleared %@", _selectedSlot], YES);
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0; self.transform = CGAffineTransformMakeScale(0.9,0.9);
    } completion:^(BOOL d){
        self.hidden = YES; self.alpha = 1; self.transform = CGAffineTransformIdentity;
    }];
}

- (void)handleDrag:(UIPanGestureRecognizer*)pan {
    CGPoint d = [pan translationInView:self.superview];
    self.center = CGPointMake(self.center.x+d.x, self.center.y+d.y);
    [pan setTranslation:CGPointZero inView:self.superview];
}

// ─── UITextFieldDelegate ──────────────────────────────────────────────────────
- (BOOL)textFieldShouldReturn:(UITextField*)tf { [tf resignFirstResponder]; return YES; }

// ─── Helpers ──────────────────────────────────────────────────────────────────
- (UILabel*)makeLabel:(NSString*)t font:(UIFont*)f color:(UIColor*)c frame:(CGRect)r {
    UILabel *l = [[UILabel alloc] initWithFrame:r];
    l.text=t; l.font=f; l.textColor=c; l.backgroundColor=[UIColor clearColor];
    return l;
}

- (UIButton*)makeStepperMinus:(CGRect)r action:(SEL)a {
    UIButton *b = [self makeStepperBtn:@"−" frame:r]; [b addGestureRecognizer:[self tapForSel:a]]; return b;
}
- (UIButton*)makeStepperPlus:(CGRect)r action:(SEL)a {
    UIButton *b = [self makeStepperBtn:@"+" frame:r]; [b addGestureRecognizer:[self tapForSel:a]]; return b;
}
- (UIButton*)makeStepperBtn:(NSString*)t frame:(CGRect)r {
    UIButton *b = [[UIButton alloc] initWithFrame:r];
    b.backgroundColor = SYN_BG2; b.layer.cornerRadius = 6;
    b.layer.borderWidth=1; b.layer.borderColor=SYN_BORDER;
    [b setTitle:t forState:UIControlStateNormal];
    [b setTitleColor:SYN_RED forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    return b;
}
- (UITapGestureRecognizer*)tapForSel:(SEL)sel {
    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:sel];
    return t;
}
@end

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: — Injection
// ═══════════════════════════════════════════════════════════════════════════════

static SyntroidMenu *gMenu = nil;
static UIButton     *gBtn  = nil;

static void SYNInject() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5*NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (!win) return;

        // Floating button
        gBtn = [[UIButton alloc] initWithFrame:CGRectMake(win.bounds.size.width-52, 90, 42, 42)];
        gBtn.backgroundColor = [UIColor colorWithRed:0.06 green:0.04 blue:0.04 alpha:0.95];
        gBtn.layer.cornerRadius = 21;
        gBtn.layer.borderWidth = 2; gBtn.layer.borderColor = SYN_BORDER;
        SYNGlow(gBtn.layer, SYN_RED_GLOW, 10);
        [gBtn setTitle:@"⚔️" forState:UIControlStateNormal];
        gBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [win addSubview:gBtn];

        // Menu
        CGFloat mw = MIN(win.bounds.size.width - 24, 320);
        CGFloat mh = MIN(win.bounds.size.height - 100, 560);
        gMenu = [[SyntroidMenu alloc] initWithFrame:CGRectMake(
            (win.bounds.size.width - mw)/2,
            (win.bounds.size.height - mh)/2, mw, mh)];
        gMenu.hidden = YES;
        [win addSubview:gMenu];

        // Toggle
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
        [tap addTarget:^(id t){
            if (gMenu.hidden) {
                gMenu.hidden = NO; gMenu.alpha = 0;
                gMenu.transform = CGAffineTransformMakeScale(0.85,0.85);
                [UIView animateWithDuration:0.28 delay:0
                     usingSpringWithDamping:0.72 initialSpringVelocity:0.5 options:0
                                 animations:^{ gMenu.alpha=1; gMenu.transform=CGAffineTransformIdentity; }
                                 completion:nil];
            } else { [gMenu dismiss]; }
        } withObject:nil];
        [gBtn addGestureRecognizer:tap];
    });
}

%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ SYNInject(); });
}
%end
