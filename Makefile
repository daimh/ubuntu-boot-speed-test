Ts != date +%s

var/test : var/base
	[ -n "$(Tag)" ]
	while fuser $<.img; do sleep 1; done
	date +%s.%3N > $@.start
	qemu-system-x86_64 -nographic -cpu host --enable-kvm -smp 1 -m 2G -drive if=virtio,file=$<.img,format=qcow2
	mkdir -p $@.m
	guestmount -ia $<.img $@.m
	echo $$(cat $@.m/home/ubuntu/epoch) - $$(cat $@.start) | bc > var/boottime-$(Tag).$(Ts)
	guestunmount $@.m
	rmdir $@.m
	echo Boot time is $$(cat var/boottime-$(Tag).$(Ts)) seconds

var/base : iso/jammy-server-cloudimg-amd64 var/user-data
	cp $<.img $@.img
	mkdir -p $@.m
	guestmount -ia $@.img $@.m
	echo '@reboot root date +\%s.\%3N > /home/ubuntu/epoch' >> $@.m/etc/crontab
	echo '@reboot root sleep 10 && w | grep ubuntu || poweroff' >> $@.m/etc/crontab
	cp -pr lib $@.m/root
	guestunmount $@.m
	while fuser $@.img; do sleep 1; done
	date +%s.%3N > $@.start
	qemu-system-x86_64 -nographic -cpu host --enable-kvm -smp 1 -m 2G -drive if=virtio,file=$@.img,format=qcow2 -drive if=virtio,file=var/user-data.img,format=raw
	guestmount -ia $@.img $@.m
	echo $$(cat $@.m/home/ubuntu/epoch) - $$(cat $@.start) | bc > var/boottime-first.$(Ts)
	guestunmount $@.m
	rmdir $@.m
	touch $@
	echo Boot time is $$(cat var/boottime-first.$(Ts)) seconds

var/user-data :
	mkdir -p $(@D)
	echo -e '#cloud-config\npassword: asdf\nchpasswd: { expire: False }' > $@.cfg
	cloud-localds $@.img $@.cfg
	touch $@

iso/jammy-server-cloudimg-amd64 :
	mkdir -p $(@D)
	wget -P $(@D) https://cloud-images.ubuntu.com/jammy/current/$(@F).img
	touch $@
