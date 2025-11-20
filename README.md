# Comands

## Build

~~~bash
docker build -t fedorax .
~~~

## run

~~~bash
docker run -d -p {{PORT}}:22 -e USER_NAME={{USER_NAME}} -e USER_PASS={{USER_PASS}} -e USER_SUDO={{true|false}} fedorax
~~~
