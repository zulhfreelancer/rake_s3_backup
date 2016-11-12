require 'dotenv'
Dotenv.load
require 'aws-sdk'
require 'slack-notifier'

SLACK_NOTIFIER = Slack::Notifier.new(ENV['SLACK_WEBHOOK_URL'], channel: "#alerts")

# to organize our backup in target bucket, we'll store each backup with `YYYY-MM-DD HH:MM:SS +0000` prefix (folder name)
target_folder = Time.now.to_s

# if `/path/to/file` ends with an `.extension`, return true
def valid_file_path?(path)
	!File.extname(path).empty?
end

# init S3 client
s3      = Aws::S3::Client.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])

# init source bucket
bucket  = Aws::S3::Bucket.new(ENV['SOURCE_BUCKET'])

# get all file paths (not folders)
objects = bucket.objects.select {|object| object.key if valid_file_path?(object.key)}

# duplicate each file from source bucket to target bucket
objects.each {|object| object.copy_to(bucket: ENV['TARGET_BUCKET'], key: "#{target_folder}/#{object.key}")}

msg = "S3 backup for the Rails app has been generated successfully. Check #{target_folder} folder in S3 to see the files."
SLACK_NOTIFIER.ping(msg, icon_url: "http://i.imgur.com/nNHFl3q.png", username: "S3backup")

puts "Done!"
