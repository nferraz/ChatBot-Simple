package Introduction;

use ChatBot::Simple;

no warnings 'uninitialized';

my %mem;

{
    context '';

    transform 'hello' => 'hi';
    transform 'goodbye', 'bye-bye', 'sayonara' => 'bye';

    pattern 'bye' => 'bye!';

    pattern 'hi' => sub {
        my ( $input, $param ) = @_;
        if ( !$mem{name} ) {
            $ChatBot::Simple::__context__ = 'name';
            return "hi! what's your name?";
        }
    };
}

{
    context 'name';

    pattern "my name is :name" => sub {
        my ( $input, $param ) = @_;
        $mem{name} = $param->{':name'};

        $ChatBot::Simple::__context__ = 'how_are_you';
        return "Hello, :name! How are you?";
    };

    pattern qr{^(\w+)$} => sub {
        my ( $input, $param ) = @_;
        $mem{name} = $param->{':1'};

        $ChatBot::Simple::__context__ = 'how_are_you';
        return "Hello, $mem{name}! How are you?";
      }
}

{
    context 'how_are_you';

    pattern 'fine' => "that's great!";

    pattern qr{^(\w+)$} => 'why do you say that?';
}

1;
