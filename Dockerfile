FROM fedora:34

LABEL maintainer="Wu Assassin <jambang.pisang@gmail.com>"
LABEL org.opencontainers.image.source=https://github.com/pinteraktif/infra-dlcv

### Arguments & Environments

ARG CUDA_ARCH

ENV LC_ALL="C.UTF-8"
ENV CUDA_HOME="/usr/local/cuda"
ENV CUDA_CACHE_DISABLE="1"
ENV PYTHONIOENCODING="utf-8"
ENV JUPYTER_PORT="8888"
ENV LD_LIBRARY_PATH="/usr/local/cuda/compat/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH}"
ENV PATH="/root/.cargo/bin${PATH:+:}${PATH}"
ENV PATH="/usr/local/nvidia/bin:${PATH}"
ENV PATH="/usr/local/cuda/bin:${PATH}"

### Install system packages

RUN dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-34.noarch.rpm && \
    dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-34.noarch.rpm && \
    dnf upgrade -y && \
    dnf install -y \
    aria2 \
    atlas-devel \
    atlas-static \
    autoconf \
    automake \
    bash-completion \
    bpytop \
    byobu \
    bzip2 \
    ceres-solver-devel \
    clang \
    clang-devel \
    clang-libs \
    clang-resource-filesystem \
    clang-tools-extra \
    cmake \
    compiler-rt \
    cpufetch \
    cyrus-sasl-devel \
    docker-compose \
    dotnet \
    doxygen \
    eigen3-devel \
    elfutils-devel \
    faac-devel \
    fdk-aac-devel \
    ffmpeg-devel \
    freeimage-devel \
    g++ \
    gcc \
    gdal-devel \
    gflags-devel \
    giflib-devel \
    git \
    git-clang-format \
    glog-devel \
    gnutls-devel \
    gpgme-devel \
    gstreamer1-devel \
    gstreamer1-libav \
    gstreamer1-plugin* \
    gstreamer1-rtsp* \
    gstreamer1-svt-av1 \
    gstreamer1-svt-vp9 \
    gstreamer1-vaapi \
    gstreamer1-vaapi-devel \
    gtk3-devel \
    gtkglext-devel \
    hdf5-devel \
    hdf5-static \
    htop \
    jack-audio-connection-kit-devel \
    lame-devel \
    lapack \
    lapack-devel \
    lapack-static \
    lapack64 \
    libaom-devel \
    libass-devel \
    libavc1394-devel \
    libclc-devel \
    libdav1d-devel \
    libdc1394-devel \
    libdrm-devel \
    libgeotiff-devel \
    libglvnd-devel \
    libgpg-error-devel \
    libgphoto2-devel \
    liblas-devel \
    libomp \
    libpng-devel \
    libpng12-devel \
    libraw1394-devel \
    librsvg2-devel \
    libsass-devel \
    libsodium-devel \
    libssh2-devel \
    libtheora-devel \
    libtiff-devel \
    libtool \
    libunistring-devel \
    libv4l-devel \
    libva-devel \
    libvdpau-devel \
    libvorbis-devel \
    libvpx-devel \
    libwebp-devel \
    libzstd-devel \
    libzstd-devel \
    libzstd-static \
    lld \
    llvm-devel \
    llvm-libs \
    llvm-static \
    lshw \
    make \
    mesa-libEGL-devel \
    meson \
    mono-devel \
    musl-clang \
    musl-devel \
    musl-filesystem \
    musl-gcc \
    musl-libc \
    musl-libc-static \
    mycli \
    nasm \
    ncdu \
    ninja-build \
    nodejs \
    numactl-devel \
    nv-codec-headers \
    openblas-devel \
    openblas-openmp \
    openblas-static \
    openblas-threads \
    opencore-amr-devel \
    openjpeg-devel \
    openjpeg2-devel \
    openmpi \
    openssl-devel \
    opus-devel \
    p7zip \
    p7zip-plugins \
    PackageKit-command-not-found \
    pciutils \
    perl-FindBin \
    pinentry \
    polly-devel \
    protobuf-devel \
    psutils \
    pylint \
    python3-beautifulsoup4 \
    python3-black \
    python3-clang \
    python3-devel \
    python3-flake8 \
    python3-numpy \
    python3-pip \
    python3-setuptools \
    python3-virtualenv \
    python3-wheel \
    SDL2-devel \
    svt-av1-devel \
    tar \
    tbb-devel \
    tesseract-devel \
    texinfo \
    unzip \
    v4l-utils \
    vid.stab-devel \
    vim \
    wget \
    x264 \
    x264-devel \
    x265-devel \
    xine-lib-devel \
    xvidcore-devel \
    yasm \
    zlib-static

### Rust 1.55.0

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y && \
    rustup toolchain add nightly && \
    rustup default 1.55.0 && \
    rustup target add x86_64-unknown-linux-musl && \
    rustup update

### Nvidia Computer Vision suites

WORKDIR /app/downloads

RUN mkdir temp

RUN --mount=type=secret,id=tapapass \
    aria2c -x 16 -s 16 \
    --force-sequential \
    --http-user="pinteraktif" \
    --http-passwd=$(cat /run/secrets/tapapass) \
    https://share.tapalogi.com/nvidia/cuda_11.4.2_470.57.02_linux.run \
    https://share.tapalogi.com/nvidia/libcudnn8-8.2.4.15-1.cuda11.4.x86_64.rpm \
    https://share.tapalogi.com/nvidia/libcudnn8-devel-8.2.4.15-1.cuda11.4.x86_64.rpm \
    https://share.tapalogi.com/nvidia/nv-tensorrt-repo-rhel8-cuda11.4-trt8.2.0.6-ea-20210922-1-1.x86_64.rpm \
    https://share.tapalogi.com/nvidia/nvhpc-2021-21.9-1.x86_64.rpm \
    https://share.tapalogi.com/nvidia/nvhpc-21-9-21.9-1.x86_64.rpm \
    https://share.tapalogi.com/nvidia/NVIDIA-Linux-x86_64-470.57.02.run

RUN chmod +x NVIDIA-Linux-x86_64-470.57.02.run && \
    ./NVIDIA-Linux-x86_64-470.57.02.run \
    --accept-license \
    --force-libglx-indirect \
    --install-libglvnd \
    --no-backup \
    --no-drm \
    --no-kernel-module \
    --no-kernel-module-source \
    --no-nouveau-check \
    --no-nvidia-modprobe \
    --no-questions \
    --no-systemd \
    --no-wine-files \
    --no-x-check \
    --skip-module-unload \
    --tmpdir="/app/downloads/temp" \
    --ui="none" && \
    ldconfig

RUN chmod +x cuda_11.4.2_470.57.02_linux.run && \
    ./cuda_11.4.2_470.57.02_linux.run \
    --no-drm \
    --no-man-page \
    --silent \
    --tmpdir="/app/downloads/temp" \
    --toolkit && \
    ldconfig

RUN dnf install -y \
    ./libcudnn8-8.2.4.15-1.cuda11.4.x86_64.rpm \
    ./libcudnn8-devel-8.2.4.15-1.cuda11.4.x86_64.rpm \
    ./nv-tensorrt-repo-rhel8-cuda11.4-trt8.2.0.6-ea-20210922-1-1.x86_64.rpm \
    ./nvhpc-2021-21.9-1.x86_64.rpm \
    ./nvhpc-21-9-21.9-1.x86_64.rpm

### Source Codes

ENV NVCCPARAMS="-O3 -gencode arch=compute_${CUDA_ARCH},code=sm_${CUDA_ARCH}"

WORKDIR /app/source

RUN git clone --recursive --depth 1 --branch 4.5.3 https://github.com/opencv/opencv.git && \
    git clone --recursive --depth 1 --branch 4.5.3 https://github.com/opencv/opencv_contrib.git && \
    git clone --recursive --depth 1 --branch n4.4 https://github.com/FFmpeg/FFmpeg.git && \
    git clone --recursive --depth 1 --branch n11.1.5.0 https://github.com/FFmpeg/nv-codec-headers.git && \
    git clone --recursive --depth 1 --branch 0.9.2 https://github.com/videolan/dav1d.git && \
    git clone --recursive --depth 1 --branch v0.8.7 https://gitlab.com/AOMediaCodec/SVT-AV1.git

### FFmpeg & friends

RUN cd dav1d && \
    mkdir build && \
    cd build && \
    meson setup \
    -D enable_tools="false" \
    -D enable_test="false" \
    .. && \
    ninja && \
    ninja install && \
    ldconfig

RUN cd SVT-AV1 && \
    mkdir build && \
    cd build && \
    cmake -G "Unix Makefiles" \
    -D CMAKE_BUILD_TYPE="Release" \
    -D BUILD_DEC="ON" \
    -D BUILD_SHARED_LIBS="ON" .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig

RUN cd nv-codec-headers && \
    make install && \
    ldconfig

RUN cd FFmpeg && \
    ./configure \
    --disable-debug \
    --enable-cuda-nvcc \
    --enable-gpl \
    --enable-hardcoded-tables \
    --enable-libaom \
    --enable-libass \
    --enable-libdav1d \
    --enable-libdrm \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libnpp \
    --enable-libopus \
    --enable-libsvtav1 \
    --enable-libvidstab \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxvid \
    --enable-nonfree \
    --enable-nvenc \
    --enable-opengl \
    --enable-openssl \
    --enable-vaapi \
    --enable-shared \
    --extra-cflags="-I/usr/local/cuda/include" \
    --extra-ldflags="-L/usr/local/cuda/lib64" \
    --extra-libs="-lpthread -lm" \
    --nvccflags="${NVCCPARAMS}" && \
    make -j$(nproc) && \
    make install && \
    ldconfig

### OpenCV & friends

RUN cd opencv && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE="Release" \
    -D BUILD_DOCS="ON" \
    -D BUILD_EXAMPLES="OFF" \
    -D BUILD_NEW_PYTHON_SUPPORT="ON" \
    -D BUILD_opencv_cudacodec="ON" \
    -D BUILD_opencv_python2="OFF" \
    -D BUILD_opencv_python3="ON" \
    -D BUILD_opencv_world="ON" \
    -D BUILD_SHARED_LIBS="ON" \
    -D CPU_BASELINE="SSE,SSE2,SSE3,SSSE3,SSE4_1,POPCNT,SSE4_2,AVX,AVX2,FP16" \
    -D CPU_DISPATCH="SSE,SSE2,SSE3,SSSE3,SSE4_1,POPCNT,SSE4_2,AVX,AVX2,FP16" \
    -D CUDA_ARCH_BIN="${CUDA_ARCH}" \
    -D CUDA_ARCH_PTX="${CUDA_ARCH}" \
    -D CUDA_FAST_MATH="ON" \
    -D ENABLE_CCACHE="ON" \
    -D ENABLE_FAST_MATH="ON" \
    -D ENABLE_FLAKE8="ON" \
    -D ENABLE_PYLINT="ON" \
    -D HAVE_opencv_python3="ON" \
    -D INSTALL_C_EXAMPLES="OFF" \
    -D INSTALL_PYTHON_EXAMPLES="OFF" \
    -D OPENCV_DNN_CUDA="ON" \
    -D OPENCV_DNN_OPENCL="ON" \
    -D OPENCV_ENABLE_NONFREE="ON" \
    -D OPENCV_EXTRA_MODULES_PATH="../../opencv_contrib/modules" \
    -D OPENCV_GENERATE_PKGCONFIG="ON" \
    -D PARALLEL_ENABLE_PLUGINS="ON" \
    -D WITH_CUBLAS="ON" \
    -D WITH_CUDA="ON" \
    -D WITH_CUDNN="ON" \
    -D WITH_CUFFT="ON" \
    -D WITH_FFMPEG="ON" \
    -D WITH_GDAL="ON" \
    -D WITH_GSTREAMER="ON" \
    -D WITH_GTK="ON" \
    -D WITH_ITT="OFF" \
    -D WITH_NVCUVID="ON" \
    -D WITH_OPENGL="ON" \
    -D WITH_QT="OFF" \
    -D WITH_TBB="ON" \
    -D WITH_V4L="ON" \
    .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig

RUN echo "/usr/local/lib64" > /etc/ld.so.conf.d/local.conf && \
    ldconfig

### Cleanup

RUN rm -rf /app && \
    dnf clean all

### Jupyter Notebook

WORKDIR /workspace

EXPOSE 8888

RUN pip3 install jupyterlab

### Print Info

RUN echo "** Clang **" && clang -v && echo "" && \
    echo "** GCC **" && gcc -v && echo "" && \
    echo "** Python **" && python3 --version && echo "" && \
    echo "** Rust **" && rustc -vV && echo "" && \
    echo "** OpenCV **" && python3 -c "import cv2; print(cv2.getBuildInformation())" && echo "" && \
    echo "** FFmpeg **" && ffmpeg -version && echo "" && \
    echo "** Environments **" && env && echo ""
