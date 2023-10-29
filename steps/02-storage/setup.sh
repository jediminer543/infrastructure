sudo mkdir /opt/cephstore
cd /opt/cephstore
sudo dd if=/dev/zero of=/opt/cephstore/initialdisk bs=1 count=0 seek=64G
sudo losetup /dev/loop42 /opt/cephstore/initialdisk

kubectl create -f https://raw.githubusercontent.com/rook/rook/v1.12.5/deploy/examples/crds.yaml
kubectl create -f https://raw.githubusercontent.com/rook/rook/v1.12.5/deploy/examples/common.yaml
curl -s "https://raw.githubusercontent.com/rook/rook/v1.12.5/deploy/examples/operator.yaml" | sed -e 's|ROOK_CEPH_ALLOW_LOOP_DEVICES: "false"|ROOK_CEPH_ALLOW_LOOP_DEVICES: "true"|g' | kubectl create -f -

kubectl apply -f config/ceph-cluster.yaml
kubectl apply -f config/ceph-provisioner.yaml
kubectl krew install rook-ceph
kubectl rook-ceph ceph status