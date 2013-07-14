THEOS_BUILD_DIR = debs

include theos/makefiles/common.mk

TWEAK_NAME = OSExperience
OSExperience_FILES = Tweak.xm OSWallpaperView.m OSViewController.m OSPane.m OSDesktopPane.m OSSlider.m explorer/OSFile.m explorer/OSFileView.m explorer/OSFileGridView.m UIView+FrameExtensions.m OSAppPane.m SBSlidingAnimation.xm OSTouchForwarder.m
OSExperience_FRAMEWORKS = UIKit QuartzCore CoreGraphics
OSExperience_PRIVATE_FRAMEWORKS = AppSupport GraphicsServices
OSExperience_LDFLAGS = -L/Users/Evan/Dropbox/Projects/iOS/Libraries/libcpbitmap/obj -lcpbitmap

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	$(ECHO_NOTHING)install.exec "killall -9 backboardd"$(ECHO_END)
