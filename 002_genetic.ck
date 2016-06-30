// dos melodías intentan alcanzar una melodía de referencia
// a través de mutaciones a melodías aleatorias

// se crean los generadores de sonido
// TODO: no repetir código, crearlos con un for
SinOsc s;
Pan2 p;
JCRev r; // cosmético
0.05 => s.gain;
1.0 => p.pan;
0.03 => r.mix;

SinOsc s2;
Pan2  p2;
JCRev r2; // cosmético
-1.0 => p2.pan;
0.05 => s2.gain;
0.03 => r2.mix;

// cadena de sonido
s => r => p => dac;
s2 => r2 => p2 => dac;

// esta es la melodía de referencia 
[ 64, 66, 68, 71, 73] @=> int goal[];

// se inicializan los arreglos
int seq[5];
int sequence[goal.cap()];
int sequence2[goal.cap()];

// se crean secuencias aleatorias
// TODO: encontrar mejor solución
function int createRandomNote()
{
  Math.random2(10, 127) => int note;
  return note;
}
for( 0 => int i; i < goal.cap()-1; i++)
  {
    createRandomNote() =>  sequence[i];
    createRandomNote() =>  sequence2[i];
  }

// una función para probabilidad
function int intChance( int percent, int value1, int value2)
{
  int percentArray[100];
  for( 0 => int i; i < 100; i++)
    {
      if( i < percent ) value1 => percentArray[i];
      if( i >= percent ) value2 => percentArray[i];
    }
  percentArray[Math.random2(0, percentArray.cap()-1)] => int selected;
  return selected;
}

// funciones para mutar los arreglos aleatorios
// TODO: una sola función debería poder hacer eso
// TODO: la base de la mutación debe adaptarse a un nuevo arreglo que 
//       ya contiene las notas encontradas
function int mutate()
{
  goal[Math.random2(0, sequence.cap()-1)] =>  sequence[Math.random2(0, goal.cap()-1)];
}
function int mutate2()
{
  goal[Math.random2(0, sequence2.cap()-1)] =>  sequence2[Math.random2(0, goal.cap()-1)];
}

// evalua que tan distante esta de la meta
// TODO: dejar fijas las notas que ya fueron encontradas
// TODO: en un solo if debería poder evaluarse ambas secuencias
// TODO: es feo evaluar cada x milisegundos, esto debería ser
//       comandado por eventos
function void evaluate()
{
  while(true)
    {
      for( 0 => int i; i < goal.cap()-1; i++)
        {
          if(sequence[i] == goal[i])
            {
              <<< "           melodía derecha: ** encontró **  ",  goal[i], "\n" >>>;
            }
          if( sequence2[i] == goal[i])
            {
              <<< "           melodía izquierda: ** encontró ** ",  goal[i], "\n" >>>;
            }
          500::ms => now;
        }
    }
}

// suena las secuencias y se mutan según una probabilidad
// establecida
// TODO: se debería poder tocar las dos secuencias con una
//       sola función
// TODO: en el futuro la función debería recibir argumentos
function void playSequence (int sequence[])
{
  while (true)
    {
      for( 0 => int i; i < (sequence.cap()-1); i++)
        {
          Std.mtof(sequence[i]) => s.freq;
          177::ms => now;
        }
      intChance(30, 1, 0) => int chance;
      if(chance == 1)
        {
          mutate();
          <<< "muta melodía derecha", " => \n">>>;
        }
    }
}

function void playSequence2 (int seq2[])
{
  while (true)
    {
      for( 0 => int i; i < (sequence2.cap()-1); i++)
        {
          Std.mtof(seq2[i])  => s2.freq;
          177::ms => now;
        }
      intChance(10, 1, 0) => int chance;
      if(chance == 1)
        {
          mutate2();
          <<< " <= ", "muta melodía izquierda \n">>>;
        }
    }
}

// llama las funciones
spork~  playSequence(sequence);
spork~  playSequence2(sequence2);
spork~ evaluate();

// mantiene vivos los spork
while(true){ 10::ms => now;}
