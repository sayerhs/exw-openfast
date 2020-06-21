FROM exawind/exw-dev-deps as base

RUN (\
    git clone --depth 1 -b dev https://github.com/openfast/openfast.git \
    && cd openfast \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/opt/exawind -DBUILD_SHARED_LIBS=ON -DUSE_DLL_INTERFACE=ON -DFPE_TRAP_ENABLED=ON -DBUILD_OPENFAST_CPP_API=ON .. \
    && make -j$(nproc) \
    && make install \
    && cd ../.. \
    && rm -rf openfast \
    && cd /opt/exawind/lib \
    && ls lib*so* | xargs strip -s \
    && echo "/opt/exawind/lib" > /etc/ld.so.conf.d/exawind.conf \
    && ldconfig \
    )

FROM exawind/exw-osrun as runner

COPY --from=base /usr/local /usr/local
COPY --from=base /opt/exawind /opt/exawind

RUN (\
    echo "/opt/exawind/lib" > /etc/ld.so.conf.d/exawind.conf \
    && ldconfig \
    )

WORKDIR /run
ENV PATH=/opt/exawind/bin:${PATH}
