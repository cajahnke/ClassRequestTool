# Class Request Tool

## Application Set-up Steps

1. Get code from: https://github.com/harvard-library/class_request_tool
2. Run bundle install. You will probably have to install OS-vendor supplied libraries to satisfy some gem install requirements.
3. Create the database and run `rake db:schema:load`, after modifying "config/database.yml" to suit your environment.
4. Create a .env file for your environment. Currently, the following variables are needed to run Class Request Tool:

```
SECRET_TOKEN=ThirtyPlusCharStringOfRandomnessGottenFromRakeSecretMaybe # Only needed in RAILS_ENV=production
DEVISE_SECRET_KEY=anotherThirtyPluscharStringOfRandomness              # Also only needed in production
ROOT_URL=my.crt.host.com
DEFAULT_MAILER_SENDER=email.address.for.mails@my.crt.host.com
EMAIL_BATCH_LIMIT=100
```

## License

This application is licensed under the GPL, version 3.
