# For Bundler.with_clean_env
require 'bundler/setup'

PACKAGE_NAME = "BBSync"
VERSION = "0.0.4"
TRAVELING_RUBY_VERSION = "20150210-2.1.5"

desc "Package your app"
task :package => ['package:linux:x86', 'package:linux:x86_64', 'package:osx', 'package:osx32' 'package:win32']

namespace :package do
  namespace :linux do
    desc "Package your app for Linux x86"
    task :x86 => [:bundle_install, "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz"] do
      create_package("linux-x86")
    end

    desc "Package your app for Linux x86_64"
    task :x86_64 => [:bundle_install, "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz"] do
      create_package("linux-x86_64")
    end
  end

  desc "Package your app for OS X"
  task :osx => [:bundle_install, "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz"] do
    create_package("osx")
  end

  desc "Package your app for OSX 32-bit"
  task :osx32 => [:bundle_install, "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx32.tar.gz"] do
    create_package("osx", :osx32)
  end


  desc "Package your app for Windows x86"
  task :win32 => [:bundle_install, "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-win32.tar.gz"] do
    create_package("win32", :windows)
  end

  desc "Install gems to local directory"
  task :bundle_install do
    if RUBY_VERSION !~ /^2\.1\./
      abort "You can only 'bundle install' using Ruby 2.1, because that's what Traveling Ruby uses."
    end
    sh "rm -rf packaging/tmp"
    sh "mkdir packaging/tmp"
    sh "cp Gemfile Gemfile.lock packaging/tmp/"
    Bundler.with_clean_env do
      sh "cd packaging/tmp && env BUNDLE_IGNORE_CONFIG=1 bundle install --path ../vendor --without development"
    end
    sh "rm -rf packaging/tmp"
    sh "rm -f packaging/vendor/*/*/cache/*"
  end
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz" do
  download_runtime("linux-x86")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz" do
  download_runtime("linux-x86_64")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz" do
  download_runtime("osx")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-win32.tar.gz" do
  download_runtime("win32")
end

def create_package(target, os_type = :unix)
  package_dir = "#{PACKAGE_NAME}-#{VERSION}-#{target}"
  package_dir += "32" if os_type == :osx32
  sh "rm -rf #{package_dir}"
  sh "mkdir #{package_dir}"
  sh "mkdir -p #{package_dir}/lib/app"
  sh "cp scrape.rb scraper.rb courses.yml #{package_dir}/lib/app/"
  sh "cp config.yml.example #{package_dir}/config.yml"
  sh "mkdir #{package_dir}/lib/ruby"
  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz -C #{package_dir}/lib/ruby"

  # not working...
  if os_type == :osx32
    # replace binaries in bin.real with RVM binaries
    # remember to `rbenv install 2.1.5` if it doesn't work
    sh "rm #{package_dir}/lib/ruby/bin.real/*"
    sh "cp ~/.rvm/rubies/ruby-2.1.5/bin/* ~/.rvm/gems/ruby-2.1.5/bin/* #{package_dir}/lib/ruby/bin.real/"

    # replace binaries in lib with RVM binaries
    sh "pushd #{package_dir}/lib/ruby/lib"
    sh "rm libcrypto.1.0.0.dylib libedit.0.dylib libffi.6.dylib libncurses.5.dylib liblzma.5.dylib libgmp.10.dylib libssl.1.0.0.dylib libyaml-0.2.dylib ./libffi.dylib ./libgmp.dylib"
    sh "cp /usr/lib/libncurses.5.dylib /usr/local/Cellar/libyaml/0.1.6_1/lib/libyaml.dylib /usr/local/Cellar/openssl/1.0.2d_1/lib/libcrypto.1.0.0.dylib /usr/local/Cellar/openssl/1.0.2d_1/lib/libssl.1.0.0.dylib /usr/lib/libedit.2.dylib /usr/lib/libffi.dylib /usr/local/Cellar/openssl/1.0.2d_1/lib/engines/libgmp.dylib /usr/local/Cellar/xz/5.2.1/lib/liblzma.5.dylib /usr/local/Cellar/libyaml/0.1.6_1/lib/libyaml-0.2.dylib  ."
    sh "rm libedit.dylib libreadline.dylib"
    sh "ln -s libedit.2.dylib libedit.dylib"
    sh "ln -s libedit.2.dylib libreadline.dylib"
    sh "popd"

    # replace binaries in lib/ruby/2.1.5/extensions with RVM binaries
    sh "rm -r #{package_dir}/lib/ruby/2.1.5/extensions/x86_64-darwin-13/2.1.5-static/*"
    sh "cp -r ~/.rvm/gems/ruby-2.1.5/extensions/x86_64-darwin-10/2.1.5/*  #{package_dir}/lib/ruby/2.1.5/extensions/x86_64-darwin-13/2.1.5-static/"

    # replace ruby lib dir with RVM ruby lib
    sh "rm -r  #{package_dir}/lib/ruby/lib/ruby/2.1.5/"
    sh "cp -r ~/.rvm/rubies/ruby-2.1.5/lib/ruby/2.1.5 #{package_dir}/lib/ruby/lib/ruby/"

    # replace gems with RVM gems
    sh "rm -r #{package_dir}/lib/ruby/lib/ruby/gems/2.1.5/*"
    sh "cp -r ~/.rvm/gems/ruby-2.1.5/build_info ~/.rvm/gems/ruby-2.1.5/cache ~/.rvm/gems/ruby-2.1.5/specifications ~/.rvm/gems/ruby-2.1.5/doc #{package_dir}/lib/ruby/lib/ruby/gems/2.1.5/"
    sh "mkdir #{package_dir}/lib/ruby/lib/ruby/gems/2.1.5/gems"
    sh "cp -r ~/.rvm/gems/ruby-2.1.5/gems/* #{package_dir}/lib/ruby/lib/ruby/gems/2.1.5/gems/"
  end

  if os_type == :win32
    sh "cp packaging/wrapper.bat #{package_dir}/bbsync.bat"
  else
    sh "cp packaging/wrapper.sh #{package_dir}/bbsync"
  end
  sh "cp -pR packaging/vendor #{package_dir}/lib/"
  sh "cp Gemfile Gemfile.lock #{package_dir}/lib/vendor/"
  sh "mkdir #{package_dir}/lib/vendor/.bundle"
  sh "cp packaging/bundler-config #{package_dir}/lib/vendor/.bundle/config"
  if !ENV['DIR_ONLY']
    if os_type == :win32
      sh "zip -9r dist/#{package_dir}.zip #{package_dir}"
    else
      sh "tar -czf dist/#{package_dir}.tar.gz #{package_dir}"
    end
    sh "rm -rf #{package_dir}"
  end
end

def download_runtime(target)
  sh "cd packaging && curl -L -O --fail " +
    "http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz"
end
