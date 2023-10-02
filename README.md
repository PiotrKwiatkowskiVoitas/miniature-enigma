# Testing CICD dev

Testing CICD at Voitas


docker run -d \
  --restart=always \
  --name registry \
  -v "$(pwd)"/certs:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/cert.pem \
  -e REGISTRY_HTTP_TLS_KEY=/certs/key.pem \
  -p 443:443 \
  registry:2
