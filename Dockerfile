FROM docker.io/k0sproject/k0s:v1.30.2-k0s.0

FROM ubuntu:22.04

RUN for u in etcd kube-apiserver kube-scheduler konnectivity-server; do \
    useradd --system --shell /sbin/nologin --no-create-home -d /var/lib/k0s "$u"; \
  done
RUN apt-get update && apt-get install -y iptables tini kmod ca-certificates vim curl iproute2
RUN update-ca-certificates

RUN update-alternatives --set iptables /usr/sbin/iptables-legacy && update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

COPY --from=0 /usr/local/bin/k0s /usr/local/bin/k0s

COPY k0s.yaml /etc/k0s/k0s.yaml

ENV KUBECONFIG=/var/lib/k0s/pki/admin.conf

ADD docker-entrypoint.sh /entrypoint.sh


ENTRYPOINT ["/usr/bin/tini", "-v", "--", "/entrypoint.sh" ]

CMD ["k0s", "controller", "--enable-worker", "--kubelet-extra-args", "--hostname-override=master", "--single"]

