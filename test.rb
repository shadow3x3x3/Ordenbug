require 'prawn'
require 'squid'

Prawn::Document.generate 'test.pdf' do
  chart views: {2013 => 182, 2014 => 46, 2015 => 134}
end
