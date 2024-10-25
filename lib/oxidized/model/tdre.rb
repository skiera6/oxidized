module Oxidized
  module Models
    # Represents the TDRE model.
    #
    # Handles configuration retrieval and processing for TDRE devices.

    class TDRE < Oxidized::Models::Model
      using Refinements

      # @!method prompt(regex)
      #   Sets the prompt for the device.
      #   @param regex [Regexp] The regular expression that matches the prompt.
      prompt /^>$/
      cmd "get -f"

      # Determines if the current session is an SSH session.
      #
      # @return [MatchData, nil] Returns the MatchData if the session is SSH, otherwise nil.
      def ssh
        @input.class.to_s.match(/SSH/)
      end

      expect /^>.+$/ do |data, re|
        send "\r" if ssh
        data.sub re, ''
      end

      cmd :all do |cfg|
        if ssh
          cfg.lines.to_a[5..-4].join
        else
          cfg.lines.to_a[1..-4].join
        end
      end

      cfg :telnet do
        username /^Username:/
        password /^Password:/
      end

      cfg :telnet, :ssh do
        pre_logout "DISCONNECT\r"
      end
    end
  end
end
