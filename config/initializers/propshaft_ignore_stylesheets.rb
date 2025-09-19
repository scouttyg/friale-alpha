# During rake assets:precompile, propshaft moves over scss files without compiling them.
# On the flipside, yarn build:css will compile them, along with the .css files correctly.
# So, for now, let's force propshaft not to handle the asset stylesheets directory

Rails.application.config.assets.excluded_paths << Rails.root.join("app/assets/stylesheets")
