use Dancer2;
use DBI;
use File::Spec;
use File::Slurp;
use Template;
use DateTime;
 
set 'database'     => File::Spec->catfile(File::Spec->tmpdir(), 'dancr.db');
set 'session'      => 'Simple';
set 'template'     => 'template_toolkit';
set 'logger'       => 'console';
set 'log'          => 'debug';
set 'show_errors'  => 1;
set 'startup_info' => 1;
set 'warnings'     => 1;
set 'username'     => 'admin';
set 'password'     => 'password';
#set 'layout'       => 'main';
 
my $flash;
 
sub set_flash {
    my $message = shift;
 
    $flash = $message;
}
 
sub get_flash {
 
    my $msg = $flash;
    $flash = "";
 
    return $msg;
}
 
sub connect_db {
    my $dbh = DBI->connect(
        "dbi:SQLite:dbname=".setting('database'),
         "",
         "",
         {RaiseError => 1, sqlite_unicode => 1}
         ) or die $DBI::errstr;
 
    return $dbh;
}
 
sub init_db {
    my $db = connect_db();
    my $schema = read_file('./db/schema.sql');
    $db->do($schema) or die $db->errstr;
}
 
hook before_template_render => sub {
    my $tokens = shift;
 
    $tokens->{'css_url'}    = request->base . 'css/style.css';
    $tokens->{'login_url'}  = uri_for('/login');
    $tokens->{'logout_url'} = uri_for('/logout');
};
 
get '/' => sub {
    my $db = connect_db();
    my $sql = 'select id, title, text, datetime, author from entries order by id desc';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute or die $sth->errstr;
    template 'show_entries.tt', {
        'msg'     => get_flash(),
        'entries' => $sth->fetchall_hashref('id'),
        'session' => session
    };
};

get '/new_entry' => sub {
    template 'new_entry.tt', {
        'session'       => session,
        'add_entry_url' => uri_for('/add')
    }, { layout => 'entries' };
};

get '/update_entry' => sub {
    my $db = connect_db();
    my $sql = 'select id, title, text from entries where id=?';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute(params->{'id'}) or die $sth->errstr;
    my $row = $sth->fetchrow_arrayref();

    template 'update_entry.tt', {
        'session'       => session,
        'add_entry_url' => uri_for('/update'),
        'id_post'       => @$row[0],
        'title_post'    => @$row[1],
        'text_post'     => @$row[2]
    }, { layout => 'entries' };

};

post '/add' => sub {
    if ( not session('logged_in') ) {
        send_error("Not logged in", 401);
    }
 
    my $db = connect_db();
    my $sql = 'insert into entries (title, text, datetime, author) values (?, ?, ?, ?)';
    my $sth = $db->prepare($sql) or die $db->errstr;
    $sth->execute(
              params->{'title'},
              params->{'text'},
              DateTime->now,
              setting('username')
          ) or die $sth->errstr;
 
    set_flash('New entry posted!');
    redirect '/';
};

post '/update' => sub {
    if ( not session('logged_in') ) {
        send_error("Not logged in", 401);
    }

    my @data_update = (params->{'title'}, params->{'text'}, params->{'id'});
    my $db  = connect_db();
    my $sql = 'update entries set title = ?, text = ? where id = ?';
    my $sth = $db->do($sql, undef, @data_update) or die $db->errstr;
    if( $sth < 0 ){
        set_flash($db->errstr);
    }else{
        set_flash('Entry updated');
    }
    redirect '/';
};

get '/delete' => sub {
    if ( not session('logged_in') ) {
        send_error("Not logged in", 401);
    }

    my $db  = connect_db();
    my $sql = 'DELETE from entries where id=?';
    my $sth = $db->do($sql, undef, params->{'id'}) or die $db->errstr;
    if( $sth < 0 ){
        set_flash($db->errstr);
    } else{
        set_flash('Entry deleted');
        return redirect '/';
    }
};

get '/login' => sub {
    template 'login', {}, { layout => 'login' };
};

post '/login' => sub {
    my $err;
 
    if ( request->method() eq "POST" ) {
        # process form input
        if ( params->{'username'} ne setting('username') ) {
            $err = "Invalid username";
        }
        elsif ( params->{'password'} ne setting('password') ) {
            $err = "Invalid password";
        }
        else {
            session logged_in => 1;
            set_flash('You are logged in.');
            return redirect '/';
        }
   }
 
   # display login form
   template 'login.tt', { 'err' => $err }, { layout => 'login.tt' };
 
};

get '/about' => sub {
    template 'about.tt', { 'session' => session }, { layout => 'entries' };
};
 
get '/logout' => sub {
   app->destroy_session;
   set_flash('You are logged out.');
   redirect '/';
};
 
init_db();
start;
