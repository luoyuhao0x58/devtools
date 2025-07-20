FROM debian:13-slim
ARG DEBIAN_FRONTEND=noninteractive

ARG TZ=Asia/Shanghai
ARG BUILD_DIR=/build
ARG BUILD_TMP_DIR=/build/tmp
ARG BUILD_UTILS_PATH=$BUILD_DIR/common/utils.sh
ARG BUILD_CONSTANTS_PATH=$BUILD_DIR/common/constants.cfg
ARG DEVCONTAINER_USER_ID=54321
ARG DEVCONTAINER_USER_NAME=devcontainer
ARG DEVCONTAINER_USER_HOME=/home/devcontainer
ENV LANG=C.UTF-8

# Only for test
# COPY ./build/common  ${BUILD_DIR}/common
# COPY ./build/stage1 ${BUILD_DIR}/stage1
# RUN mkdir -p ${BUILD_TMP_DIR} && chmod 777 ${BUILD_TMP_DIR} && cd ${BUILD_TMP_DIR} && ${BUILD_DIR}/stage1/main.sh && apt-get clean && rm -rf /var/lib/apt/lists/* ${BUILD_TEMP_DIR} ${BUILD_DIR}/stage1 /tmp/*
# COPY ./build/stage2 ${BUILD_DIR}/stage2
# ARG DEVCONTAINER_BUILD_CONFIGS
# RUN mkdir -p ${BUILD_TMP_DIR} && chmod 777 ${BUILD_TMP_DIR} && cd ${BUILD_TMP_DIR} && ${BUILD_DIR}/stage2/main.sh && apt-get clean && rm -rf /var/lib/apt/lists/* ${BUILD_TEMP_DIR} ${BUILD_DIR}/stage2 /tmp/*
# COPY ./build/stage3 ${BUILD_DIR}/stage3
# RUN mkdir -p ${BUILD_TMP_DIR} && chmod 777 ${BUILD_TMP_DIR} && cd ${BUILD_TMP_DIR} && ${BUILD_DIR}/stage3/main.sh && apt-get clean && rm -rf /var/lib/apt/lists/* ${BUILD_TEMP_DIR} ${BUILD_DIR} /tmp/*

# Build
COPY ./build ${BUILD_DIR}
ARG DEVCONTAINER_BUILD_CONFIGS
RUN mkdir -p ${BUILD_TMP_DIR} && chmod 777 ${BUILD_TMP_DIR} && cd ${BUILD_TMP_DIR} && ${BUILD_DIR}/stage1/main.sh && ${BUILD_DIR}/stage2/main.sh && ${BUILD_DIR}/stage3/main.sh && apt-get clean && rm -rf /var/lib/apt/lists/* ${BUILD_TEMP_DIR} ${BUILD_DIR} /tmp/*

USER ${DEVCONTAINER_USER_ID}
WORKDIR ${DEVCONTAINER_USER_HOME}
ENTRYPOINT [ "./.entrypoint.sh" ]
