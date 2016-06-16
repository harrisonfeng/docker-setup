# Docker Setup

This project is used to setup your docker runtime environment. It includes
two utilities inside:

    docker_setup.sh: install docker
    nsdocker: a script which wraps nsenter enable you to start a shell and run command inside container
    
## How to use it

```bash
git clone https://github.com/harrisonfeng/docker-setup.git
cd docker-setup
./docker_setup.sh 1.11.1
```

