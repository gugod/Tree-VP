use inc::Module::Install;

license 'mit';

all_from 'lib/Tree/VP.pm';

repository 'git://github.com/gugod/Tree-VP.git';

tests 't/*.t';

makemaker_args(
    dist => {
        COMPRESS => "zopfli -i50",
    }
);

if(-d ".git" && !-f "META.yml") {
    cpanfile;
}

WriteAll;
