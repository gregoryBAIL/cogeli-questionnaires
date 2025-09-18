#!/usr/bin/env ruby

# Script pour mettre à jour les noms des codes FHREH

ProductKit.where("code LIKE ?", "FHREH%").each do |kit|
  diam = kit.code.gsub("FHREH", "")
  kit.update!(name: "Rehausse de conduit #{diam}")
  puts "#{kit.code}: #{kit.name}"
end

puts "Noms FHREH mis à jour"