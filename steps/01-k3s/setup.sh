sudo cp k3sconfig.yaml /etc/rancher/k3s/config.yaml
curl -sfL https://get.k3s.io | sh -

# In the event of issues:
# sudo rm -r /var/lib/rancher/k3s/