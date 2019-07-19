pwd = $(shell pwd)
build = $(pwd)/build/$(OS)_$(ARCH)
dist = $(pwd)/dist/$(OS)_$(ARCH)

ifeq ("${ARCH}", "386")
archflags = -m32
endif

ifeq ("${OS}", "linux")
goLDFlags = -ldflags "-linkmode external -extldflags -static"
endif

clean-bzip2:
	rm -rf $(build)/bzip2
build-bzip2: clean-bzip2
	mkdir -p $(build)/bzip2
	-cd src/$(FTB_BZIP2) && make clean
	cd src/$(FTB_BZIP2) \
		&& make CFLAGS="$(archflags) -fPIC" \
		&& make install PREFIX=$(build)/bzip2

clean-zlib:
	rm -rf $(build)/zlib
build-zlib: clean-zlib
	mkdir -p $(build)/zlib
	-cd src/$(FTB_ZLIB) && make clean
	cd src/$(FTB_ZLIB) \
		&& CFLAGS="$(archflags) -fPIC" ./configure --prefix=$(build)/zlib --static \
		&& make \
		&& make install

clean-libpng:
	rm -rf $(build)/libpng
build-libpng: clean-libpng build-zlib
	mkdir -p $(build)/libpng
	-cd src/$(FTB_LIBPNG) && make clean
	cd src/$(FTB_LIBPNG) \
		&& LDFLAGS="-L$(build)/zlib/lib" CFLAGS="$(archflags) -fPIC" CPPFLAGS="-I $(build)/zlib/include $(archflags) -fPIC" ./configure \
			--prefix=$(build)/libpng \
			--enable-static \
			--disable-shared \
			--with-zlib-prefix=$(build)/zlib \
		&& LD_LIBRARY_PATH=$(build)/zlib/lib CFLAGS="$(archflags) -fPIC" CPPFLAGS="$(archflags) -fPIC" make \
		&& make install

clean-freetype:
	rm -rf $(build)/freetype
build-freetype: clean-freetype build-libpng build-zlib build-bzip2
	mkdir -p $(build)/freetype
	-cd src/$(FTB_FREETYPE) && make clean
	cd src/$(FTB_FREETYPE) \
		&& PKG_CONFIG_LIBDIR=$(build)/zlib/lib/pkgconfig:$(build)/libpng/lib/pkgconfig CFLAGS="$(archflags) -fPIC -I$(build)/bzip2/include" LDFLAGS="-L$(build)/bzip2/lib" ./configure \
			--prefix=$(build)/freetype \
			--enable-static \
			--disable-shared \
			--with-zlib \
			--with-png \
			--with-bzip2 \
			--without-harfbuzz \
		&& LD_LIBRARY_PATH=$(build)/zlib/lib:$(build)/libpng/lib:$(build)/bzip2/lib make \
		&& make install

clean-harfbuzz:
	rm -rf $(build)/harfbuzz
build-harfbuzz: clean-harfbuzz build-libpng build-zlib build-freetype
	mkdir -p $(build)/harfbuzz
	-cd src/$(FTB_HARFBUZZ) && make clean
	cd src/$(FTB_HARFBUZZ) \
		&& autoreconf --force --install \
		&& PKG_CONFIG_LIBDIR=$(build)/zlib/lib/pkgconfig:$(build)/libpng/lib/pkgconfig:$(build)/freetype/lib/pkgconfig CFLAGS="$(archflags) -fPIC" CXXFLAGS="$(archflags) -fPIC" ./configure \
			--prefix=$(build)/harfbuzz \
			--enable-static \
			--disable-shared \
			--without-glib \
			--without-gobject \
			--without-cairo \
			--without-fontconfig \
			--without-icu \
			--without-graphite2 \
			--with-freetype \
			--without-uniscribe \
			--without-directwrite \
			--without-coretext \
		&& CFLAGS="$(archflags) -fPIC" CXXFLAGS="$(archflags) -fPIC" LD_LIBRARY_PATH=$(build)/zlib/lib:$(build)/libpng/lib:$(build)/freetype/lib make \
		&& make install

clean-freetypehb:
	rm -rf $(build)/freetypehb
build-freetypehb: clean-freetypehb build-libpng build-zlib build-bzip2 build-harfbuzz
	mkdir -p $(build)/freetypehb
	-cd src/$(FTB_FREETYPE) && make clean
	cd src/$(FTB_FREETYPE) \
		&& PKG_CONFIG_LIBDIR=$(build)/zlib/lib/pkgconfig:$(build)/libpng/lib/pkgconfig:$(build)/harfbuzz/lib/pkgconfig CFLAGS="$(archflags) -fPIC -I$(build)/bzip2/include" LDFLAGS="-L$(build)/bzip2/lib" ./configure \
			--prefix=$(build)/freetypehb \
			--enable-static \
			--disable-shared \
			--with-zlib \
			--with-png \
			--with-bzip2 \
			--with-harfbuzz \
		&& LD_LIBRARY_PATH=$(build)/zlib/lib:$(build)/libpng/lib:$(build)/bzip2/lib:$(build)/harfbuzz/lib make \
		&& make install

build: build-freetype build-freetypehb

clean-dist:
	rm -rf $(dist)
dist: build clean-dist
	mkdir -p $(dist)/lib
	mv $(build)/freetypehb/lib/libfreetype.a $(build)/freetypehb/lib/libfreetypehb.a
	mv $(build)/freetypehb/lib/libfreetype.la $(build)/freetypehb/lib/libfreetypehb.la
	cp -r $(build)/freetype/include $(dist)
	cp $(build)/bzip2/lib/libbz2.a $(dist)/lib
	cp $(build)/freetype/lib/libfreetype.a $(dist)/lib
	cp $(build)/freetype/lib/libfreetype.la $(dist)/lib
	cp $(build)/freetypehb/lib/libfreetypehb.a $(dist)/lib
	cp $(build)/freetypehb/lib/libfreetypehb.la $(dist)/lib
	cp $(build)/harfbuzz/lib/libharfbuzz.a $(dist)/lib
	cp $(build)/harfbuzz/lib/libharfbuzz.la $(dist)/lib
	cp $(build)/harfbuzz/lib/libharfbuzz-subset.a $(dist)/lib
	cp $(build)/harfbuzz/lib/libharfbuzz-subset.la $(dist)/lib
	cp $(build)/libpng/lib/libpng16.a $(dist)/lib
	cp $(build)/libpng/lib/libpng16.la $(dist)/lib
	cp $(build)/zlib/lib/libz.a $(dist)/lib
	cd $(dist) && zip -r $(HOME)/$(OS)_$(ARCH).zip .

test-ft:
	CGO_ENABLED=1 GOOS=$(OS) GOARCH=$(ARCH) go build -tags 'static' $(goLDFlags) -o static test.go
	./static $(FTB_VERSION)
test-ft-hb:
	CGO_ENABLED=1 GOOS=$(OS) GOARCH=$(ARCH) go build -tags 'static harfbuzz' $(goLDFlags) -o statichb test.go
	./statichb $(FTB_VERSION)
test-ft-hb-subset:
	CGO_ENABLED=1 GOOS=$(OS) GOARCH=$(ARCH) go build -tags 'static harfbuzz subset' $(goLDFlags) -o statichb-subset test.go
	./statichb-subset $(FTB_VERSION)

test: test-ft test-ft-hb test-ft-hb-subset