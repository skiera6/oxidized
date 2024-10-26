module Oxidized
  module Models
    # Represents the IBOS model.
    #
    # Handles configuration retrieval and processing for IBOS devices.

    class IBOS < Oxidized::Models::Model
      using Refinements

      # @!visibility private
      # IBOS model, Intelligent Broadband Operating System (iBOS)
      # Used in Waystream (previously PacketFront) Routers and Switches

      # @!method prompt(regex)
      #   Sets the prompt for the device.
      #   @param regex [Regexp] The regular expression that matches the prompt.
      prompt /^([\w.@()-]+[#>]\s?)$/
      comment  '! '

      cmd :all do |cfg|
        cfg.each_line.to_a[1..-2].join
      end

      cmd :secret do |cfg|
        # @!visibility private
        # snmp-group version 2c
        #  notify 10.1.1.1 community public trap
        cfg.gsub! /^ notify (\S+) community (\S+) (.*)/, ' notify \\1 community <hidden> \\3'

        # @!visibility private
        # snmp-group version 2c
        #  community public read-only view all
        cfg.gsub! /^ community (\S+) (.*)/, ' community <hidden> \\2'

        # @!visibility private
        # radius server 10.1.1.1 secret public
        cfg.gsub! /^radius server (\S+) secret (\S+)(.*)/, 'radius server \\1 secret <hidden> \\3'
        cfg
      end

      cmd 'show version' do |cfg|
        cfg.gsub! /.*uptime is.*/, ''
        comment cfg
      end

      cmd 'show running-config' do |cfg|
        cfg = cfg.each_line.to_a[0..-1].join
        cfg.gsub! /.*!volatile.*/, ''
        cfg
      end

      cfg :telnet do
        username /^username:\s/
        password /^\r?password:\s/
      end

      cfg :telnet, :ssh do
        # @!visibility private
        # preferred way to handle additional passwords
        post_login do
          if vars(:enable) == true
            cmd "enable"
          elsif vars(:enable)
            cmd "enable", /^[pP]assword:/
            cmd vars(:enable)
          end
        end
        post_login 'terminal no pager'
        post_login 'terminal width 65535'
        pre_logout 'exit'
      end
    end
  end
end
