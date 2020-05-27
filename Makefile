VCMD=v
VTEST=$(VCMD) test

build:
			$(VCMD) tinyv.v
test:
			$(VTEST) .
test2:
			$(VTEST) */**_test.v
test3:
			v -stats test .
clean:
			rm -f tinyv *~ tmp*
fmt:
			$(VCMD) fmt ./*.v ./*/*.v

.PHONY: test clean build fmt
