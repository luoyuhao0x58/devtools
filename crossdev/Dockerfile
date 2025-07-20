FROM debian:12-slim
ARG DEBIAN_FRONTEND=noninteractive

ARG TZ=Asia/Shanghai
ARG BUILD_DIR=/build
ARG CROSSDEV_USER_ID=54321
ARG CROSSDEV_USER_NAME=crossdev
ARG CROSSDEV_USER_HOME=/home/crossdev
ARG CROSSDEV_BUILD_CONFIGS
ENV LANG=C.UTF-8

ADD ./build ${BUILD_DIR}

RUN cd ${BUILD_DIR} && ${BUILD_DIR}/init.sh
RUN cd ${BUILD_DIR} && ${BUILD_DIR}/main.sh && apt-get clean && rm -rf /var/lib/apt/lists/* ${BUILD_DIR}

USER ${CROSSDEV_USER_ID}
WORKDIR ${CROSSDEV_USER_HOME}
ENTRYPOINT [ "./.entrypoint.sh" ]
