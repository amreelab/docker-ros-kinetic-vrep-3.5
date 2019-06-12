FROM ros:kinetic-robot

LABEL Description="Customized ROS-Kinetic-Robot for VREP Simulator 3.5.0 in Ubuntu 16.04" Version="1.0"

# Arguments
ARG user=amreelab
ARG uid=1000
ARG shell=/bin/bash
ARG vrep_ws="/home/${user}"

# 
# Leave as empty string "" if you don't want any nvidia drivers to be installed.
# Otherwise, manually set the link to download the NVidia driver model for your system,
# in Linux x86_x64 version.
# This link can be found here:
#
# https://www.nvidia.com/Download/index.aspx?lang=en-us
#
# Example: for a GeForce RTX 2080 Ti running under a Windows x64, the Linux x86_64 version is:
# nvidia_driver_link=
# "http://us.download.nvidia.com/XFree86/Linux-x86_64/410.66/NVIDIA-Linux-x86_64-410.66.run"
#
# ARG nvidia_driver_link="http://uk.download.nvidia.com/XFree86/Linux-x86_64/430.26/NVIDIA-Linux-x86_64-430.26.run"
ARG nvidia_driver_link=""
						  

#
# ========================== Install required and useful packages ==========================
#
RUN printf '\n\n Installing Required Packages.. \n\n'

RUN apt-get update -y && apt-get install --no-install-recommends -y \
 lsb-release apt-utils mesa-utils build-essential \
 software-properties-common locales x11-apps \
 git \
 xvfb \
 gedit gedit-plugins nano vim \
 zsh screen tree \
 sudo ssh synaptic \
 wget curl unzip htop \
 gdb valgrind \
 libcanberra-gtk* \
 python-keybinder python-notify \
 python-tempita python-lxml default-jre xsltproc \
 python-setuptools \
 python-pip\
 python3-pip\ 
 python-rosinstall \
 python-rosinstall-generator \
 python-wstool build-essential \
&& pip3 install numpy \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean


#
# ========================== Set Timezone and New User ==========================
#

## Configure timezone and locale
#RUN sudo locale-gen en_US.UTF-8  
#ENV LANG en_US.UTF-8  
#ENV LANGUAGE en_US:en  
#ENV LC_ALL en_US.UTF-8

RUN printf '\n\n Setting New User.. \n\n'

# Crete and add user
ENV USER=${user}

RUN useradd -ms ${shell} ${user} \
&& export uid=${uid} gid=${uid} \
&& echo "${user} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${user}" && \
chmod 0440 "/etc/sudoers.d/${user}"

# Switch to user
USER ${user}


#
# ========================== ROS Workspace Setup ==========================
#

RUN echo "source /opt/ros/kinetic/setup.bash" >> $HOME/.bashrc


#
# ========================== Download and Install V-REP  ==========================
#

RUN printf '\n\n Fechting and Installing V-REP.. \n\n'

##Installation VREP 3.5: Download V-REP from link (may be outdated) and then Install
RUN wget -P ${vrep_ws} http://coppeliarobotics.com/files/V-REP_PRO_EDU_V3_5_0_Linux.tar.gz \
&& tar -C ${vrep_ws} -xvzf ${vrep_ws}/V-REP_PRO_EDU_V3_5_0_Linux.tar.gz \
&& sudo apt-get update -y && sudo apt-get install --no-install-recommends -y \
libgl1-mesa-dev libavcodec-dev libavformat-dev libswscale-dev libopencv*

##Installation VREP 3.6.1: Download V-REP from link (may be outdated) and then Install
# RUN wget -P ${vrep_ws} http://coppeliarobotics.com/files/V-REP_PRO_EDU_V3_6_1_Ubuntu16_04.tar.xz \
# && tar -C ${vrep_ws} -xf ${vrep_ws}/V-REP_PRO_EDU_V3_6_1_Ubuntu16_04.tar.xz -v

#
# ========================== Install NVidia Driver, if desired ==========================
#

RUN if [ "$nvidia_driver_link" != "" ]; then \
	printf '\n\n Installing Nvidia Driver, as requested.. \n\n' \	
	&& export nvidia_driver=$(echo $nvidia_driver_link | rev | cut -d'/' -f 1 | rev) \
	#Install required packages..
	&& sudo apt-get update -y && sudo apt-get install --no-install-recommends -y mesa-utils binutils kmod \
	#Download NVidia chosen driver
	&& wget -P /tmp/ ${nvidia_driver_link} \
	#Install the driver previously downloaded
        && chmod +x /tmp/${nvidia_driver} \
	&& sudo sh /tmp/${nvidia_driver} -a --ui=none --no-kernel-module \
	&& rm /tmp/${nvidia_driver} \
;fi
#
# ========================== Final Installations ==========================
#

RUN printf '\n\n Runnning Final Update.. \n\n'

# Run a final update-upgrade routines
RUN sudo apt-get update -y \
&& sudo apt-get dist-upgrade -y


#
# ========================== Final environment configs ==========================
#

# Reset APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE to default value
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=0

# Create a mount point to bind host data to
# to check where the volume is mounted in the host machine:
# "docker inspect -f "{{json .Mounts}}" vol-test | jq ."
VOLUME /external

# Make SSH available
EXPOSE 22

# This is required for sharing Xauthority
ENV QT_X11_NO_MITSHM=1

# Set the starting working directory.
WORKDIR /

# Set the image to start opening a new bash terminal
ENTRYPOINT ["/bin/bash"]
