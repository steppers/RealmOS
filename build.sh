echo "Assembling bootloaders..."
nasm -f bin boot/src/stage1/boot1.asm -o boot/build/boot1.bin
nasm -f bin boot/src/stage2/boot2.asm -o boot/build/boot2.bin

echo "Creating disk image..."
dd if=/dev/zero of=dist/RealmOS.img bs=1MB count=64
mkfs -t msdos -F 32 dist/RealmOS.img

dd conv=notrunc if=boot/build/boot1.bin of=dist/RealmOS.img bs=1 seek=90 count=422

mount dist/RealmOS.img mnt/
head /dev/urandom > mnt/test1.sht
cp boot/build/boot2.bin mnt/boot.img
umount mnt/
