### Backup All Files To Another S3 Bucket Rake Task

A Ruby rake task to backup all files from bucket A to bucket B in S3 with DateTime as prefix (folder name).

#### Important

- You don't need web or worker dyno this. You just need [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler).
- [How to create AWS IAM user with S3 access?](https://www.youtube.com/watch?v=p4ZkTtjnWgM) - just watch until 1:40 and click `Download credentials` button that you see on the screen

#### Need .env file sample?

[Here you go](https://gist.github.com/anonymous/0f3b371d199fa3df7176112c0f5d8d95)
