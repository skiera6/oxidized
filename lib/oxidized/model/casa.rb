module Oxidized
  module Models
    # Represents the Casa model.
    #
    # Handles configuration retrieval and processing for Casa devices.

    class Casa < Oxidized::Models::Model
      using Refinements

      # @!visibility private
      # Casa Systems CMTS

      # @!method prompt(regex)
      #   Sets the prompt for the device.
      #   @param regex [Regexp] The regular expression that matches the prompt.
      prompt /^([\w.@()-]+[#>]\s?)$/
      comment '! '

      cmd :secret do |cfg|
        cfg.gsub! /^(snmp community) \S+/, '\\1 <configuration removed>'
        cfg.gsub! /^(snmp comm-tbl) \S+ \S+/, '\\1 <removed> <removed>'
        cfg.gsub! /^(console-password encrypted) \S+/, '\\1 <secret hidden>'
        cfg.gsub! /^(password encrypted) \S+/, '\\1 <secret hidden>'
        cfg.gsub! /^(tacacs-server key) \S+/, '\\1 <secret hidden>'
        cfg.gsub! /^(  ip rip authentication secret) \S+/, '\\1 <secret hidden>'
        cfg
      end

      cmd :all do |cfg|
        cfg.cut_both
      end

      cmd 'show system' do |cfg|
        cfg.gsub! /Uptime:.*/, 'Uptime: <removed>'
        cfg.gsub! /Time:.*/, 'Time: <removed>'
        comment cfg
      end

      cmd 'show version' do |cfg|
        comment cfg
      end

      cmd 'show run'

      cfg :telnet do
        username /^Username:/
        password /^Password:/
      end

      cfg :telnet, :ssh do
        post_login 'page-off'
        # @!visibility private
        # preferred way to handle additional passwords
        if vars :enable
          post_login do
            send "enable\n"
            cmd vars(:enable)
          end
        end
        pre_logout 'logout'
      end
    end
  end
end
