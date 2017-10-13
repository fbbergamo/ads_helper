module AdsHelper
  class Ads
    class DimensionsRequired < StandardError; end
    class BadFormattedDimensions < StandardError; end
    class InvalidSource < StandardError; end
    class LimitedHit < StandardError; end
    class AllLimitedHit < StandardError; end

    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::OutputSafetyHelper
    attr_accessor :client_id, :counter, :browser, :debug, :links_counter, :amp

    LIMIT = {
      adsense: 3,
      adsense_link: 3,
      criteo: 4,
      all: 9
    }

    def initialize(client_id:, browser:, amp:, development: false)
      self.counter = {}
      self.counter.default = 0
      self.client_id = client_id
      self.browser = browser
      self.amp = amp
      self.debug = development
    end

    def banner(source:, id:, screen:, options: {})
      return unless validate_screen(screen)

      validate_banners_print_limit(source)

      if debug
        mock_banner(id, source, options)
      elsif block_given?
        yield
      elsif source == :criteo
        criteo_banner(id, options)
      elsif [:adsense, :adsense_link].include?(source)
        adsense_banner(id, source, options)
      end
    end

    def adsense_banner(id, source, options)
      if amp
        adsense_amp(id, options)
      else
        adsense_html(id, source, options)
      end
    end

    def criteo_banner(id, options)
      if amp
        criteo_amp(id, options)
      else
        criteo_html(id)
      end
    end

    def validate_banners_print_limit(source)
      raise InvalidSource, "No source #{source}" unless LIMIT[source].present?
      raise LimitedHit, "Limit print Banner to #{source}" if counter[source] >= LIMIT[source]
      raise AllLimitedHit, "Limited hit for all banners, check limit[:all] setup" if (counter.values.reduce(:+) || 0) >= LIMIT[:all]
      counter[source] += 1
    end

    def validate_screen(screen)
      send("screen_#{screen}?")
    end

    def mock_banner(id, source, options)
      return_dimesions(options) if options[:dimension]

      defaults = { dimension: (options[:placehold_size] || '320x250') }
      options = options.to_h.reverse_merge(defaults).with_indifferent_access
      image_tag("http://placehold.it/#{options[:dimension]}")
    end

    def screen_all?
      true
    end

    def screen_desktop?
      !screen_portable? && !screen_amp?
    end

    def screen_portable?
      (browser.device.mobile? || browser.device.tablet? || !browser.modern?) && !screen_amp?
    end

    def screen_amp?
      amp
    end

    def screen_portable_or_amp?
      screen_amp? || browser.device.mobile? || browser.device.tablet? || !browser.modern?
    end

    alias desktop? screen_desktop?
    alias portable? screen_portable?
    alias amp? screen_amp?

    def adsense_amp(id, options)
      width, height = return_dimesions(options)

      content_tag('amp-ad', '', width: width, height: height, data: {ad_client: "ca-pub-#{client_id}", ad_slot: id}, type: 'adsense')
    end

    def adsense_html(id, source, options)
      extra = {}

      if options[:responsive]
        style = 'display:block'
        extra = if source == :adsense_link
                  { 'data-ad-format' => 'link' }
                else
                  { 'data-ad-format' => 'auto' }
        end
      else
        width, height = return_dimesions(options)
        style = "display:inline-block;width:#{width}px;height:#{height}px"
      end

      tags = [
        content_tag('script', '', async: '', src: '//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js'),
        content_tag('ins', '', *[{ class: 'adsbygoogle', style: style, 'data-ad-client' => "ca-pub-#{client_id}", 'data-ad-slot' => id }.merge(extra)]),
        content_tag('script', '(adsbygoogle = window.adsbygoogle || []).push({});')
      ]

      safe_join(tags)
    end

    def criteo_html(id)
      ad_call = %Q[Criteo.DisplayAd({"zoneid": #{id}, "async": false});]
      content_tag('script', ad_call.html_safe, type: 'text/javascript')
    end

    def criteo_amp(id, options)
      width, height = return_dimesions(options)
      content_tag('amp-ad', '', width: width,
        height: height,
        data: {tagtype: "passback", zone: id},
        type: 'criteo')
    end

    def return_dimesions(options)
      raise DimensionsRequired, 'Dimesion is required for AMP or no responsive Adsense banners' if options[:dimension].blank?

      options[:dimension].split('x').to_a.tap do |width, height|
        raise BadFormattedDimensions, 'Invalid ad dimension, should be "#{width}x#{height}"' unless width.to_s[/^\d+$/] && height.to_s[/^\d+$/]
      end
    end
  end
end
