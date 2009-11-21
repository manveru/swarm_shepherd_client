module SwarmShepherd
  class Controller < Ramaze::Controller
    layout :default
    helper :xhtml
    engine :Etanni
  end
end

# Here go your requires for subclasses of Controller:
require_relative 'main'
