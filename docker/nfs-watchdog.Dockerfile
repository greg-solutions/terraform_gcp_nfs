FROM google/cloud-sdk:alpine
COPY README.md /

RUN apk add --no-cache --update --verbose bash e2fsprogs e2fsprogs-extra util-linux && \
    rm -rf /var/cache/apk /tmp /sbin/halt /sbin/poweroff /sbin/reboot

# default is 80% disk fullness
ENV THRESHOLD 80
# default is increasing by 10 GB
ENV INCREASE_STEP_GB 10

COPY nfs-watchdog.sh /usr/bin/nfs-watchdog.sh
RUN chmod +x /usr/bin/nfs-watchdog.sh
ENTRYPOINT ["/usr/bin/nfs-watchdog.sh"]