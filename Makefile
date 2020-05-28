VCMD=v
VTEST=$(VCMD) test

build:
			$(VCMD) miniv.v
test:
			$(VTEST) .
test2:
			$(VTEST) */**_test.v
test3:
			v -stats test .
clean:
			rm -f miniv *~ tmp*
fmt:
			$(VCMD) fmt ./*.v ./*/*.v

.PHONY: test clean build fmt
