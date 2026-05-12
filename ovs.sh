#/bin/bash

BR=tectel

ovs-vsctl add-br $BR

ovs-vsctl show

ip link add veth101 type veth peer name veth102
ip netns add testns1
ip link set veth102 netns testns1
ip netns exec testns1 ip addr add 10.0.0.11/24 dev veth102
ip link set veth101 up
ip netns exec testns1 ip link set veth102 up
ip netns exec testns1 ip link set lo up

ip link add veth201 type veth peer name veth202
ip netns add testns2
ip link set veth202 netns testns2
ip netns exec testns2 ip addr add 10.0.0.12/24 dev veth202
ip link set veth201 up
ip netns exec testns2 ip link set veth202 up
ip netns exec testns2 ip link set lo up


ip link add veth301 type veth peer name veth302
ip link set veth301 up
ip netns add testns3
ip link set veth302 netns testns3
ip netns exec testns3 ip addr add 10.0.0.13/24 dev veth302
ip netns exec testns3 ip link set veth302 up
ip netns exec testns3 ip link set lo up

ovs-vsctl add-port $BR veth101 tag=100
ovs-vsctl add-port $BR veth201 tag=100
ovs-vsctl add-port $BR veth301 tag=200

ovs-vsctl add-port $BR int-vlan100 -- set Interface int-vlan100 type=internal
ovs-vsctl set port int-vlan100 tag=100

ip link set int-vlan100 up
ip addr add 10.0.0.1/24 dev int-vlan100
ping -c3 10.0.0.1

ip netns exec testns1 ping -c 3 10.0.0.11
ip netns exec testns1 ping -c 3 10.0.0.12
ip netns exec testns1 ping -c 3 10.0.0.13

ip link show | grep veth
ip link show int-vlan100
cat /etc/sysconfig/network-scripts/ifcfg-br0

## CLEANUP

#!/bin/bash

BR=tectel

if ovs-vsctl show | grep -q "$BR"; then
    echo "Deleting OVS bridge $BR..."
    ovs-vsctl del-br $BR
else
    echo "OVS bridge $BR not found. Skipping deletion."
fi

for ns in testns1 testns2 testns3; do
    if ip netns show | grep -q "$ns"; then
        echo "Deleting network namespace $ns..."
        ip netns delete $ns
    else
        echo "Network namespace $ns not found. Skipping deletion."
    fi
done


for link in veth101 veth102 veth201 veth202 veth301 veth302; do
    if ip link show $link 2>/dev/null; then
        echo "Deleting lingering link $link..."
        ip link delete $link
    fi
done

echo "--- Cleanup complete! ---"

docker run -it -d --name ovs-lab-ubuntu --privileged --cap-add=ALL ubuntu:26.04 /bin/bash
docker run -it -d --name ovs-lab-centos --privileged --network host --pid host --cap-add=ALL quay.io/centos/centos:stream8 /bin/bash
docker run -it -d --name ovs-lab-rocky --privileged --network host --pid host --cap-add=ALL rockylinux:9 /bin/bash