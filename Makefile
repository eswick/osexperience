ARCHS = arm64 armv7
THEOS_BUILD_DIR = debs
include theos/makefiles/common.mk

#PRODUCE_DYLIB=1

TWEAK_NAME = OSExperience

ifdef PRODUCE_DYLIB
OSExperience_FILES = $(wildcard missioncontrol/*.xm) $(wildcard *.xm) $(wildcard *.m) $(wildcard missioncontrol/*.m) $(wildcard missioncontrol/*.mm) $(wildcard explorer/*.c) $(wildcard launchpad/*.m) Initializer.S Initializer.init
else
OSExperience_FILES = Empty.m
endif

OSExperience_CFLAGS += -O0 -DMACH_VERIFY_UDID -Wno-unused-function -mno-thumb
OSExperience_FRAMEWORKS = UIKit QuartzCore CoreGraphics IOKit Security CoreText
OSExperience_PRIVATE_FRAMEWORKS = AppSupport GraphicsServices BackBoardServices SpringBoardFoundation
OSExperience_LIBRARIES = rocketbootstrap objcipc MobileGestalt

include $(THEOS_MAKE_PATH)/tweak.mk

ifdef PRODUCE_DYLIB
after-OSExperience-all::
	/Users/eswick/Development/mach_pwn/mach_pwn $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT) -u 9f1b481a4bcce5a47ef72374155289b9246f8a1f -o ~/Desktop/OSE.dylib -thin 64
	strip -u -r $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT)
endif

after-install::
	install.exec "killall -9 backboardd"

