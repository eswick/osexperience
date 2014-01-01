THEOS_BUILD_DIR = debs
DEBUG = 1
include theos/makefiles/common.mk

TWEAK_NAME = OSExperience
OSExperience_FILES = $(wildcard *.xm) $(wildcard *.m) $(wildcard missioncontrol/*.m) $(wildcard explorer/*.m) $(wildcard explorer/*.c) $(wildcard launchpad/*.m) 
OSExperience_LDFLAGS = -lfsmonitor
OSExperience_FRAMEWORKS = UIKit QuartzCore CoreGraphics IOKit Security CoreText
OSExperience_PRIVATE_FRAMEWORKS = AppSupport GraphicsServices BackBoardServices

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
