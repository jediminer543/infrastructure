# Ingress

This stage configures ingress and sets up cert manager

Please note: this assumes the host posesses some proxy (haproxy) that will be configured to relay appropriate requests to the ingress via Host/SNI with sendproxy enabled