source "https://rubygems.org"

# Mirrors the GitHub Pages native build environment exactly.
# Pinned versions: https://pages.github.com/versions/
gem "github-pages", "~> 232", group: :jekyll_plugins

# webrick left the Ruby stdlib in 3.0; `jekyll serve` needs it.
gem "webrick", "~> 1.8"

# Windows has no system tzdata, so Ruby needs the zone database as a gem.
# (The `wdm` file-watching gem is deliberately absent: it does not build on
# Ruby 3.3, and OneDrive breaks native change notifications anyway. Serve with
# --force_polling instead. See README.)
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end
