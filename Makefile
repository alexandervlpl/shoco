FLAGS=$(CFLAGS) -std=c99 -O3 -Wall
SOURCES=shoco.c
OBJECTS=$(SOURCES:.c=.o)
HEADERS=shoco.h shoco_model.h
GENERATOR=generate_compressor_model.py
TRAINING_DATA_DIR=training_data
TRAINING_DATA=$(wildcard training_data/*.txt)
TABLES_DIR=models
TABLES=$(TABLES_DIR)/text_en.h $(TABLES_DIR)/words_en.h $(TABLES_DIR)/filepaths.h

.PHONY: all
all: shoco

shoco: shoco-bin.o $(OBJECTS) $(HEADERS)
	$(CC) $(LDFLAGS) $(OBJECTS) -s $< -o $@
	cp shoco python

test_input: test_input.o $(OBJECTS) $(HEADERS)
	$(CC) $(LDFLAGS) $(OBJECTS) -s $< -o $@

$(OBJECTS): %.o: %.c $(HEADERS)
	$(CC) $(FLAGS) $< -c

shoco_model.h: $(TABLES_DIR)/words_en.h
	cp $< $@

.PHONY: models
models: $(TABLES)

$(TABLES_DIR)/text_en.h: $(TRAINING_DATA) $(GENERATOR)
	python $(GENERATOR) $(TRAINING_DATA) -o $@

$(TABLES_DIR)/words_en.h: $(TRAINING_DATA) $(GENERATOR)
	python $(GENERATOR) --split=whitespace --strip=punctuation $(TRAINING_DATA) -o $@

$(TABLES_DIR)/dictionary.h: /usr/share/dict/words $(GENERATOR)
	python $(GENERATOR) $< -o $@

# Warning: This is *slow*! Use pypy when possible
$(TABLES_DIR)/filepaths.h: $(GENERATOR)
	find / -print 2>/dev/null | pypy $(GENERATOR) --optimize-encoding -o $@

.PHONY: check
check: tests

tests: tests.o $(OBJECTS) $(HEADERS)
	$(CC) $(LDFLAGS) $(OBJECTS) $< -o $@
	./tests

.PHONY: clean
clean:
	rm -f *.o shoco
	rm -f js/_shoco.js
	rm -f python/shoco

.PHONY: js
js: _shoco.js

_shoco.js: $(OBJECTS) $(HEADERS)
	emcc shoco.c -O2 -o js/_shoco.js --closure 1 -s EXPORTED_FUNCTIONS="['_shoco_compress', '_shoco_decompress']" -s 'EXTRA_EXPORTED_RUNTIME_METHODS=["ccall", "cwrap"]' -s BINARYEN_ASYNC_COMPILATION=0 -s SINGLE_FILE=1
