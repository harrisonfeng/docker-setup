# Docker Setup

This project is used to setup your docker runtime environment. 
It includes three utilities inside:

    docker_setup.sh: install docker in your linux box (currently support Ubuntu and CentOS)
    nsdocker: a script which wraps nsenter enable you to start a shell and run command inside container
    golang_inst.sh: install golang in your linux box
    
## How to use it

```bash
git clone https://github.com/harrisonfeng/docker-setup.git
cd docker-setup
./docker_setup.sh 1.11.1
```
