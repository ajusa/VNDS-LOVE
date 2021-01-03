FROM debian:bullseye-slim
COPY devkitpro-pacman.amd64.deb /
RUN apt-get update && \
	apt-get install -y --no-install-recommends apt-utils && \
	apt-get install -y --no-install-recommends sudo ca-certificates pkg-config curl wget bzip2 xz-utils make git libarchive-tools doxygen gnupg && \
	apt-get install -y --no-install-recommends gdebi-core && \
	apt-get install -y --no-install-recommends cmake 

RUN gdebi -n devkitpro-pacman.amd64.deb && \
		rm devkitpro-pacman.amd64.deb && \
		dkp-pacman -Scc --noconfirm

ENV DEVKITPRO=/opt/devkitpro
ENV PATH=${DEVKITPRO}/tools/bin:$PATH
ENV DEVKITARM=/opt/devkitpro/devkitARM
RUN dkp-pacman -Syyu --noconfirm switch-dev 3ds-dev devkit-env
RUN apt-get install -y nodejs zip
RUN apt-get install -y python3-pip
RUN pip install lovebrew
RUN apt-get install -y lua5.3 liblua5.3-dev
RUN wget https://luarocks.org/releases/luarocks-3.5.0.tar.gz && \
	tar zxpf luarocks-3.5.0.tar.gz && \
	cd luarocks-3.5.0 && \
	./configure && make && make install && \
	cd ..

RUN apt-get install -y libzip-dev
RUN luarocks install moonscript && \
	luarocks install busted && \
	luarocks install alfons && \
	luarocks install love-release

