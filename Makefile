include theos/makefiles/common.mk
export ARCHS = armv7 armv7s arm64
export TARGET = iphone:clang:7.0:7.0
TWEAK_NAME = RBJailed
RBJailed_FILES = Tweak.m JGMethodSwizzler.m $(wildcard OCZip/*.m) $(wildcard OCZip/*.c)
ADDITIONAL_LDFLAGS  = -Wl,-segalign,4000,-lz
include $(THEOS_MAKE_PATH)/tweak.mk



