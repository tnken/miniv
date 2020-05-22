VCMD=v
VTEST=$(VCMD) -stats test

build:
			$(VCMD) tinyv.v
test:
			$(VTEST) .
clean:
			rm -f tinyv *~ tmp*
fmt:
			$(VCMD) fmt ./*.v ./*/*.v

.PHONY: test clean build fmt
