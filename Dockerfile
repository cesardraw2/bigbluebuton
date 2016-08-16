FROM ubuntu:14.04
MAINTAINER Cesar Draw cesardraw@gmail.com
ENV DEBIAN_FRONTEND noninteractive
ENV FFMPEG_VERSION=2.3.3

RUN apt-get -y update
RUN apt-get install -y language-pack-en vim wget
RUN update-locale LANG=en_US.UTF-8
RUN dpkg-reconfigure locales

# Update server

#Add multiverse repo
#RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main restricted universe multiverse" | tee -a /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -y dist-upgrade

#Install PPA for LibreOffice 4.4 and libsslAnchor link for: install ppa for libreoffice 44 and libssl
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:libreoffice/libreoffice-4-4
RUN add-apt-repository -y ppa:ondrej/php

# Install key for BigBlueButtonAnchor link for: install key for bigbluebutton
RUN wget http://ubuntu.bigbluebutton.org/bigbluebutton.asc -O- | apt-key add -
RUN echo "deb http://ubuntu.bigbluebutton.org/trusty-1-0/ bigbluebutton-trusty main" | tee /etc/apt/sources.list.d/bigbluebutton.list
RUN apt-get update

# Install ffmpeg
RUN apt-get install -y --force-yes build-essential git-core checkinstall yasm texi2html libvorbis-dev libx11-dev libvpx-dev libxfixes-dev zlib1g-dev pkg-config netcat libncurses5-dev
RUN cd /usr/local/src
RUN if [ ! -d "/usr/local/src/ffmpeg-${FFMPEG_VERSION}" ]; then \
		wget "http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2" \
		tar -xjf "ffmpeg-${FFMPEG_VERSION}.tar.bz2" \
	fi	

RUN cd "ffmpeg-${FFMPEG_VERSION}"
RUN ./configure --enable-version3 --enable-postproc --enable-libvorbis --enable-libvpx
RUN make
RUN checkinstall --pkgname=ffmpeg --pkgversion="5:${FFMPEG_VERSION}" --backup=no --deldoc=yes --default
RUN chmod +x install-ffmpeg.sh
RUN ./install-ffmpeg.sh

# Install BigBlueButtonAnchor link for: install bigbluebutton
RUN apt-get install -y bigbluebutton

# ImageMagick security issuesAnchor link for: imagemagick security issues (ImageMagick included with Ubuntu 14.04 is vulnerable to CVE-2016-3714)
RUN rm -f /etc/ImageMagick/policy.xml
COPY policy.xml /etc/ImageMagick
RUN convert -list policy

# Install API Demos
##RUN apt-get -y install bbb-demo
# Install Client Self-Check
RUN apt-get -y install bbb-check

# Enable WebRTC audio
RUN bbb-conf --enablewebrtc

# Do a Clean Restart
RUN bbb-conf --clean
RUN bbb-conf --check

EXPOSE 80 9123 1935

#Add helper script to start bbb
ADD scripts/start.sh /usr/bin/

CMD ["/usr/bin/start.sh"]
