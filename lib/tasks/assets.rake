namespace :assets do
  desc "Build Tailwind CSS for production"
  task build_css: :environment do
    puts "Building Tailwind CSS..."
    system("npm run build-css-production")
    puts "Tailwind CSS built successfully"
  end
end

# Hook into assets:precompile to build CSS first
Rake::Task["assets:precompile"].enhance(["assets:build_css"])