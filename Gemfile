source "https://rubygems.org"

# Mirrors the GitHub Pages native build environment exactly.
# Pinned versions: https://pages.github.com/versions/
gem "github-pages", "~> 232", group: :jekyll_plugins

# webrick left the Ruby stdlib in 3.0; `jekyll serve` needs it.
gem "webrick", "~> 1.8"

platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
  gem "wdm", "~> 0.1.1"
end
