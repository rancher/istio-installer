FROM registry.suse.com/suse/sle15:15.3
ENV ISTIO_VERSION 1.19.6
RUN zypper -n update && \
    zypper -n install curl jq openssl nginx tar gzip sudo

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
