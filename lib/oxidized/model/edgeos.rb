module Oxidized
  module Models
    # Represents the Edgeos model.
    #
    # Handles configuration retrieval and processing for Edgeos devices.

    class Edgeos < Oxidized::Models::Model
      using Refinements

      # @!visibility private
      # EdgeOS #

      # @!method prompt(regex)
      #   Sets the prompt for the device.
      #   @param regex [Regexp] The regular expression that matches the prompt.
      prompt /@.*?:~\$\s/

      cmd :all do |cfg|
        cfg.lines.to_a[1..-2].join
      end

      cmd :secret do |cfg|
        cfg.gsub! /encrypted-password (\S+).*/, 'encrypted-password <secret removed>'
        cfg.gsub! /plaintext-password (\S+).*/, 'plaintext-password <secret removed>'
        cfg.gsub! /password (\S+).*/, 'password <secret removed>'
        cfg.gsub! /pre-shared-secret (\S+).*/, 'pre-shared-secret <secret removed>'
        cfg.gsub! /community (\S+) {/, 'community <hidden> {'
        cfg
      end

      cmd 'show version | no-more' do |cfg|
        cfg.gsub! /^Uptime:\s.+/, ''
        comment cfg
      end

      cmd 'show configuration commands | no-more'

      cfg :telnet do
        username  /login:\s/
        password  /^Password:\s/
      end

      cfg :telnet, :ssh do
        pre_logout 'exit'
      end
    end
  end
end
