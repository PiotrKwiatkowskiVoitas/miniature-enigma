
# Notes

## Create certs (server)
```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365 -nodes
```

## Run registery with certs
```bash
docker run -d --restart=always --name registry -v "$(pwd)"/certs:/certs -e REGISTRY_HTTP_ADDR=0.0.0.0:443 -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/cert.pem -e REGISTRY_HTTP_TLS_KEY=/certs/key.pem -p 443:443 registry:2
```

## Get cert
```bash
openssl s_client -showcerts -connect "IP:port" </dev/null 2>/dev/null|openssl x509 -outform PEM >mycertfile_registry.pem
```
Replace "IP:port" with IP address and port to registery don't add "https://" beforehand.

## Adding certs to registery 
```bash
sudo cp CICD.crt /usr/share/ca-certificates
sudo dpkg-reconfigure ca-certificates
```
