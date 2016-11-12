require 'dotenv'
Dotenv.load
require 'aws-sdk'
require 'mailjet'

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

# init Mailjet
Mailjet.configure do |config|
  config.api_key      = ENV['MAILJET_API_KEY']
  config.secret_key   = ENV['MAILJET_SECRET_KEY']
  config.default_from = ENV['MAILJET_FROM_EMAIL']
end

# set Mailjet email
email = { from_email: ENV['MAILJET_FROM_EMAIL'],
          from_name:  "Rails S3 Backup",
          subject:    "S3 backup successfully generated!",
          text_part:  "S3 backup for the Rails app has been generated successfully. \nLogin to S3 console to see all the files.",
          recipients: [{email: ENV['MAILJET_TO_EMAIL']}] }

# send notification email
Mailjet::Send.create(email)

puts "Done!"
