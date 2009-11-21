require 'compass'

module SwarmShepherd
  class CSS < Controller
    map '/css'

    provide :css, :engine => :Sass, :type => 'text/css'
    trait :sass_options  => {
      :load_paths => Compass::Frameworks::ALL.map{|f| f.stylesheets_directory}
    }
  end
end
