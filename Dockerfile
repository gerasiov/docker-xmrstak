ARG CUDA_VER=9.1
ARG MINER_VER=2.7.1

FROM nvidia/cuda:${CUDA_VER}-devel as build
ARG MINER_VER
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update&&apt-get install -qq --no-install-recommends -y build-essential cmake libhwloc-dev libmicrohttpd-dev libssl-dev git
RUN git clone https://github.com/fireice-uk/xmr-stak.git \
	&& cd xmr-stak \
	&& git checkout ${MINER_VER} \
	&& cmake . -DXMR-STAK_COMPILE=generic -DOpenCL_ENABLE=OFF -DCMAKE_LINK_STATIC=ON \
	&& make

FROM nvidia/cuda:${CUDA_VER}-base
RUN apt-get update&&apt-get install -qq --no-install-recommends libmicrohttpd10 libhwloc5&&rm -rf /var/lib/apt/lists/*
LABEL maintainer="Alexander Gerasiov"
COPY --from=build /xmr-stak/bin/xmr-stak /xmr-stak/bin/libxmrstak_cuda_backend.so /
ENTRYPOINT ["/bin/xmr-stak"]
