# Dancr
Dancer Blog Example in [Dancer2::Tutorial](https://metacpan.org/pod/distribution/Dancer2/lib/Dancer2/Tutorial.pod)

This is an example of Dancr micro blog but with a few changes.
You need to install the following modules:

* Dancer2 - lightweight yet powerful web application framework (libdancer2-perl)
* SQLite - file-based relational database engine (sqlite3.deb)
* DBD::SQLite - self-contained RDBMS in a DBI Driver (libdbd-sqlite3-perl.deb)
* Template::Toolkit - template processing system (libtemplate-perl.deb)
* File::Slurp - Simple and Efficient Reading/Writing/Modifying of Complete Files (libfile-slurp-perl.deb)
* File::Spec - portably perform operations on file names (libfile-spec-perl.deb)
* DateTime - a date and time object for Perl (lib-date-time.deb)
* Bootstrap - front-end framework
* JQuery - JavaScript Library

Running application
-------------------
To run the aplication just clone this repo with git in console and run app.pl

```
$ git clone https://github.com/hecaxmmx/dancr
$ cd dancr
$ ./bin/app.pl
```
or via plack
```
plackup ./bin/app.pl -p 5000
```

# Note
Since this aplication has been tested in Debian Jessy, you need to install modules via "apt-get install" and use the older form of run plack.
