module HstoreTranslate
  module Translates
    module InstanceMethods
      def disable_fallback
        toggle_fallback(false)
      end

      def enable_fallback
        toggle_fallback(true)
      end

      protected

      attr_reader :enabled_fallback

      def hstore_translate_fallback_locales(locale)
        return locale if enabled_fallback == false || !I18n.respond_to?(:fallbacks)
        I18n.fallbacks[locale]
      end

      def read_hstore_translation(attr_name, locale = I18n.locale)
        translations = public_send("#{attr_name}#{SUFFIX}") || {}
        available = Array(hstore_translate_fallback_locales(locale)).detect do |available_locale|
          translations[available_locale.to_s].present?
        end

        translations[available.to_s]
      end

      def write_hstore_translation(attr_name, value, locale = I18n.locale)
        translation_store = "#{attr_name}#{SUFFIX}"

        # This line causing stack level too deep error on activerecord < 4.2
        #              public_send(translation_store) || {}
        translations = public_send(translation_store) || {}
        public_send("#{translation_store}_will_change!") unless translations[locale.to_s] == value
        translations[locale.to_s] = value
        public_send("#{translation_store}=", translations)
        value
      end

      def respond_to_with_translates?(symbol, include_all = false)
        return true if parse_translated_attribute_accessor(symbol)
        respond_to_without_translates?(symbol, include_all)
      end

      def method_missing_with_translates(method_name, *args)
        translated_attr_name, locale, assigning = parse_translated_attribute_accessor(method_name)

        return method_missing_without_translates(method_name, *args) unless translated_attr_name

        if assigning
          write_hstore_translation(translated_attr_name, args.first, locale)
        else
          read_hstore_translation(translated_attr_name, locale)
        end
      end

      # Internal: Parse a translated convenience accessor name.
      #
      # method_name - The accessor name.
      #
      # Examples
      #
      #   parse_translated_attribute_accessor("title_en=")
      #   # => [:title, :en, true]
      #
      #   parse_translated_attribute_accessor("title_fr")
      #   # => [:title, :fr, false]
      #
      # Returns the attribute name Symbol, locale Symbol, and a Boolean
      # indicating whether or not the caller is attempting to assign a value.
      def parse_translated_attribute_accessor(method_name)

        # It's required to monkey patch this line to enable :tat locale
        #                                                   {2} <- origin
        return unless /(?<attribute>[a-z_]+)_(?<locale>[a-z]{2,})(?<assignment>=?)\z/ =~ method_name

        translated_attr_name = attribute.to_sym
        return unless translated_attribute_names.include?(translated_attr_name)

        locale    = locale.to_sym
        assigning = assignment.present?

        [translated_attr_name, locale, assigning]
      end

      def toggle_fallback(enabled)
        if block_given?
          old_value = @enabled_fallback
          begin
            @enabled_fallback = enabled
            yield
          ensure
            @enabled_fallback = old_value
          end
        else
          @enabled_fallback = enabled
        end
      end
    end
  end
end
