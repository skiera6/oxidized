module Oxidized
  module Models
    # Represents the ZyNOSGS model.
    #
    # Handles configuration retrieval and processing for ZyNOSGS devices.

    class ZyNOSGS < Oxidized::Models::Model
      using Refinements

      # @!visibility private
      # Used in Zyxel GS1900 switches, tested with GS1900-8
      prompt /^.*# $/
      comment '! '
      expect /^--More--$/ do |data, re|
        send ' '
        data.sub re, ''
      end

      # @!visibility private
      # replace all used vt100 control sequences
      expect /\e\[\??\d+(;\d+)*[A-Za-z]/ do |data, re|
        data.gsub re, ''
      end
      cmd 'show running-config' do |cfg|
        cfg.gsub! /(System Up Time:) \S+(.*)/, '\\1 <time>'
        # @!visibility private
        # Remove garbage vt100 control sequences
        # Backspace 0x07 char or escape char + control chars
        cfg.gsub! /[\b]|\e\[A|\e\[2K/, ''
        # @!visibility private
        # Remove empty lines
        cfg.gsub! "\n\n", "\n"
        cfg
      end

      cfg :telnet, :ssh do
        username /^(User name|.*Username):/
        password /^\r?Password:/
      end
      cfg :telnet do
        pre_logout do
          send "exit\r"
        end
      end
      cfg :ssh do
        pre_logout do
          # @!visibility private
          # Yes, that GS1900 switch needs two exit !
          send "exit\n"
          send "exit\n"
        end
      end
    end
  end
end
