resource "proxmox_lxc" "lxc-test" {
    features {
        nesting = true
    }
    hostname = "terraform-new-container"
    network {
        name = "eth0"
        bridge = "vmbr0"
        ip = "dhcp"
        ip6 = "dhcp"
    }
    ostemplate = "shared:local/centos-8-default_20201210_amd64.tar.xz"
    password = "rootroot"
    pool = "local-lvm"
    target_node = "prxmox1"
    unprivileged = true
}
