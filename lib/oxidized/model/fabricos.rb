module Oxidized
  module Models
    class FabricOS < Oxidized::Models::Model
      using Refinements

      # @!visibility private
      # Brocade Fabric OS model #
      ## FIXME: Only ssh exec mode support, no telnet, no ssh screenscraping

      prompt /^([\w]+:+[\w]+[>]\s)$/
      comment '# '

      cmd 'chassisShow' do |cfg|
        comment cfg.each_line.reject { |line| line.match(/Time Awake:/) || line.match(/Power Usage \(Watts\):/) || line.match(/Power Usage:/) || line.match(/Time Alive:/) || line.match(/Update:/) }.join
      end

      cmd 'configShow -all' do |cfg|
        cfg = cfg.each_line.reject { |line| line.match /date = / }.join
        cfg
      end

      cfg :ssh do
        exec true # don't run shell, run each command in exec channel
      end
    end
  end
end
