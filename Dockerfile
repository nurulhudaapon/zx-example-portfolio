FROM debian:12.12 AS build

# Setup Zig
ARG ZIG_VER=0.15.2

RUN apt-get update && apt-get install -y curl xz-utils
RUN curl https://ziglang.org/download/${ZIG_VER}/zig-$(uname -m)-linux-${ZIG_VER}.tar.xz -o zig.tar.xz && \
    tar xf zig.tar.xz && \
    mv zig-$(uname -m)-linux-${ZIG_VER}/ /opt/zig

# Build the app
WORKDIR /app
COPY . .
# -Dtarget=$(uname -m)-linux-musl # musl target is not supported by zap
RUN /opt/zig/zig build -Doptimize=ReleaseFast -Dcpu=baseline


# Run the app
FROM debian:12.12
ARG FW=zap
COPY --from=build /app/zig-out/bin/www_zigx_nuhu_dev /bin/nuhu_site

ENTRYPOINT ["/bin/nuhu_site"]

