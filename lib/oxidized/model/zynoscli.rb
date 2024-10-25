module Oxidized
  module Models
    # Represents the ZyNOSCLI model.
    #
    # Handles configuration retrieval and processing for ZyNOSCLI devices.

    class ZyNOSCLI < Oxidized::Models::Model
      using Refinements

      # @!visibility private
      # Used in Zyxel DSLAMs, such as SAM1316

      # @!visibility private
      # Typical prompt "XGS4600#"

      # @!method prompt(regex)
      #   Sets the prompt for the device.
      #   @param regex [Regexp] The regular expression that matches the prompt.
      prompt /^([\w.@()-]+[#>]\s\e7)$/
      comment  ';; '

      cmd :all do |cfg|
        cfg.gsub! /^.*\e7/, ''
      end
      cmd 'show stacking'

      cmd 'show version'

      cmd 'show running-config'

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
            expect /^.+[#]$/
          end
        end
        pre_logout 'exit'
      end
    end
  end
end
