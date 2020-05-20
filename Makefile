tinyv: tinyv.v
			v tinyv.v

test: tinyv
			v -stats test .

clean:
				rm -f tinyv *~ tmp*

.PHONY: test clean
