#!/usr/bin/env ruby
require File.expand_path('../lib/filesize.rb', __FILE__)

module OS
	def self.linux?
		RUBY_PLATFORM =~ /linux/i
	end

	def self.freebsd?
		RUBY_PLATFORM =~ /freebsd/i
	end
end

module Info
	def self.cpu
		if OS.linux?
			`grep 'model name' /proc/cpuinfo`.gsub /^[^:]+: /, ''
		elsif OS.freebsd?
			`/sbin/sysctl hw.model`.gsub /^[^:]+: /, ''
		else
			'unkonwn'
		end.strip.gsub /\s+/, ' '
	end

	def self.memory
		if OS.linux?
			Filesize.from(`grep 'MemTotal' /proc/meminfo`.gsub(/^[^:]+: /, '').strip).to_s 'MiB'
		elsif OS.freebsd?
			Filesize.from(`sysctl hw.realmem`.gsub(/^[^:]+: /, '').strip + 'B').to_s 'MiB'
		else
			'unknown'
		end
	end
end

motd = File.open File.expand_path(File.join('../lib/motd', `hostname`.strip), __FILE__), 'r' do |f|
	f.read
end

puts motd % {
	:cpu => Info.cpu,
	:mem => Info.memory,
	:current_time => Time.now.asctime,
	:online_users => 0
}
