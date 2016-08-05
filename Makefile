MOON   = $(shell find -name '*.moon')
NATIVE = main.lua conf.lua
ASSETS = $(shell find assets)
COMPILED  = $(MOON:.moon=.lua)
LOVE = $(NATIVE) $(ASSETS) $(COMPILED) heythere.txt

.PHONY: all clean

all: vision-training-kit.love

vision-training-kit.love: $(LOVE)
	@zip -9g $@ $?

$(COMPILED): %.lua: %.moon
	@moonc $?

clean:
	rm -f $(COMPILED)
