FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    python3 python3-pip openssh-server ca-certificates curl tar gzip passwd sudo gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd

RUN useradd -m -s /bin/bash tester \
    && echo 'tester:tester' | chpasswd \
    && usermod -aG sudo tester \
    && echo 'tester ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config || true
RUN sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config || true

EXPOSE 22 80
CMD ["/usr/sbin/sshd", "-D"]