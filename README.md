# docker-ros-kinetic-vrep-3.5
Run a docker container with Ubuntu 16.04, ROS Kinetic and V-REP 3.5.

If you are not familiar with Docker, this is useful with you are in a host machine with a different stack than Ubuntu 16.04 and wants to run V-REP 5.0 with ROS Kinetic in a very easy and fast way without having to change your machine configuration or operating system at all. You will run a docker container on top of your operating system kernel, that's all. You do not even need ROS or V-REP installed in your host machine.

## Getting started with Docker

If you are not familiar with Docker, it's recommended you [try it out](https://www.docker.com/tryit/) with the online tutorial. 

Before running this Dockerfile, you will have to complete install Docker as described in [Docker's installation instructions](https://docs.docker.com/installation/). Installation instructions are available for multiple operation systems including Ubuntu, Mac OS x, Debian, Fedora and even Microsoft Windows.

## Running the docker container

Once you have Docker installed, we can run following a simple sequence of steps:

1. Clone this repository.
2. Enter the directory to where files where clone. Ex:
```
$ cd docker-ros-kinetic-vrep-3.5
```
3. Build the docker container
A. If you do not have an nvidia graphics card, run:
```
$ sudo docker build -t ros-kinetic-vrep3-5:1.0 .
```
B. If you have an nvidia graphics card, run the following command passing the driver download link. 
```
$ sudo docker build -t ros-kinetic-vrep3-5:1.0 . --build-arg nvidia_driver_link=<LINK>
```

The link can be found at [NVidia website](https://www.nvidia.com/Download/index.aspx?lang=en-us). Remember that the link
passed should be related to the Linux version that is running inside the container. For instance, if you are running a Windows x64
system with a GeForce RTX 2080 Ti, the link for the container would be:
```
<LINK>="http://us.download.nvidia.com/XFree86/Linux-x86_64/410.66/NVIDIA-Linux-x86_64-410.66.run"
```

4. Run the command:
```
$ xhost +local:docker
```
This command will forward the X control from the host machine, so you can run V-REP with GUI.

5. Run a new container issuing the followin command:
```
$ sudo docker run -it --name ros-kinetic-vrep3-5 --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/root/.Xauthority --privileged ros-kinetic-vrep3-5:1.0
```

This will move you into an interactive session with the running container. From here, it's basically as if you're in a new bash terminal separate from your host machine. Now run the roscore command and you will see ros master startup.
```
$ roscore
```

6. In a new terminal on the host machine, find the name of your new container, last container started using: 
```
$ docker ps -l
```

Using the name of the container as the ID, we can start additional bash session in the same container by running: 
```
$ docker exec -it ros-kinetic-vrep3-5 bash
```

We can then run a ROS command such as:
```
$ rostopic list
```
and see that roscore is running and publishing both `rosout` and `rosout_agg` topics.

7. V-REP: in this same new terminal, go to V-REP directoryL
```
$ cd ~/cd V-REP_PRO_EDU_V3_5_0_Linux
```

Run V-REP:

```
./vrep.sh
```

If V-REP loads well, you should be able to test one ROS scene. Remember this V-REP is running inside the container, an instance of V-REP 5.0. 

Go to File > Open Scene > Select and Open rosInterfaceTopicPublisherAndSubscriber.ttt. Run the scene. 

EXPECTED RESULT: A camera node trasmitting to a subscriber node, which is also a camera.

## Stopping the docker container

To stop containers, we merely need to stop the original processes run by docker run command. We can switch back to the terminal where roscore is running and hit ctrl-c to stop the ROS process, and then exit to terminate the bash shell. You can also use the docker CLI to tell the docker daemon to stop or remove the running container directly. Check the [stop](https://docs.docker.com/reference/commandline/stop/) and [rm](https://docs.docker.com/reference/commandline/rm/) docs here for details. 
