all: bootloader disk.img

bootloader:
	@echo [+] Build Boot Loader
	make -C 00.bootloader
	@echo [+] Build complete

kernel32:
	@echo [+] Build 32-bit kernel
	make -C 01.kernel32
	@echo [+] Build complete

disk.img: bootloader kernel32
	@echo [+] Disk image build start
	cat 00.bootloader/bootloader.bin 01.kernel32/VirtualOS.bin > disk.img
	@echo [+] all build complete

clean:
	make -C 00.bootloader clean
	make -C 01.kernel32 clean
	rm -f disk.img

