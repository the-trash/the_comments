TheAppStartScripts
==================

Bash scripts for starting Rails Services & App

For example it can start `whenever`, `sphinx`, `delayed_job`, `sidekiq`, `unicorn`, etc.

1. Clone it to `#{ RAILS.root }/_app/`
2. Makes sripts executables `chmod 744 _app/*.sh`
3. Setup vars in `_app/_vars.sh`

```
/rails/app> _app/init.sh

/rails/app> _app/start.sh
/rails/app> _app/stop.sh
```
