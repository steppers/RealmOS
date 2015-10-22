echo "Assembling bootloaders..."
nasm -f bin boot/src/bootV2.asm -o boot/build/boot1.bin
#nasm -f bin boot/src/bootStage1.asm -o boot/build/boot1.bin
nasm -f bin boot/src/bootStage2.asm -o boot/build/boot2.bin

echo "Creating disk image..."
dd if=/dev/zero of=dist/RealmOS.img bs=1MB count=64
mkfs -t msdos -F 32 dist/RealmOS.img

dd conv=notrunc if=boot/build/boot1.bin of=dist/RealmOS.img bs=1 seek=90 count=422

mount dist/RealmOS.img mnt/
head /dev/urandom > mnt/test.sht
head /dev/urandom > mnt/test2.sht
head /dev/urandom > mnt/test3.sht
head /dev/urandom > mnt/test4.sht
head /dev/urandom > mnt/test5.sht
head /dev/urandom > mnt/test6.sht
head /dev/urandom > mnt/test7.sht
head /dev/urandom > mnt/test8.sht
head /dev/urandom > mnt/test9.sht
head /dev/urandom > mnt/test10.sht
head /dev/urandom > mnt/test11.sht
head /dev/urandom > mnt/test12.sht
head /dev/urandom > mnt/test13.sht
head /dev/urandom > mnt/test14.sht
head /dev/urandom > mnt/test15.sht
head /dev/urandom > mnt/test16.sht
head /dev/urandom > mnt/test17.sht
head /dev/urandom > mnt/test18.sht
head /dev/urandom > mnt/test19.sht
head /dev/urandom > mnt/test20.sht
head /dev/urandom > mnt/test21.sht
head /dev/urandom > mnt/test22.sht
head /dev/urandom > mnt/test23.sht
head /dev/urandom > mnt/test24.sht
head /dev/urandom > mnt/test25.sht
head /dev/urandom > mnt/test26.sht
cp boot/build/boot2.bin mnt/boot.img
umount mnt/
