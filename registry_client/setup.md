
# Docker client
```
/etc/docker/daemon.json
{
  "storage-driver": "overlay2",
  "insecure-registries" : ["192.168.100.79:8082"]
}

sudo systemctl restart docker
```

# Podman client
```
/etc/containers/registries.conf
[registries.insecure]
registries = ['192.168.100.79:8082']

```

# 
`docker login 192.168.100.79:8082`