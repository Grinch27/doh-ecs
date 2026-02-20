#!/usr/bin/bash

## install q at:
## https://github.com/natesales/q

myDnsDomain="test.domain.com"
testDomain="douyu.com"
testSubnet="1.2.3.0/24"
testReqEncoded="RJ8BAAABAAAAAAAABWRvdXl1A2NvbQAAAgAB"

# 可按你的部署改成 masked 路径，例如 /masked-dns-query、/masked-resolve
queryPath="/dns-query"
resolvePath="/resolve"

## GET /resolve JSON
curl --header "accept: application/dns-json" "https://${myDnsDomain}${resolvePath}?name=${testDomain}"
curl --header "accept: application/dns-json" "https://${myDnsDomain}${resolvePath}?name=${testDomain}&edns_client_subnet=${testSubnet}"

## GET /dns-query Base64 Encoded URL
curl --header 'accept: application/dns-message' --verbose "https://${myDnsDomain}${queryPath}?dns=${testReqEncoded}" | hexdump
# q --http-method=GET                          "${testDomain}" @https://${myDnsDomain}${queryPath}
# q --http-method=GET --subnet="${testSubnet}" "${testDomain}" @https://${myDnsDomain}${queryPath}

## POST /dns-query BODY
echo -n "${testReqEncoded}" | base64 --decode | curl --header 'content-type: application/dns-message' --data-binary @- "https://${myDnsDomain}${queryPath}" --output - | hexdump
# q --http-method=POST                          "${testDomain}" @https://${myDnsDomain}${queryPath}
# q --http-method=POST --subnet="${testSubnet}" "${testDomain}" @https://${myDnsDomain}${queryPath}

## Masked 路径示例（如 queryPath=/masked-dns-query, resolvePath=/masked-resolve）
# curl --header 'accept: application/dns-message' "https://${myDnsDomain}/masked-dns-query?dns=${testReqEncoded}" | hexdump
# curl --header 'accept: application/dns-json' "https://${myDnsDomain}/masked-resolve?name=${testDomain}"