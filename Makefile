TARGET=iphone:7.1:7.1
ARCHS = arm64 armv7
THEOS_BUILD_DIR = debs

include theos/makefiles/common.mk

export VERSION=1.0.7



TWEAK_NAME = OSExperience

OSExperience_CFLAGS += -DVERSION=\"$(VERSION)\"

OSExperience_FILES += $(wildcard tutorial/*.x) $(wildcard missioncontrol/*.xm) Hooks.xm $(wildcard *.m) $(wildcard missioncontrol/*.m) $(wildcard missioncontrol/*.mm) $(wildcard explorer/*.c) $(wildcard launchpad/*.m)
OSExperience_CFLAGS += -Wno-deprecated-declarations
OSExperience_FRAMEWORKS += UIKit QuartzCore CoreGraphics IOKit Security CoreText
OSExperience_PRIVATE_FRAMEWORKS += AppSupport GraphicsServices BackBoardServices SpringBoardFoundation
OSExperience_LIBRARIES += rocketbootstrap objcipc MobileGestalt

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"

SUBPROJECTS += osexperienceprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
