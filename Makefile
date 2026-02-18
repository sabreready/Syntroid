ARCHS  = arm64 arm64e x86_64
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Syntroid

Syntroid_FILES      = Tweak.mm
Syntroid_CFLAGS     = -fobjc-arc -Wno-deprecated-declarations
Syntroid_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
Syntroid_LIBRARIES  = substrate

include $(THEOS_MAKE_PATH)/tweak.mk
