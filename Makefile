ARCHS = arm64

THEOS_BUILD_DIR = debs
#DEBUG = 1
include theos/makefiles/common.mk

TWEAK_NAME = OSExperience
OSExperience_FILES = $(wildcard missioncontrol/*.xm) $(wildcard *.xm) $(wildcard *.m) $(wildcard missioncontrol/*.m) $(wildcard missioncontrol/*.mm) $(wildcard explorer/*.c) $(wildcard launchpad/*.m) 
OSExperience_CFLAGS = -Wno-format-nonliteral -Wno-unused-function -DMACH_ENC_VERIFY_UDID
OSExperience_FRAMEWORKS = UIKit QuartzCore CoreGraphics IOKit Security CoreText
OSExperience_PRIVATE_FRAMEWORKS = AppSupport GraphicsServices BackBoardServices SpringBoardFoundation
OSExperience_LIBRARIES = rocketbootstrap objcipc MobileGestalt

ifndef DEBUG
OSExperience_STRIP_FLAGS = -u -r
endif

include $(THEOS_MAKE_PATH)/tweak.mk

after-OSExperience-all::
	theos/bin/mach_prot $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT) __TEXT rwx
	/Users/eswick/Development/mach_encrypt/mach_encrypt $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT) -u 

after-install::
	install.exec "killall -9 backboardd"
