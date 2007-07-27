################################################################################
# Tasks used for extracting and compiling gettext texts and translations.
# 
# Added 2007-07-16 by Sam Lown <dev at samlown.com>

require 'gettext/utils'

namespace :gettext do

  desc "Create mo-files for L10n" 
  task :makemo do
    GetText.create_mofiles(true, "po", "locale")
  end
  
  desc "Update pot/po files to match new version." 
  task :updatepo do
    MY_APP_TEXT_DOMAIN = "devalot" 
    MY_APP_VERSION     = "devalot 0.2" 
    GetText.update_pofiles(MY_APP_TEXT_DOMAIN,
                        Dir.glob("{app,lib}/**/*.{rb,rhtml}"),
                        MY_APP_VERSION )
  end

end
