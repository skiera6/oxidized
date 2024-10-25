module Oxidized
  module Models
    class ZyNOSADSL < Oxidized::Models::Model
      using Refinements

      # @!visibility private
      # Used in Zyxel ADSL, such as AAM1212-51

      prompt /^.*>\s?$/
      comment ';; '

      cmd 'config show all nopause'

      cfg :telnet do
        password /^Password:/i
      end
    end
  end
end
