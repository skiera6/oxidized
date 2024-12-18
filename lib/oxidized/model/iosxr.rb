module Oxidized
  module Models
    # Represents the IOSXR model.
    #
    # Handles configuration retrieval and processing for IOSXR devices.

    class IOSXR < Oxidized::Models::Model
      using Refinements

      # @!visibility private
      # IOS XR model #

      # @!method prompt(regex)
      #   Sets the prompt for the device.
      #   @param regex [Regexp] The regular expression that matches the prompt.
      prompt /^(\r?[\w.@:\/-]+[#>]\s?)$/
      comment  '! '

      cmd :all do |cfg|
        cfg.each_line.to_a[2..-2].join
      end

      cmd :secret do |cfg|
        cfg.gsub! /^(snmp-server community).*/, '\\1 <configuration removed>'
        cfg.gsub! /secret (\d+) (\S+).*/, '<secret hidden>'
        cfg
      end

      cmd 'show inventory all' do |cfg|
        comment cfg
      end

      cmd 'show platform' do |cfg|
        comment cfg
      end

      cmd 'show running-config' do |cfg|
        cfg = cfg.each_line.to_a[1..-1].join
        cfg
      end

      cfg :telnet do
        username /^Username:/
        password /^\r?Password:/
      end

      cfg :telnet, :ssh do
        post_login 'terminal length 0'
        post_login 'terminal width 0'
        post_login 'terminal exec prompt no-timestamp'
        if vars :enable
          post_login do
            send "enable\n"
            send vars(:enable) + "\n"
          end
        end
        pre_logout 'exit'
      end
    end
  end
end
