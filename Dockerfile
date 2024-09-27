FROM registry.suse.com/bci/bci-micro:15.6 as final

FROM registry.suse.com/bci/bci-base:15.6 as builder

# Install system packages using builder image that has zypper
COPY --from=final / /chroot/

# Install some packages with zypper in the chroot of the final micro image
RUN zypper refresh && \
    zypper --installroot /chroot -n in --no-recommends \
    curl jq openssl nginx tar gzip sudo ca-certificates sed && \
    zypper --installroot /chroot clean -a && \
    rm -rf /chroot/var/cache/zypp/* /chroot/var/log/zypp/* /chroot/tmp/* /chroot/var/tmp/* /chroot/usr/share/doc/packages/*

# Main stage using bci-micro as the base image
FROM final

# Copy binaries and configuration files from builder to micro
COPY --from=builder /chroot/ /

ENV ISTIO_VERSION 1.23.2
# Get Istio
RUN curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} sh -
RUN mv istio-${ISTIO_VERSION}/bin/istioctl /usr/bin && chmod +x /usr/bin/istioctl

# Get kubectl
ARG TARGETPLATFORM
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/${TARGETPLATFORM}/kubectl
RUN mv ./kubectl /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# Add scripts for Istio
COPY scripts /usr/local/app/scripts/
RUN chmod +x /usr/local/app/scripts/init_kubeconfig.sh /usr/local/app/scripts/run.sh /usr/local/app/scripts/create_istio_system.sh /usr/local/app/scripts/uninstall_istio_system.sh /usr/local/app/scripts/get_grafana_dashboards.sh /usr/local/app/scripts/fetch_istio_releases.sh
RUN mkdir -p /usr/local/app/dashboards && /usr/local/app/scripts/get_grafana_dashboards.sh

# Add nginx configuration
COPY overlay/ .

# Get Istio tar for nginx
RUN mkdir -p /opt/istio-releases && /usr/local/app/scripts/fetch_istio_releases.sh /opt/istio-releases
RUN mkdir -p /var/cache/nginx

RUN chown -R nginx:nginx /var/cache/nginx /etc/ssl /var/run /usr/share/nginx /usr/lib/ca-certificates /var/lib/ca-certificates /usr/local/app/dashboards
RUN chmod 755 /etc/ssl/private /etc/ssl/certs

RUN echo "nginx ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/nginx \
    && chmod 0440 /etc/sudoers.d/nginx

USER nginx
ENTRYPOINT [ "/usr/local/app/scripts/run.sh" ]
