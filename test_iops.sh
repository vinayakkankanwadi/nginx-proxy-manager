sudo apt-get install fio -y
sudo fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=/mnt/docker/test --bs=4k --iodepth=64 --size=4G --readwrite=randrw --rwmixread=75
sudo rm -rf /mnt/docker/test