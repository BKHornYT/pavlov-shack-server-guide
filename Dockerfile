FROM ghcr.io/gab9281/pavlov-shack-docker:main
USER root
RUN cp /usr/lib/llvm-10/lib/libc++.so.1.0 /lib/x86_64-linux-gnu/libc++.so
