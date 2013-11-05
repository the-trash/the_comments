## TheComments Dummy App

### First step

```
git clone https://github.com/the-teacher/the_comments.git

cd the_comments/spec/dummy_app/

bundle
```

### App start

```
rake db:bootstrap_and_seed

rails s -p 3000 -b localhost
```

Browser

```
http://localhost:3000/
```

### Tests start

```
rake db:bootstrap RAILS_ENV=test

rspec --format documentation
```
