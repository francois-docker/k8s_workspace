Docker - k8s_calamari
==============
Currently in early stage "dev" - not even usable for now
This container runs the cepph-calamari gui to manage a ceph cluster

Requirements
------------
TODO

Environment variables
----------
#### Mandatory environment variables

#### Optional environment variables

Usage
-----
#### Docker
Build as usual

```
cd k8s_workspace
docker build -t francois/k8s_cluster .
```

Run the container with necessary links

```
docker run --name somename -P francois/k8s_workspace
```

Then, get the ipaddress of the container :

```
docker inspect somename | grep -i ipaddress
```

And finally connect to the ip address provided by the previous command

```
ssh root@$IPADDRESS
```

TODO: change the static hardcoded password (config.sh) to a configurable environment variable
Currently the default password is 'neutre'

#### Kubernetes
Use the yaml files available at : https://github.com/francois-k8s/kube_apps
For the pod : https://github.com/francois-k8s/kube_apps/blob/master/workspace-pod.yaml
For the ssh service : https://github.com/francois-k8s/kube_apps/blob/master/workspace-ssh-service.yaml

```
git clone https://github.com/francois-k8s/kube_apps

kubecfg -c kube_apps/workspace-pod.yaml create pods

kubecfg -c kube_apps/workspace-ssh-service.yaml create services
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Submit a Pull Request using Github

License and Authors
-------------------
Authors: François Billant <fbillant@gmail.com>
