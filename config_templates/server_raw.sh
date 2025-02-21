{
  "log": {
    "access": "./access.log",
    "dnsLog": false,
    "error": "./error.log",
    "loglevel": "warning",
    "maskAddress": ""
  },
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api"
      },
      {
        "type": "field",
        "domain": [
          "geosite:category-ads-all"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "domain": [
          "geosite:google"
        ],
        "outboundTag": "warp"
      },
      {
        "type": "field",
        "domain": [
          "domain:gemini.google.com"
        ],
        "outboundTag": "warp"
      },
      {
        "type": "field",
        "domain": [
          "keyword:xn--"
        ],
        "outboundTag": "warp"
      },
      {
        "type": "field",
        "domain": [
          "geosite:intel",
          "category-ru"
        ],
        "outboundTag": "warp"
      },
      {
        "type": "field",
        "ip": [
          "geoip:ru"
        ],
        "outboundTag": "warp"
      },
      {
        "type": "field",
        "domain": [
          "regexp:.*\\.ru$",
          "regexp:.*\\.su$"
        ],
        "outboundTag": "warp"
      }
    ]
  },
  "dns": null,
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 62789,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "streamSettings": null,
      "tag": "api",
      "sniffing": null,
      "allocate": null
    },
    {
      "listen": "127.0.0.1",
      "port": 10550,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "email": "ggpe4nb7",
            "flow": "",
            "id": "b1b8346c-83e1-40aa-883c-d160bf7dcb3f"
          }
        ],
        "decryption": "none",
        "fallbacks": []
      },
      "streamSettings": {
        "network": "tcp",
        "security": "none",
        "tcpSettings": {
          "acceptProxyProtocol": false,
          "header": {
            "type": "none"
          }
        }
      },
      "tag": "inbound-127.0.0.1:10550",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic",
          "fakedns"
        ],
        "metadataOnly": false,
        "routeOnly": false
      },
      "allocate": {
        "strategy": "always",
        "refresh": 5,
        "concurrency": 3
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "ForceIPv4",
        "redirect": "",
        "noises": []
      }
    },
    {
      "tag": "blocked",
      "protocol": "blackhole",
      "settings": {}
    },
    {
      "tag": "IPv4",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIPv4"
      }
    },
    {
      "tag": "warp",
      "protocol": "socks",
      "settings": {
        "servers": [
          {
            "address": "127.0.0.1",
            "port": 40000,
            "users": []
          }
        ]
      }
    }
  ],
  "transport": null,
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundDownlink": true,
      "statsInboundUplink": true,
      "statsOutboundDownlink": true,
      "statsOutboundUplink": true
    }
  },
  "api": {
    "tag": "api",
    "services": [
      "HandlerService",
      "LoggerService",
      "StatsService"
    ]
  },
  "stats": {},
  "reverse": null,
  "fakedns": null,
  "observatory": null,
  "burstObservatory": null
}