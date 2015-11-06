;; This is an operating system configuration template
;; for a "bare bones" setup, with no X11 display server.

(use-modules
 (gnu)
 (gnu packages linux)
 (gnu system linux-initrd))
(use-service-modules networking ssh xorg)
(use-package-modules admin suckless)

(operating-system
  (host-name "eiz-guix")
  (timezone "America/New_York")
  (locale "en_US.UTF-8")
  (kernel-arguments
   '("modprobe.blacklist=nouveau"
     "intel_iommu=on"))

  ;; Assuming /dev/sdX is the target hard disk, and "root" is
  ;; the label of the target root file system.
  (bootloader
   (grub-configuration
    (device "/dev/sda")))

  (initrd (lambda (file-systems . rest)
	    (apply base-initrd file-systems
		   #:extra-modules '("vfio-pci" "vfio_iommu_type1")
		   rest)))
  
  (file-systems (cons (file-system
                        (device "/dev/sda1")
                        (mount-point "/")
                        (type "ext4"))
                      %base-file-systems))

  ;; This is where user accounts are specified.  The "root"
  ;; account is implicit, and is initially created with the
  ;; empty password.
  (users (cons (user-account
                (name "eiz")
                (comment "One True God")
                (group "users")

                ;; Adding the account to the "wheel" group
                ;; makes it a sudoer.  Adding it to "audio"
                ;; and "video" allows the user to play sound
                ;; and access the webcam.
                (supplementary-groups '("wheel"
                                        "audio" "video"))
                (home-directory "/home/eiz"))
               %base-user-accounts))

  ;; Globally-installed packages.
  (packages (cons tcpdump %base-packages))

  ;; Add services to the baseline: a DHCP client and
  ;; an SSH server.
  (services (cons* (dhcp-client-service)
                   (lsh-service #:port-number 2222)
                   (slim-service
		    #:auto-login-session #~(string-append #$dwm "/bin/dwm"))
                   %base-services)))
