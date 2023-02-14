all: 00.bootloader/bootloader.bin 01.kernel32/kernel32.bin disk.img

00.bootloader/bootloader.bin:
	@echo [+] Build Boot Loader
	make -C 00.bootloader
	@echo [+] Build complete

01.kernel32/kernel32.bin:
	@echo [+] Build 32-bit kernel
	make -C 01.kernel32
	@echo [+] Build complete

disk.img: 00.bootloader/bootloader.bin 01.kernel32/kernel32.bin
	@echo [+] Disk image build start
	cat $^ > disk.img
	@echo [+] all build complete

clean:
	make -C 00.bootloader clean
	make -C 01.kernel32 clean
	rm -f disk.img

