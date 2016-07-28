package Introduction;

use ChatBot::Simple;

no warnings 'uninitialized';

{
    context '';

    pattern [ 'hi', 'hello' ]  => sub { context 'name' } => "hi! what's your name?";
}

{
    context 'name';

    transform [ "i'm :name", "call me :name" ] => 'my name is :name';

    pattern "my name is :name" => sub { context 'how_are_you' } => "Hello, :name! How are you?";
}

{
    context 'how_are_you';

    pattern 'fine'            => "that's great, :name!";
    pattern ':something_else' => 'why do you say that?';
}

{
    context 'global';

    transform 'goodbye', 'bye-bye', 'sayonara' => 'bye';
    pattern 'bye' => 'bye!';
}

1;
