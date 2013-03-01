package Calculator;

use ChatBot::Simple;

no warnings 'uninitialized';

pattern qr{(\d+)\s*([\+\-\*\/])\s*(\d+)} => sub {
  my ($input,$param) = @_;
  my ($n1,$op,$n2) = ($param->{':1'},$param->{':2'},$param->{':3'});

  return
        $op eq '+' ? $n1 + $n2
      : $op eq '-' ? $n1 - $n2
      : $op eq '*' ? $n1 * $n2
      : $op eq '/' ? $n1 / $n2
                   : "I don't know how to calculate that!";
};

1;
