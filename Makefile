THEOS_BUILD_DIR = debs

include theos/makefiles/common.mk

TWEAK_NAME = OSExperience
OSExperience_FILES = Tweak.xm OSWallpaperView.m OSViewController.m OSPane.m OSDesktopPane.m OSSlider.m explorer/OSFile.m explorer/OSFileView.m explorer/OSFileGridView.m UIView+FrameExtensions.m OSAppPane.m
OSExperience_FRAMEWORKS = UIKit QuartzCore CoreGraphics
OSExperience_LDFLAGS = -L/Users/Evan/Dropbox/Projects/iOS/Libraries/libcpbitmap/obj -lcpbitmap

include $(THEOS_MAKE_PATH)/tweak.mk
