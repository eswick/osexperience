ARCHS = arm64 armv7
THEOS_BUILD_DIR = debs
include theos/makefiles/common.mk

#ENCRYPT=1
INSTALL_LOCAL=1
MAKE_SOURCE_DYLIB=1


TWEAK_NAME = OSExperience

ifdef MAKE_SOURCE_DYLIB
OSExperience_FILES += $(wildcard tutorial/*.x) $(wildcard missioncontrol/*.xm) $(wildcard *.xm) $(wildcard *.m) $(wildcard missioncontrol/*.m) $(wildcard missioncontrol/*.mm) $(wildcard explorer/*.c) $(wildcard launchpad/*.m)
OSExperience_CFLAGS += -O0 -Wno-unused-function -mno-thumb
OSExperience_FRAMEWORKS += UIKit QuartzCore CoreGraphics IOKit Security CoreText
OSExperience_PRIVATE_FRAMEWORKS += AppSupport GraphicsServices BackBoardServices SpringBoardFoundation
OSExperience_LIBRARIES += rocketbootstrap objcipc MobileGestalt
else
OSExperience_FILES = Notifier.x
OSExperience_FRAMEWORKS += UIKit
endif

ifdef ENCRYPT
OSExperience_FILES += Initializer.S Initializer.init
OSExperience_CFLAGS += -DMACH_ENCRYPT -DMACH_VERIFY_UDID
endif


include $(THEOS_MAKE_PATH)/tweak.mk

ifdef ENCRYPT
after-OSExperience-all::
	cp $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT) $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT).tmp
	rm $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT)
	/Users/eswick/Development/mach_pwn/mach_pwn $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT).tmp -u 9f1b481a4bcce5a47ef72374155289b9246f8a1f -o $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT)
	strip -u -r $(THEOS_OBJ_DIR)/$(THEOS_CURRENT_INSTANCE)$(TARGET_LIB_EXT)
endif

ifdef INSTALL_LOCAL
before-package::
	rm $(THEOS_STAGING_DIR)/DEBIAN/extrainst_
endif

after-install::
	install.exec "killall -9 backboardd"

SUBPROJECTS += osexperienceprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
