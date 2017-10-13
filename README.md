# AdsHelper

Helper to build ads from Criteo and adsense

# Usage

```
portable = Browser.new('Mozilla/5.0 (Linux; U; Android 1.5; en-gb; T-Mobile G1 Build/CRC1) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1')

ads = AdsHelper::Ads.new(client_id: client_id, browser: portable, amp: false)
```

```
<%= ads.banner(source: :adsense, id: '1234', screen: :all, options: { responsive: true }) %>
```

```
<%= ads.banner(source: :adsense, id: '1234', screen: :all, options: { dimension: '100x250' }) %>
```

```
<%= ads.banner(source: :criteo, id: '1234', screen: :all, options: { dimension: '100x200' }) %>
```
