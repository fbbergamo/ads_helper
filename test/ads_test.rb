require 'rails'
require "rails/test_help"
require 'browser'
require 'ads_helper'

class AdsTest  < ActiveSupport::TestCase
  attr_reader :portable, :desktop, :client_id

  def setup
    @portable = Browser.new('Mozilla/5.0 (Linux; U; Android 1.5; en-gb; T-Mobile G1 Build/CRC1) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1')
    @desktop = Browser.new('Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.99 Safari/533.4')
    @client_id = 1
  end

  test 'should print a adsense banner' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: portable, amp: false, development: false)
    assert_equal ads.banner(source: :adsense, id: '1234', screen: :all, options: { dimension: '336x280' }), '<script async="async" src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script><ins class="adsbygoogle" style="display:inline-block;width:336px;height:280px" data-ad-client="ca-pub-1" data-ad-slot="1234"></ins><script>(adsbygoogle = window.adsbygoogle || []).push({});</script>'
  end

  test 'should render a adsense responsive banner' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: portable, amp: false)
    assert_equal ads.banner(source: :adsense, id: '1234', screen: :all, options: { responsive: true }), '<script async="async" src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script><ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-1" data-ad-slot="1234" data-ad-format="auto"></ins><script>(adsbygoogle = window.adsbygoogle || []).push({});</script>'
  end

  test 'should print a criteo banner' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: portable, amp: false)
    assert_equal ads.banner(source: :criteo, id: '1234', screen: :all), '<script type="text/javascript">Criteo.DisplayAd({"zoneid": 1234, "async": false});</script>'
  end

  test 'should print a adsense_link banner' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: portable, amp: false)
    assert_equal ads.banner(source: :adsense_link, id: '1234', screen: :all, options: { dimension: '336x280' }), '<script async="async" src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script><ins class="adsbygoogle" style="display:inline-block;width:336px;height:280px" data-ad-client="ca-pub-1" data-ad-slot="1234"></ins><script>(adsbygoogle = window.adsbygoogle || []).push({});</script>'
  end

  test 'should render a adsense link responsive banner' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: portable, amp: false)
    assert_equal ads.banner(source: :adsense_link, id: '1234', screen: :all, options: { responsive: true }), '<script async="async" src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script><ins class="adsbygoogle" style="display:block" data-ad-client="ca-pub-1" data-ad-slot="1234" data-ad-format="link"></ins><script>(adsbygoogle = window.adsbygoogle || []).push({});</script>'
  end

  test 'should print a adsense amp banner' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: portable, amp: true)
    assert_equal ads.banner(source: :adsense, id: '1234', screen: :all, options: { dimension: '100x250' }), '<amp-ad width="100" height="250" data-ad-client="ca-pub-1" data-ad-slot="1234" type="adsense"></amp-ad>'
  end

  test 'should print a criteo amp banner' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: portable, amp: true)
    assert_equal ads.banner(source: :criteo, id: '1234', screen: :all, options: { dimension: '100x250' }), '<amp-ad width="100" height="250" data-tagtype="passback" data-zone="1234" type="criteo"></amp-ad>'
  end

  test 'should return empty if is a desktop device for a portable banner' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: desktop, amp: false)
    assert_nil ads.banner(source: :adsense, id: '1234', screen: :portable)
  end

  test 'should return empty if is a desktop device for a amp banner' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: desktop, amp: false)
    assert_nil ads.banner(source: :adsense, id: '1234', screen: :amp)
  end

  test 'should return empty if is a portable device for a desktop banner' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: portable, amp: false)
    assert_nil ads.banner(source: :adsense, id: '1234', screen: :desktop)
  end

  test 'should return empty if is a portable device for a portable amp' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: portable, amp: false)
    assert_nil ads.banner(source: :adsense, id: '1234', screen: :amp)
  end

  test 'should return empty if is a amp screen for a portable banner' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: portable, amp: true)
    assert_nil ads.banner(source: :adsense, id: '1234', screen: :portable)
  end

  test 'should return empty if is a amp screen for a desktop banner' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: portable, amp: true)
    assert_nil ads.banner(source: :adsense, id: '1234', screen: :desktop)
  end

  test 'should return if is a portable screen for a portable banner' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: portable, amp: false)
    assert ads.banner(source: :adsense, id: '1234', screen: :portable, options: { dimension: '336x280' }).present?
  end

  test 'should return if is a desktop screen for a desktop banner' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: desktop, amp: false)
    assert ads.banner(source: :adsense, id: '1234', screen: :desktop, options: { dimension: '336x280' }).present?
  end

  test 'should return if is a amp screen for a amp banner' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: desktop, amp: true)
    assert ads.banner(source: :adsense, id: '1234', screen: :amp, options: { dimension: '100x250' }).present?
  end

  test 'should raises a exception if exceed banners LIMIT' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: desktop, amp: false)

    ads.banner(source: :adsense, id: '1234', screen: :all, options: { dimension: '100x250' })
    ads.banner(source: :adsense, id: '1234', screen: :all, options: { dimension: '100x250' })
    ads.banner(source: :adsense, id: '1234', screen: :all, options: { dimension: '100x250' })

    assert_raises AdsHelper::Ads::LimitedHit do
      ads.banner(source: :adsense, id: '1234', screen: :all, options: { dimension: '100x250' })
    end
  end

  test 'should raises a exception if exceed banners all banners LIMITS' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: desktop, amp: false)

    ads.banner(source: :adsense, id: '1234', screen: :all, options: { dimension: '100x250' })
    ads.banner(source: :adsense, id: '1234', screen: :all, options: { dimension: '100x250' })
    ads.banner(source: :adsense, id: '1234', screen: :all, options: { dimension: '100x250' })
    ads.banner(source: :adsense_link, id: '1234', screen: :all, options: { dimension: '100x250' })
    ads.banner(source: :adsense_link, id: '1234', screen: :all, options: { dimension: '100x250' })
    ads.banner(source: :adsense_link, id: '1234', screen: :all, options: { dimension: '100x250' })
    ads.banner(source: :criteo, id: '1234', screen: :all, options: { dimension: '100x250' })
    ads.banner(source: :criteo, id: '1234', screen: :all, options: { dimension: '100x250' })
    ads.banner(source: :criteo, id: '1234', screen: :all, options: { dimension: '100x250' })

    assert_raises AdsHelper::Ads::AllLimitedHit do
      ads.banner(source: :criteo, id: '1234', screen: :all, options: { dimension: '100x250' })
    end
  end

  test 'should raises a exception if render a amp width no dimessions' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: desktop, amp: true)

    assert_raises AdsHelper::Ads::DimensionsRequired do
      ads.banner(source: :adsense, id: '1234', screen: :all)
    end
  end

  test 'should raises a exception if render a amp dimesions bad formated' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: desktop, amp: true)

    assert_raises AdsHelper::Ads::BadFormattedDimensions do
      ads.banner(source: :criteo, id: '1234', screen: :all, options: { dimension: '22xabc' })
    end
  end

  test 'should raises a exception if render a bad formated adsense dimessions ' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: desktop, amp: false)

    assert_raises AdsHelper::Ads::BadFormattedDimensions do
      ads.banner(source: :adsense, id: '1234', screen: :all, options: { dimension: '22xabc' })
    end
  end

  test 'should raises a exception if render adsense with no dimesions or responsive' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: desktop, amp: false)

    assert_raises AdsHelper::Ads::DimensionsRequired do
      ads.banner(source: :adsense, id: '1234', screen: :all)
    end
  end

  test 'should raise a exception if render a invalid source' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: desktop, amp: false)

    assert_raises AdsHelper::Ads::InvalidSource do
      ads.banner(source: :dfp, id: '1234', screen: :all)
    end
  end

  test 'should return a placehold.it on development mode' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: desktop, amp: false, development: true)
    assert_equal ads.banner(source: :adsense, id: '1234', screen: :all, options: { dimension: '200x100' }), '<img src="http://placehold.it/200x100" alt="200x100" />'
  end

  test 'should return a placehold.it on development mode with placehold sizes' do
    ads = AdsHelper::Ads.new(client_id: client_id, browser: desktop, amp: false, development: true)
    assert_equal ads.banner(source: :adsense, id: '1234', screen: :all, options: { placehold_size: '100x250' }), '<img src="http://placehold.it/100x250" alt="100x250" />'
  end
end
