all: bootloader disk.img

bootloader:
	@echo [+] Build Boot Loader
	make -C 00.bootloader
	@echo [+] Build complete

disk.img:
	@echo [+] Disk image build start
	cp 00.bootloader/bootloader.bin disk.img
	@echo [+] all build complete

clean:
	make -C 00.bootloader clean
	rm -f disk.img

