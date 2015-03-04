all:
	@echo "updating lmdb submodule"
	git submodule update --init

	@echo
	@echo "building lmdb library"
	make -C ./mdb/libraries/liblmdb 2>&1 > /dev/null

	@echo
	@echo "moving lmdb into place"
	mv ./mdb/libraries/liblmdb/liblmdb.so ./liblmdb.so

test:
	mkdir -p ./tests/fixtures
	luajit ./tests/run.lua