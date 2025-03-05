# gost-stunnel-CSP

### Структура репозитория
```
.
│   Dockerfile
│
├───bin
│       entrypoint.sh
│       stunnel-socat.sh
│
├───conf
│       CA.crt
│       certificate.pfx
│       stunnel.conf
│
└───cprocsp
        linux-amd64_deb.tgz
```
- CA.crt - сертификат УЦ
- certificate.pfx - личный сертификат с ключом
- linux-amd64_deb.tgz - КриптоПро CSP

### Запуск

Сборка: `docker build . -t proxy-gost `

Запуск: `docker run -p 8080:8080 -e STUNNEL_HOST=<TARGET-HOST>:443 -e STUNNEL_HTTP_PROXY=<HTTP-PROXY-HOST> -e STUNNEL_HTTP_PROXY_PORT=<PORT>-e STUNNEL_HTTP_PROXY_CREDENTIALS=<LOGIN:PASS> proxy-gost`

### Проверка

При запросе `curl http://localhost:8080` через основную систему должна вернуться ошибка 404. Чтобы избежать этой ошибки, необходимо вручную прописать HOST-заголовок!
