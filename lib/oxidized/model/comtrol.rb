module Oxidized
  module Models
    # Represents the Comtrol model.
    #
    # Handles configuration retrieval and processing for Comtrol devices.

    class Comtrol < Oxidized::Models::Model
      using Refinements

      # @!visibility private
      # Used in Comtrol Industrial Switches, such as RocketLinx ES8510

      # @!visibility private
      # Typical prompt "<hostname>#"

      # @!method prompt(regex)
      #   Sets the prompt for the device.
      #   @param regex [Regexp] The regular expression that matches the prompt.
      prompt /([#>]\s?)$/
      comment '! '

      # @!visibility private
      # how to handle pager
      expect /--More--+\s$/ do |data, re|
        send ' '
        data.sub re, ''
      end

      cmd 'show version' do |cfg|
        comment cfg
      end

      cmd 'show running-config' do |cfg|
        cfg
      end

      cfg :telnet do
        username /^User name:/i
        password /^Password:/i
      end

      cfg :telnet, :ssh do
        if vars :enable
          post_login do
            send "enable\n"
            # @!visibility private
            # Interpret enable: true as meaning we won't be prompted for a password
            unless vars(:enable).is_a? TrueClass
              expect /[pP]assword:\s?$/
              send vars(:enable) + "\n"
            end
            expect /^.+[#]\s?$/
          end
        end
        pre_logout 'exit'
      end
    end
  end
end
